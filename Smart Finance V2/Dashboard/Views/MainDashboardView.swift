//
//  MainDashboardView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 09/08/2025.
//  Enhanced with Analytics Integration
//

import SwiftUI
import CoreData

struct MainDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var biometricManager: BiometricManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.transactionDate, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>
    
    // State variables
    @State private var showingAddTransactionView = false
    @State private var showingSettings = false
    @State private var showingTransactionList = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            contentView
            .navigationTitle("Smart Finance")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(content: toolbarContent)
            .refreshable {
                // Refresh transactions when pulled to refresh
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(biometricManager)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingAddTransactionView) {
            AddTransactionView(viewModel: TransactionViewModel(viewContext: viewContext))
        }
        .fullScreenCover(isPresented: $showingTransactionList) {
            TransactionListView(viewContext: viewContext)
        }
    }

    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                headerSection
                balanceCard
                simpleStatsSection
                quickActionsSection
                recentTransactions
                quickStatsSection
            }
            .padding()
        }
    }
    
    // MARK: - Toolbar Content
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingAddTransactionView = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good \(greetingTime())")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Here's your financial overview")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { showingSettings = true }) {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
    }
    
    // MARK: - Balance Card
    private var balanceCard: some View {
        Button(action: { showingTransactionList = true }) {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Current Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formatCurrency(totalBalance))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(totalBalance >= 0 ? .green : .red)
                        .contentTransition(.numericText())
                }
                
                HStack(spacing: 40) {
                    // Income
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.green)
                            Text("Income")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text(formatCurrency(totalIncome))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    // Expenses
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack {
                            Text("Expenses")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.red)
                        }
                        Text(formatCurrency(abs(totalExpenses)))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                }
                
                // Tap indicator
                HStack {
                    Text("Tap to view all transactions")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.top, 4)
            }
            .padding()
            .background(cardBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Simple Stats Section
    private var simpleStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Quick Stats")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                SimpleStatCard(
                    title: "Daily Avg",
                    value: formatCurrency(dailyAverage),
                    icon: "calendar",
                    color: .blue
                )
                
                SimpleStatCard(
                    title: "This Week",
                    value: formatCurrency(weeklySpending),
                    icon: "chart.bar.fill",
                    color: .purple
                )
            }
            
            // Simple spending indicator
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Spending This Month")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(formatCurrency(abs(totalExpenses)))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.red.opacity(0.7))
                            .frame(width: geometry.size.width * spendingProgress)
                            .animation(.easeInOut(duration: 0.5), value: totalExpenses)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding()
        .background(cardBackground)
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Add Income",
                    icon: "plus.circle.fill",
                    color: .green
                ) {
                    showingAddTransactionView = true
                }
                
                QuickActionButton(
                    title: "Add Expense",
                    icon: "minus.circle.fill",
                    color: .red
                ) {
                    showingAddTransactionView = true
                }
                
                QuickActionButton(
                    title: "View All",
                    icon: "list.bullet",
                    color: .blue
                ) {
                    showingTransactionList = true
                }
            }
        }
    }
    
    // MARK: - Recent Transactions Section
    private var recentTransactions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    showingTransactionList = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            if transactions.isEmpty {
                emptyTransactionsView
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(transactions.prefix(3)), id: \.id) { transaction in
                        RecentTransactionRowView(transaction: transaction)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Month")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                StatCardView(
                    title: "Transactions",
                    value: "\(transactions.count)",
                    icon: "list.number",
                    color: .blue
                )
                
                StatCardView(
                    title: "Categories",
                    value: "\(uniqueCategories)",
                    icon: "tag.fill",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Empty Transactions View
    private var emptyTransactionsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "creditcard")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("No transactions yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Add your first transaction") {
                showingAddTransactionView = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    private var totalBalance: Double {
        transactions.reduce(0) { total, transaction in
            let amount = transaction.amount?.doubleValue ?? 0
            return total + amount
        }
    }
    
    private var totalIncome: Double {
        transactions
            .filter { ($0.amount?.doubleValue ?? 0) > 0 }
            .reduce(0) { total, transaction in
                total + (transaction.amount?.doubleValue ?? 0)
            }
    }
    
    private var totalExpenses: Double {
        transactions
            .filter { ($0.amount?.doubleValue ?? 0) < 0 }
            .reduce(0) { total, transaction in
                total + (transaction.amount?.doubleValue ?? 0)
            }
    }
    
    private var uniqueCategories: Int {
        Set(transactions.compactMap { $0.category }).count
    }
    
    // ✅ NEW: Added missing computed properties
    private var dailyAverage: Double {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentTransactions = transactions.filter {
            ($0.transactionDate ?? Date()) >= thirtyDaysAgo && ($0.amount?.doubleValue ?? 0) < 0
        }
        let totalSpent = recentTransactions.reduce(0) { $0 + abs($1.amount?.doubleValue ?? 0) }
        return totalSpent / 30.0
    }

    private var weeklySpending: Double {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weekTransactions = transactions.filter {
            ($0.transactionDate ?? Date()) >= weekAgo && ($0.amount?.doubleValue ?? 0) < 0
        }
        return weekTransactions.reduce(0) { $0 + abs($1.amount?.doubleValue ?? 0) }
    }
    
    private var spendingProgress: Double {
        let maxSpending = max(totalIncome * 0.7, 1000) // Either 70% of income or $1000 minimum
        return min(abs(totalExpenses) / maxSpending, 1.0)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemGray6))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Helper Functions
    private func greetingTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Morning"
        case 12..<17: return "Afternoon"
        default: return "Evening"
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Supporting Views

// ✅ NEW: Added missing SimpleStatCard
struct SimpleStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
        )
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentTransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: categoryIcon)
                    .font(.system(size: 14))
                    .foregroundColor(categoryColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.notes ?? "No description")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(transaction.category ?? "General")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatAmount())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(amountColor)
        }
        .padding(.vertical, 4)
    }
    
    private var categoryColor: Color {
        switch transaction.category?.lowercased() {
        case "food": return .orange
        case "transport": return .blue
        case "shopping": return .purple
        case "entertainment": return .pink
        case "bills": return .red
        case "salary", "income": return .green
        default: return .gray
        }
    }
    
    private var categoryIcon: String {
        switch transaction.category?.lowercased() {
        case "food": return "fork.knife"
        case "transport": return "car.fill"
        case "shopping": return "bag.fill"
        case "entertainment": return "tv.fill"
        case "bills": return "bolt.fill"
        case "salary", "income": return "dollarsign.circle.fill"
        default: return "tag.fill"
        }
    }
    
    private var amountColor: Color {
        let amount = transaction.amount?.doubleValue ?? 0
        return amount >= 0 ? .green : .red
    }
    
    private func formatAmount() -> String {
        let amount = transaction.amount?.doubleValue ?? 0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: abs(amount))) ?? "$0.00"
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Extensions

extension View {
    func shimmer() -> some View {
        self.overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(.degrees(-45))
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                    value: UUID()
                )
        )
        .clipped()
    }
}

// MARK: - Preview
#Preview {
    MainDashboardView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(BiometricManager())
}
