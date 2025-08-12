//
//  TransactionListView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 12/08/2025.
//

import SwiftUI
import CoreData

struct TransactionListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: TransactionViewModel
    @State private var showingAddTransaction = false
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var selectedTransactionForEdit: Transaction?
    
    private let categories = ["All", "Food", "Transport", "Shopping", "Bills", "Income", "Entertainment"]
    
    init(viewContext: NSManagedObjectContext) {
        self._viewModel = StateObject(wrappedValue: TransactionViewModel(viewContext: viewContext))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                balanceHeader
                searchAndFilterBar
                transactionsList
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(viewModel: viewModel)
            }
            // ✅ FIXED: Moved EditTransactionView sheet inside NavigationView
            .sheet(item: $selectedTransactionForEdit) { transaction in
                EditTransactionView(viewModel: viewModel, transaction: transaction)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private var balanceHeader: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("Current Balance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(formatCurrency(viewModel.totalBalance))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(balanceColor())
                    .contentTransition(.numericText())
            }
            
            HStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        Text("Income")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(formatCurrency(viewModel.totalIncome))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Text("Expenses")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.red)
                    }
                    
                    Text(formatCurrency(abs(viewModel.totalExpenses)))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search transactions...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        CategoryFilterChip(
                            title: category,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var transactionsList: some View {
        
            if viewModel.isLoading {
                AnyView(
                    ProgressView("Loading transactions...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                )
            } else if filteredTransactions.isEmpty {
                AnyView(emptyState)
            } else {
                AnyView(
                    List {
                        ForEach(filteredTransactions, id: \.id) { transaction in
                            TransactionRowView(transaction: transaction)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    deleteButton(for: transaction)
                                    editButton(for: transaction)
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewModel.fetchTransactions()
                    }
                )
            
        }
    }
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Transactions Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(searchText.isEmpty ?
                 "Add your first transaction to get started!" :
                 "Try adjusting your search or filters")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if searchText.isEmpty {
                Button("Add Transaction") {
                    showingAddTransaction = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Action Buttons
    private var addButton: some View {
        Button(action: { showingAddTransaction = true }) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
        }
    }
    
    private func editButton(for transaction: Transaction) -> some View {
        Button("Edit") {
            selectedTransactionForEdit = transaction
        }
        .tint(.blue)
    }
    
    private func deleteButton(for transaction: Transaction) -> some View {
        Button("Delete") {
            withAnimation(.spring()) {
                viewModel.deleteTransaction(transaction)
            }
        }
        .tint(.red)
    }
    
    // MARK: - Computed Properties
    private var filteredTransactions: [Transaction] {
        viewModel.transactions.filter { transaction in
            let matchesSearch = searchText.isEmpty ||
                (transaction.notes?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (transaction.merchant?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchesCategory = selectedCategory == "All" ||
                (transaction.category?.localizedCaseInsensitiveContains(selectedCategory) ?? false)
            
            return matchesSearch && matchesCategory
        }
    }
    
    // MARK: - Helper Functions
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private func balanceColor() -> Color {
        return viewModel.totalBalance >= 0 ? .green : .red
    }
}

// MARK: - Category Filter Chip
struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.blue : Color(.systemGray6))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    let viewModel = TransactionViewModel(viewContext: context)
    
    // ✅ FIXED: Proper preview setup
    DispatchQueue.main.async {
        viewModel.addSampleData()
    }
    
    return TransactionListView(viewContext: context)
}
