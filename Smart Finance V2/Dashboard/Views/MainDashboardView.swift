//
//  MainDashboardView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 09/08/2025.
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
    
    @State private var showingAddTransactionView = false
    @State private var showingSettings = false
    @State private var showingTransactionList = false // ✅ NEW: For navigation

    // MARK: - Computed Properties
    private var totalBalance: Double {
        transactions.reduce(0) { total, transaction in
            let amount = transaction.amount?.doubleValue ?? 0
            return total + amount
        }
    }

    private var balanceChange: Double {
        245.67 // Mock data - you can calculate real change later
    }

    // MARK: - UI Components
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Balance Card (now interactive)
                    balanceCard
                    
                    // Quick Actions Section ✅ NEW
                    quickActionsSection
                    
                    // Recent Transactions (now interactive)
                    recentTransactions
                    
                    // Quick Stats Section
                    quickStatsSection
                }
                .padding()
            }
            .navigationTitle("Smart Finance")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    // ✅ UPDATED: Quick add transaction button
                    Button(action: { showingAddTransactionView = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(biometricManager)
                    .environment(\.managedObjectContext, viewContext)
            }
            // ✅ NEW: Add transaction sheet
            .sheet(isPresented: $showingAddTransactionView) {
                AddTransactionView(viewModel: TransactionViewModel(viewContext: viewContext))
            }
            // ✅ NEW: Full screen transaction list
            .fullScreenCover(isPresented: $showingTransactionList) {
                TransactionListView(viewContext: viewContext)
            }
        }
    }
    
    // ✅ UPDATED: Interactive balance card
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
                
                // ✅ NEW: Tap indicator
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
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // ✅ NEW: Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                // Add Income
                quickActionButton(
                    title: "Add Income",
                    icon: "plus.circle.fill",
                    color: .green
                ) {
                    // You can preset income when opening add transaction
                    showingAddTransactionView = true
                }
                
                // Add Expense
                quickActionButton(
                    title: "Add Expense",
                    icon: "minus.circle.fill",
                    color: .red
                ) {
                    showingAddTransactionView = true
                }
                
                // View All
                quickActionButton(
                    title: "View All",
                    icon: "list.bullet",
                    color: .blue
                ) {
                    showingTransactionList = true
                }
            }
        }
    }
    
    // ✅ NEW: Quick action button helper
    private func quickActionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
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
    
    // ✅ UPDATED: Interactive recent transactions
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
                // Empty state
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
            } else {
                // Show recent transactions (limit to 3)
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
    
    // ✅ NEW: Computed properties for dashboard
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
    
    // ✅ NEW: Helper function
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// ✅ NEW: Recent transaction row for dashboard
struct RecentTransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: categoryIcon)
                    .font(.system(size: 14))
                    .foregroundColor(categoryColor)
            }
            
            // Transaction details
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
            
            // Amount
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

// ✅ NEW: Stat card for dashboard
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

// MARK: - Preview
#Preview {
    MainDashboardView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(BiometricManager())
}
