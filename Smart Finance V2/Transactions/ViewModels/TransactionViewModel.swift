//
//  TransactionViewModel.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 12/08/2025.
//

import SwiftUI
import CoreData

@MainActor
class TransactionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var transactions: [Transaction] = []
    @Published var totalBalance: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Core Data
    private let viewContext: NSManagedObjectContext
    
    // MARK: - Initialisation
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchTransactions()
        calculateBalance()
    }
}

// MARK: - Core Operations
extension TransactionViewModel {
    
    func fetchTransactions() {
        isLoading = true
        
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Transaction.transactionDate, ascending: false)
        ]
        
        do {
            transactions = try viewContext.fetch(request)
            calculateBalance()
            errorMessage = nil
            print("✅ Fetched \(transactions.count) transactions")
        } catch {
            errorMessage = "Error fetching transactions: \(error.localizedDescription)"
            print("❌ Fetch error: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func calculateBalance() {
        totalBalance = transactions.reduce(0) { total, transaction in
            let amount = transaction.amount?.doubleValue ?? 0
            return total + amount
        }
        print("💰 Current balance: $\(String(format: "%.2f", totalBalance))")
    }
    
    var totalIncome: Double {
        return transactions
            .filter { ($0.amount?.doubleValue ?? 0) > 0 }
            .reduce(0) { total, transaction in
                total + (transaction.amount?.doubleValue ?? 0)
            }
    }
    
    var totalExpenses: Double {
        return transactions
            .filter { ($0.amount?.doubleValue ?? 0) < 0 }
            .reduce(0) { total, transaction in
                total + (transaction.amount?.doubleValue ?? 0)
            }
    }
    
    // ✅ FIXED: Using correct Core Data attributes
    func addTransaction(
        amount: Double,
        description: String,
        categoryName: String = "General",
        date: Date = Date(),
        merchant: String? = nil,
        paymentMethod: String? = nil,
        tags: String? = nil
    ) {
        guard isValidTransactionData(amount: amount, description: description) else {
            errorMessage = "Invalid transaction data. Please check amount and description."
            return
        }
        
        isLoading = true
        
        let newTransaction = Transaction(context: viewContext)
        
        // ✅ FIXED: Using your exact Core Data attribute names
        newTransaction.id = UUID()                                    // ✅ 'id' attribute
        newTransaction.amount = NSDecimalNumber(value: amount)        // ✅ 'amount' attribute
        newTransaction.notes = description.trimmingCharacters(in: .whitespacesAndNewlines) // ✅ 'notes' attribute
        newTransaction.transactionDate = date                        // ✅ 'transactionDate' attribute
        newTransaction.createdDate = Date()                          // ✅ 'createdDate' attribute
        newTransaction.merchant = merchant                           // ✅ 'merchant' attribute
        newTransaction.paymentMethod = paymentMethod                 // ✅ 'paymentMethod' attribute
        newTransaction.tags = tags                                   // ✅ 'tags' attribute
        newTransaction.isRecurring = false                          // ✅ 'isRecurring' attribute
        
        // ✅ Handle category relationship
        newTransaction.category = findOrCreateCategory(name: categoryName)
        
        do {
            try viewContext.save()
            fetchTransactions()
            print("✅ Transaction added: \(description) - $\(amount)")
        } catch {
            errorMessage = "Error saving transaction: \(error.localizedDescription)"
            print("❌ Save error: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    // ✅ FIXED: Update method with correct attributes
    func updateTransaction(
        _ transaction: Transaction,
        amount: Double? = nil,
        description: String? = nil,
        categoryName: String? = nil,
        date: Date? = nil,
        merchant: String? = nil,
        paymentMethod: String? = nil,
        tags: String? = nil
    ) {
        isLoading = true
        
        // ✅ FIXED: Using correct attribute names
        if let amount = amount {
            transaction.amount = NSDecimalNumber(value: amount)
        }
        if let description = description {
            transaction.notes = description.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let date = date {
            transaction.transactionDate = date
        }
        if let merchant = merchant {
            transaction.merchant = merchant
        }
        if let paymentMethod = paymentMethod {
            transaction.paymentMethod = paymentMethod
        }
        if let tags = tags {
            transaction.tags = tags
        }
        if let categoryName = categoryName {
            transaction.category = findOrCreateCategory(name: categoryName)
        }
        
        do {
            try viewContext.save()
            fetchTransactions()
            print("✅ Transaction updated")
        } catch {
            errorMessage = "Failed to update transaction: \(error.localizedDescription)"
            print("❌ Update error: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        isLoading = true
        viewContext.delete(transaction)
        
        do {
            try viewContext.save()
            fetchTransactions()
            print("✅ Transaction deleted")
        } catch {
            errorMessage = "Failed to delete transaction: \(error.localizedDescription)"
            print("❌ Delete error: \(error.localizedDescription)")
        }
        isLoading = false
    }
}

// MARK: - Category Management
extension TransactionViewModel {
    
    // ✅ Note: Your model shows 'category' as String, not relationship
    // This suggests category is stored as string name, not Core Data relationship
    func findOrCreateCategory(name: String) -> String {
        // Since 'category' is a String attribute in your model, just return the name
        return name
    }
    
    // ✅ UPDATED: Helper method for category colors (for UI)
    func colorForCategory(_ name: String) -> String {
        switch name.lowercased() {
        case "food", "dining": return "orange"
        case "transport", "gas": return "blue"
        case "shopping": return "purple"
        case "salary", "income": return "green"
        case "bills", "utilities": return "red"
        default: return "gray"
        }
    }
    
    // ✅ UPDATED: Helper method for category icons (for UI)
    func iconForCategory(_ name: String) -> String {
        switch name.lowercased() {
        case "food", "dining": return "fork.knife"
        case "transport", "gas": return "car.fill"
        case "shopping": return "bag.fill"
        case "salary", "income": return "dollarsign.circle.fill"
        case "bills", "utilities": return "bolt.fill"
        default: return "tag.fill"
        }
    }
}

// MARK: - Validation & Debugging
extension TransactionViewModel {
    
    func isValidTransactionData(amount: Double, description: String) -> Bool {
        guard amount != 0 && abs(amount) < 1_000_000 else { return false }
        guard !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        return true
    }
    
    // ✅ FIXED: Debug method using correct attributes
    func debugPrintTransactions() {
        print("\n🔍 DEBUG: Current Transactions (\(transactions.count) total)")
        print("💰 Balance: $\(String(format: "%.2f", totalBalance))")
        print("📈 Income: $\(String(format: "%.2f", totalIncome))")
        print("📉 Expenses: $\(String(format: "%.2f", abs(totalExpenses)))")
        print("---")
        
        for (index, transaction) in transactions.enumerated() {
            let amount = transaction.amount?.doubleValue ?? 0
            let notes = transaction.notes ?? "No description"          // ✅ 'notes' attribute
            let category = transaction.category ?? "No category"       // ✅ 'category' string attribute
            let merchant = transaction.merchant ?? "Unknown"           // ✅ 'merchant' attribute
            
            print("\(index + 1). \(notes) - $\(String(format: "%.2f", amount)) (\(category)) at \(merchant)")
        }
        print("---\n")
    }
    
    // ✅ ENHANCED: Sample data with more details
    func addSampleData() {
        let sampleTransactions: [(Double, String, String, String?, String?)] = [
            (-4.50, "Morning Coffee", "food", "Starbucks", "Credit Card"),
            (-25.99, "Gas Station Fill-up", "transport", "Shell", "Debit Card"),
            (-89.99, "Grocery Shopping", "food", "Whole Foods", "Credit Card"),
            (2500.00, "Monthly Salary", "salary", "Company Inc", "Direct Deposit"),
            (-45.00, "Phone Bill", "bills", "Verizon", "Auto Pay"),
            (-12.99, "Netflix Subscription", "entertainment", "Netflix", "Credit Card"),
            (100.00, "Freelance Project", "income", "Client XYZ", "PayPal")
        ]
        
        for (amount, description, category, merchant, paymentMethod) in sampleTransactions {
            addTransaction(
                amount: amount,
                description: description,
                categoryName: category,
                merchant: merchant,
                paymentMethod: paymentMethod
            )
        }
        
        debugPrintTransactions()
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    let viewModel = TransactionViewModel(viewContext: context)
    
    return VStack(alignment: .leading, spacing: 10) {
        Text("🔍 TransactionViewModel Debug")
            .font(.title2)
            .fontWeight(.bold)
        
        Text("Balance: $\(viewModel.totalBalance, specifier: "%.2f")")
            .foregroundColor(viewModel.totalBalance >= 0 ? .green : .red)
        
        Text("Income: $\(viewModel.totalIncome, specifier: "%.2f")")
            .foregroundColor(.green)
        
        Text("Expenses: $\(abs(viewModel.totalExpenses), specifier: "%.2f")")
            .foregroundColor(.red)
        
        Text("Transactions: \(viewModel.transactions.count)")
        
        Button("Add Sample Data") {
            viewModel.addSampleData()
        }
        .buttonStyle(.borderedProminent)
        
        Button("Debug Print") {
            viewModel.debugPrintTransactions()
        }
        .buttonStyle(.bordered)
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
}
