//
//  AddTransactionView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 12/08/2025.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    
    @State private var amount: String = ""
    @State private var notes: String = ""
    @State private var selectedCategory: String = "General"
    @State private var merchant: String = ""
    @State private var paymentMethod: String = "Cash"
    @State private var transactionDate = Date()
    @State private var isIncome = false
    @State private var tags: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let categories = ["General", "Food", "Transport", "Shopping", "Entertainment", "Bills", "Healthcare", "Education", "Salary", "Income"]
    private let paymentMethods = ["Cash", "Credit Card", "Debit Card", "Bank Transfer", "PayPal", "Apple Pay"]
    
    var body: some View {
        NavigationView {
            Form {
                // Transaction Type Section
                Section(header: Text("Transaction Type")) {
                    Picker("Type", selection: $isIncome) {
                        Label("Expense", systemImage: "arrow.down.circle")
                            .foregroundColor(.red)
                            .tag(false)
                        
                        Label("Income", systemImage: "arrow.up.circle")
                            .foregroundColor(.green)
                            .tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Amount Section
                Section(header: Text("Amount")) {
                    HStack {
                        Text("$")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(isIncome ? .green : .red)
                    }
                }
                
                // Details Section
                Section(header: Text("Transaction Details")) {
                    TextField("Description/Notes", text: $notes, axis: .vertical)
                        .lineLimit(1...3)
                        .autocapitalization(.sentences)
                    
                    TextField("Merchant/Store (Optional)", text: $merchant)
                        .autocapitalization(.words)
                    
                    TextField("Tags (Optional)", text: $tags)
                        .autocapitalization(.none)
                        .customPlaceholder(when: tags.isEmpty) {
                            Text("e.g., work, personal, urgent")
                                .foregroundColor(.secondary)
                        }
                }
                
                // Category Section
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            HStack {
                                Image(systemName: iconForCategory(category))
                                    .foregroundColor(colorForCategory(category))
                                    .frame(width: 20)
                                Text(category)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 120)
                }
                
                // Payment Method Section
                Section(header: Text("Payment Method")) {
                    Picker("Payment Method", selection: $paymentMethod) {
                        ForEach(paymentMethods, id: \.self) { method in
                            HStack {
                                Image(systemName: iconForPaymentMethod(method))
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                Text(method)
                            }
                            .tag(method)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Date Section
                Section(header: Text("Date & Time")) {
                    DatePicker("Transaction Date", selection: $transactionDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(CompactDatePickerStyle())
                }
                
                // Preview Section
                Section(header: Text("Preview")) {
                    transactionPreview
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(!isValidInput())
                    .fontWeight(.semibold)
                }
            }
            .alert("Transaction Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Transaction Preview
    private var transactionPreview: some View {
        HStack(spacing: 12) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(colorForCategory(selectedCategory).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconForCategory(selectedCategory))
                    .foregroundColor(colorForCategory(selectedCategory))
                    .font(.system(size: 16))
            }
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                Text(notes.isEmpty ? "Transaction description" : notes)
                    .font(.headline)
                    .foregroundColor(notes.isEmpty ? .secondary : .primary)
                    .lineLimit(1)
                
                HStack {
                    // Category Tag
                    Text(selectedCategory)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(colorForCategory(selectedCategory).opacity(0.1))
                        .foregroundColor(colorForCategory(selectedCategory))
                        .cornerRadius(4)
                    
                    // Merchant
                    if !merchant.isEmpty {
                        Text("• \(merchant)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            // Amount and Type
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatPreviewAmount())
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isIncome ? .green : .red)
                
                Text(paymentMethod)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6).opacity(0.5))
        )
        .padding(.horizontal, 4)
    }
    
    // MARK: - Helper Functions
    private func isValidInput() -> Bool {
        guard let amountValue = Double(amount), amountValue > 0 else { return false }
        return !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount) else {
            alertMessage = "Please enter a valid amount"
            showingAlert = true
            return
        }
        
        guard amountValue > 0 else {
            alertMessage = "Amount must be greater than zero"
            showingAlert = true
            return
        }
        
        guard !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter a description"
            showingAlert = true
            return
        }
        
        let finalAmount = isIncome ? amountValue : -amountValue
        
        viewModel.addTransaction(
            amount: finalAmount,
            description: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            categoryName: selectedCategory,
            date: transactionDate,
            merchant: merchant.isEmpty ? nil : merchant.trimmingCharacters(in: .whitespacesAndNewlines),
            paymentMethod: paymentMethod,
            tags: tags.isEmpty ? nil : tags.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        dismiss()
    }
    
    private func formatPreviewAmount() -> String {
        guard let amountValue = Double(amount) else { return "$0.00" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        return formatter.string(from: NSNumber(value: amountValue)) ?? "$0.00"
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "food": return .orange
        case "transport": return .blue
        case "shopping": return .purple
        case "entertainment": return .pink
        case "bills": return .red
        case "healthcare": return .red
        case "education": return .blue
        case "salary", "income": return .green
        default: return .gray
        }
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "food": return "fork.knife"
        case "transport": return "car.fill"
        case "shopping": return "bag.fill"
        case "entertainment": return "tv.fill"
        case "bills": return "bolt.fill"
        case "healthcare": return "cross.fill"
        case "education": return "book.fill"
        case "salary", "income": return "dollarsign.circle.fill"
        default: return "tag.fill"
        }
    }
    
    private func iconForPaymentMethod(_ method: String) -> String {
        switch method.lowercased() {
        case "cash": return "banknote"
        case "credit card": return "creditcard"
        case "debit card": return "creditcard.fill"
        case "bank transfer": return "building.columns"
        case "paypal": return "p.circle"
        case "apple pay": return "applelogo"
        default: return "dollarsign.circle"
        }
    }
}

// MARK: - View Extensions
extension View {
    func customPlaceholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    let viewModel = TransactionViewModel(viewContext: context)
    
    return AddTransactionView(viewModel: viewModel)
}
