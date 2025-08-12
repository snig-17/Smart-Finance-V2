//
//  RecentTransactionsSectionView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 09/08/2025.
//

import SwiftUI

struct RecentTransactionsSectionView: View {
    let transactions: [Transaction]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                // Section header
                sectionHeader
                
                // Transactions content
                if transactions.isEmpty {
                    emptyState
                } else {
                    transactionsList
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        
        // MARK: - UI Components
        
        private var sectionHeader: some View {
            HStack {
                Text("Recent Transactions")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("See All") {
                    // Navigate to full transaction list - implement later
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
        
        private var emptyState: some View {
            VStack(spacing: 12) {
                Image(systemName: "creditcard.trianglebadge.exclamationmark")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                
                Text("No transactions yet")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Add your first transaction to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
        
        private var transactionsList: some View {
            LazyVStack(spacing: 8) {
                ForEach(Array(transactions.prefix(5))) { transaction in
                    TransactionRowView(transaction: transaction)
                    
                    // Add divider between transactions (except last one)
                    if transaction != transactions.prefix(5).last {
                        Divider()
                            .padding(.leading, 52) // Align with transaction content
                    }
                }
            }
        }
    }

    // MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    // Create sample transaction with context
    let transaction = Transaction(context: context)
    transaction.id = UUID()
    transaction.merchant = "Sample Store"
    transaction.category = "Shopping"
    transaction.amount = NSDecimalNumber(value: -99.99)
    transaction.paymentMethod = "Card"
    transaction.transactionDate = Date()
    
    return VStack {
        RecentTransactionsSectionView(transactions: [transaction])
        Spacer()
        RecentTransactionsSectionView(transactions: [])
    }
    .padding()
    .background(Color(.systemGray6))
    .environment(\.managedObjectContext, context)
}
