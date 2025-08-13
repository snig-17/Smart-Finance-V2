//
//  AnalyticsViewModel.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari on 13/08/2025.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
class AnalyticsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var selectedTimeframe: AnalyticsTimeframe = .thirtyDays
    @Published var spendingTrends: [SpendingTrend] = []
    @Published var categoryInsights: [CategoryInsight] = []
    @Published var monthlyComparisons: [MonthlyComparison] = []
    @Published var financialInsights: [FinancialInsight] = []
    @Published var errorMessage: String?
    
    // MARK: - Computed Analytics Properties
    @Published var totalSpent: Double = 0
    @Published var totalIncome: Double = 0
    @Published var averageDailySpending: Double = 0
    @Published var spendingVelocity: Double = 0
    @Published var budgetUtilization: Double = 0
    
    // MARK: - Core Data
    private let viewContext: NSManagedObjectContext
    private let transactionViewModel: TransactionViewModel
    
    // MARK: - Time-based Filtering
    enum AnalyticsTimeframe: String, CaseIterable {
        case sevenDays = "7D"
        case thirtyDays = "30D"
        case ninetyDays = "90D"
        case oneYear = "1Y"
        
        var days: Int {
            switch self {
            case .sevenDays: return 7
            case .thirtyDays: return 30
            case .ninetyDays: return 90
            case .oneYear: return 365
            }
        }
        
        var displayName: String {
            switch self {
            case .sevenDays: return "Last 7 Days"
            case .thirtyDays: return "Last 30 Days"
            case .ninetyDays: return "Last 3 Months"
            case .oneYear: return "Last Year"
            }
        }
    }
    
    // MARK: - Initialization
    init(viewContext: NSManagedObjectContext, transactionViewModel: TransactionViewModel) {
        self.viewContext = viewContext
        self.transactionViewModel = transactionViewModel
        
        // Listen to transaction changes for real-time updates
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: viewContext,
            queue: .main
        ) { [weak self] _ in
            self?.refreshAnalytics()
        }
        
        // Initial data load
        refreshAnalytics()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Main Analytics Refresh
    func refreshAnalytics() {
        Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            do {
                let transactions = try await fetchTransactionsForTimeframe()
                
                await MainActor.run {
                    self.calculateBasicMetrics(from: transactions)
                    self.generateSpendingTrends(from: transactions)
                    self.analyzeCategoryInsights(from: transactions)
                    self.generateMonthlyComparisons(from: transactions)
                    self.generateFinancialInsights(from: transactions)
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load analytics: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Data Fetching
    private func fetchTransactionsForTimeframe() async throws -> [Transaction] {
        return try await withCheckedThrowingContinuation { continuation in
            viewContext.perform {
                let request: NSFetchRequest = Transaction.fetchRequest()
                
                // Calculate date range
                let endDate = Date()
                guard let startDate = Calendar.current.date(
                    byAdding: .day,
                    value: -self.selectedTimeframe.days,
                    to: endDate
                ) else {
                    continuation.resume(throwing: AnalyticsError.dateCalculationFailed)
                    return
                }
                
                // Set up predicate for date filtering
                request.predicate = NSPredicate(
                    format: "transactionDate >= %@ AND transactionDate <= %@",
                    startDate as NSDate,
                    endDate as NSDate
                )
                
                // Sort by transaction date
                request.sortDescriptors = [
                    NSSortDescriptor(keyPath: \Transaction.transactionDate, ascending: true)
                ]
                
                do {
                    let transactions = try self.viewContext.fetch(request)
                    continuation.resume(returning: transactions)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Basic Metrics Calculation
    private func calculateBasicMetrics(from transactions: [Transaction]) {
        let expenses = transactions.filter { amountAsDouble($0) < 0 }
        let income = transactions.filter { amountAsDouble($0) > 0 }
        
        // Calculate totals
        totalSpent = expenses.reduce(0) { $0 + abs(amountAsDouble($1)) }
        totalIncome = income.reduce(0) { $0 + amountAsDouble($1) }
        
        // Calculate average daily spending
        let days = Double(selectedTimeframe.days)
        averageDailySpending = days > 0 ? totalSpent / days : 0
        
        // Calculate spending velocity (trend over time)
        spendingVelocity = calculateSpendingVelocity(from: expenses)
        
        // Calculate budget utilization (70% of income as ideal spending)
        let idealSpending = totalIncome * 0.7
        budgetUtilization = idealSpending > 0 ? (totalSpent / idealSpending) * 100 : 0
    }
    
    // MARK: - Spending Velocity Calculation
    private func calculateSpendingVelocity(from expenses: [Transaction]) -> Double {
        guard expenses.count > 1 else { return 0 }
        
        let sortedExpenses = expenses.sorted {
            transactionDate($0) < transactionDate($1)
        }
        
        let midPoint = sortedExpenses.count / 2
        let firstHalf = Array(sortedExpenses.prefix(midPoint))
        let secondHalf = Array(sortedExpenses.suffix(sortedExpenses.count - midPoint))
        
        guard !firstHalf.isEmpty && !secondHalf.isEmpty else { return 0 }
        
        let firstHalfTotal = firstHalf.reduce(0) { $0 + abs(amountAsDouble($1)) }
        let secondHalfTotal = secondHalf.reduce(0) { $0 + abs(amountAsDouble($1)) }
        
        guard firstHalfTotal > 0 else { return 0 }
        return ((secondHalfTotal - firstHalfTotal) / firstHalfTotal) * 100
    }
    
    // MARK: - Spending Trends Generation
    private func generateSpendingTrends(from transactions: [Transaction]) {
        let calendar = Calendar.current
        let groupedByDay = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transactionDate(transaction))
        }
        
        spendingTrends = groupedByDay.compactMap { date, dayTransactions in
            let dailyExpenses = dayTransactions
                .filter { amountAsDouble($0) < 0 }
                .reduce(0) { $0 + abs(amountAsDouble($1)) }
            
            let dailyIncome = dayTransactions
                .filter { amountAsDouble($0) > 0 }
                .reduce(0) { $0 + amountAsDouble($1) }
            
            var trends: [SpendingTrend] = []
            
            if dailyExpenses > 0 {
                trends.append(SpendingTrend(date: date, amount: dailyExpenses, type: .expense))
            }
            
            if dailyIncome > 0 {
                trends.append(SpendingTrend(date: date, amount: dailyIncome, type: .income))
            }
            
            return trends
        }
        .flatMap { $0 }
        .sorted { $0.date < $1.date }
    }
    
    // MARK: - Category Insights Analysis
    private func analyzeCategoryInsights(from transactions: [Transaction]) {
        let expenses = transactions.filter { amountAsDouble($0) < 0 }
        let totalExpenses = expenses.reduce(0) { $0 + abs(amountAsDouble($1)) }
        
        let groupedByCategory = Dictionary(grouping: expenses) { transaction in
            transaction.category ?? "Uncategorized"
        }
        
        categoryInsights = groupedByCategory.map { category, categoryTransactions in
            let categoryTotal = categoryTransactions.reduce(0) {
                $0 + abs(amountAsDouble($1))
            }
            let percentage = totalExpenses > 0 ? (categoryTotal / totalExpenses) * 100 : 0
            let trend = calculateCategoryTrend(transactions: categoryTransactions)
            
            return CategoryInsight(
                category: category,
                totalSpent: categoryTotal,
                transactionCount: categoryTransactions.count,
                percentage: percentage,
                trend: trend
            )
        }
        .sorted { $0.totalSpent > $1.totalSpent }
    }
    
    // MARK: - Category Trend Calculation
    private func calculateCategoryTrend(transactions: [Transaction]) -> Double {
        let sortedTransactions = transactions.sorted {
            transactionDate($0) < transactionDate($1)
        }
        let midPoint = sortedTransactions.count / 2
        
        guard midPoint > 0 else { return 0 }
        
        let firstHalf = Array(sortedTransactions.prefix(midPoint))
        let secondHalf = Array(sortedTransactions.suffix(sortedTransactions.count - midPoint))
        
        guard !firstHalf.isEmpty && !secondHalf.isEmpty else { return 0 }
        
        let firstHalfAvg = firstHalf.reduce(0) {
            $0 + abs(amountAsDouble($1))
        } / Double(firstHalf.count)
        
        let secondHalfAvg = secondHalf.reduce(0) {
            $0 + abs(amountAsDouble($1))
        } / Double(secondHalf.count)
        
        guard firstHalfAvg > 0 else { return 0 }
        return ((secondHalfAvg - firstHalfAvg) / firstHalfAvg) * 100
    }
    
    // MARK: - Monthly Comparisons
    private func generateMonthlyComparisons(from transactions: [Transaction]) {
        let calendar = Calendar.current
        let groupedByMonth = Dictionary(grouping: transactions) { transaction in
            calendar.dateInterval(of: .month, for: transactionDate(transaction))?.start ?? transactionDate(transaction)
        }
        
        monthlyComparisons = groupedByMonth.map { monthStart, monthTransactions in
            let monthlyIncome = monthTransactions
                .filter { amountAsDouble($0) > 0 }
                .reduce(0) { $0 + amountAsDouble($1) }
            
            let monthlyExpenses = monthTransactions
                .filter { amountAsDouble($0) < 0 }
                .reduce(0) { $0 + abs(amountAsDouble($1)) }
            
            let netFlow = monthlyIncome - monthlyExpenses
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            let monthString = formatter.string(from: monthStart)
            
            return MonthlyComparison(
                month: monthString,
                income: monthlyIncome,
                expenses: monthlyExpenses,
                netFlow: netFlow,
                previousMonthChange: 0 // TODO: Calculate actual month-over-month change
            )
        }
        .sorted { $0.month < $1.month }
    }
    
    // MARK: - Financial Insights Generation
    private func generateFinancialInsights(from transactions: [Transaction]) {
        var insights: [FinancialInsight] = []
        
        // Spending acceleration alert
        if spendingVelocity > 20 {
            insights.append(FinancialInsight(
                title: "Spending Acceleration Alert",
                description: "Your spending has increased by \(String(format: "%.1f", spendingVelocity))% in the recent period",
                value: "\(String(format: "%.1f", spendingVelocity))%",
                trend: .negative,
                priority: .high
            ))
        }
        
        // Budget utilization warning
        if budgetUtilization > 80 {
            insights.append(FinancialInsight(
                title: "Budget Alert",
                description: "You've used \(String(format: "%.0f", budgetUtilization))% of your recommended spending budget",
                value: "\(String(format: "%.0f", budgetUtilization))%",
                trend: .negative,
                priority: budgetUtilization > 100 ? .high : .medium
            ))
        }
        
        // Top spending category insight
        if let topCategory = categoryInsights.first {
            insights.append(FinancialInsight(
                title: "Top Spending Category",
                description: "\(topCategory.category) represents \(String(format: "%.1f", topCategory.percentage))% of your total expenses",
                value: formatCurrency(topCategory.totalSpent),
                trend: topCategory.trend > 0 ? .negative : .positive,
                priority: .medium
            ))
        }
        
        // Savings rate insight
        let savingsRate = totalIncome > 0 ? ((totalIncome - totalSpent) / totalIncome) * 100 : 0
        if savingsRate > 20 {
            insights.append(FinancialInsight(
                title: "Excellent Savings Rate",
                description: "You're successfully saving \(String(format: "%.1f", savingsRate))% of your income",
                value: "\(String(format: "%.1f", savingsRate))%",
                trend: .positive,
                priority: .medium
            ))
        } else if savingsRate < 0 {
            insights.append(FinancialInsight(
                title: "Spending More Than Earning",
                description: "Your expenses exceed your income by \(String(format: "%.1f", abs(savingsRate)))%",
                value: "\(String(format: "%.1f", abs(savingsRate)))%",
                trend: .negative,
                priority: .high
            ))
        }
        
        // Transaction frequency insight
        let transactionCount = transactions.count
        let averageTransactionsPerDay = Double(transactionCount) / Double(selectedTimeframe.days)
        if averageTransactionsPerDay > 5 {
            insights.append(FinancialInsight(
                title: "High Transaction Frequency",
                description: "You're making \(String(format: "%.1f", averageTransactionsPerDay)) transactions per day on average",
                value: "\(transactionCount) transactions",
                trend: .neutral,
                priority: .low
            ))
        }
        
        financialInsights = insights
    }
    
    // MARK: - Helper Functions
    private func amountAsDouble(_ transaction: Transaction) -> Double {
        return transaction.amount?.doubleValue ?? 0.0
    }
    
    private func transactionDate(_ transaction: Transaction) -> Date {
        return transaction.transactionDate ?? Date()
    }
    
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    func changeTimeframe(to timeframe: AnalyticsTimeframe) {
        selectedTimeframe = timeframe
        refreshAnalytics()
    }
    
    // MARK: - Chart Data Preparation
    var dailySpendingChartData: [(String, Double)] {
        let calendar = Calendar.current
        let expenses = spendingTrends.filter { $0.type == .expense }
        
        return expenses.map { trend in
            let formatter = DateFormatter()
            formatter.dateFormat = selectedTimeframe == .sevenDays ? "E" : "MMM d"
            return (formatter.string(from: trend.date), trend.amount)
        }
    }
    
    var categoryChartData: [(String, Double, Color)] {
        let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .yellow, .cyan]
        
        return categoryInsights.prefix(8).enumerated().map { index, insight in
            let color = colors[index % colors.count]
            return (insight.category, insight.percentage, color)
        }
    }
    
    var monthlyComparisonChartData: [(String, Double, Double)] {
        return monthlyComparisons.map { comparison in
            (comparison.month, comparison.income, comparison.expenses)
        }
    }
    
    var incomeVsExpenseData: (income: Double, expenses: Double, savings: Double) {
        let savings = max(0, totalIncome - totalSpent)
        return (totalIncome, totalSpent, savings)
    }
    
    var topCategoriesForChart: [(String, Double)] {
        return categoryInsights.prefix(5).map {
            ($0.category, $0.totalSpent)
        }
    }
}

// MARK: - Custom Errors
enum AnalyticsError: Error {
    case dateCalculationFailed
    case noDataAvailable
    case calculationError
    
    var localizedDescription: String {
        switch self {
        case .dateCalculationFailed:
            return "Failed to calculate date range for analytics"
        case .noDataAvailable:
            return "No transaction data available for the selected timeframe"
        case .calculationError:
            return "Error occurred during analytics calculation"
        }
    }
}

// MARK: - Preview Helper
extension AnalyticsViewModel {
    static func preview(context: NSManagedObjectContext) -> AnalyticsViewModel {
        let transactionVM = TransactionViewModel(viewContext: context)
        return AnalyticsViewModel(viewContext: context, transactionViewModel: transactionVM)
    }
    
    // For preview/testing purposes
    func addSampleAnalyticsData() {
        // This would be used in previews to populate with sample data
        totalSpent = 2500.0
        totalIncome = 3500.0
        averageDailySpending = 83.33
        spendingVelocity = 15.5
        budgetUtilization = 102.0
        
        spendingTrends = [
            SpendingTrend(date: Date().addingTimeInterval(-6*24*60*60), amount: 120.0, type: .expense),
            SpendingTrend(date: Date().addingTimeInterval(-5*24*60*60), amount: 80.0, type: .expense),
            SpendingTrend(date: Date().addingTimeInterval(-4*24*60*60), amount: 200.0, type: .expense),
            SpendingTrend(date: Date().addingTimeInterval(-3*24*60*60), amount: 1500.0, type: .income),
            SpendingTrend(date: Date().addingTimeInterval(-2*24*60*60), amount: 150.0, type: .expense),
            SpendingTrend(date: Date().addingTimeInterval(-1*24*60*60), amount: 90.0, type: .expense),
            SpendingTrend(date: Date(), amount: 110.0, type: .expense)
        ]
        
        categoryInsights = [
            CategoryInsight(category: "Food", totalSpent: 800.0, transactionCount: 15, percentage: 32.0, trend: 5.2),
            CategoryInsight(category: "Transport", totalSpent: 600.0, transactionCount: 8, percentage: 24.0, trend: -2.1),
            CategoryInsight(category: "Shopping", totalSpent: 500.0, transactionCount: 5, percentage: 20.0, trend: 12.5),
            CategoryInsight(category: "Bills", totalSpent: 400.0, transactionCount: 3, percentage: 16.0, trend: 0.0),
            CategoryInsight(category: "Entertainment", totalSpent: 200.0, transactionCount: 4, percentage: 8.0, trend: -5.5)
        ]
        
        financialInsights = [
            FinancialInsight(
                title: "Budget Alert",
                description: "You've exceeded your recommended spending by 2%",
                value: "102%",
                trend: .negative,
                priority: .high
            ),
            FinancialInsight(
                title: "Food Spending Increase",
                description: "Your food expenses have increased by 5.2% recently",
                value: "$800.00",
                trend: .negative,
                priority: .medium
            )
        ]
    }
}
