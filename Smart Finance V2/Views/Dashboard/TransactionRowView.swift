//
//  TransactionSectionView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 09/08/2025.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    var body: some View {
        HStack(spacing: 12){
           categoryIcon
            
            VStack(alignment: .leading, spacing: 4){
                Text(transaction.merchant ?? "Unknown Merchant")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(transaction.category ?? "Uncategorised")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            //amount
            VStack(alignment: .trailing, spacing: 4) {
                            Text(formattedAmount)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(amountColor)
                            
                            Text(transaction.paymentMethod ?? "Unknown")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
        }
        .padding(.vertical, 8)
    }
    
    private var categoryIcon : some View {
        Image(systemName: categoryIconName)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(categoryColor)
                    .clipShape(Circle())
    }
    private var categoryIconName: String {
            switch transaction.category?.lowercased() ?? "" {
            case "food & dining", "food":
                return "fork.knife"
            case "transportation":
                return "car.fill"
            case "shopping":
                return "bag.fill"
            case "entertainment":
                return "tv.fill"
            case "bills & utilities":
                return "house.fill"
            case "healthcare":
                return "cross.fill"
            default:
                return "questionmark"
            }
        }
    private var categoryColor: Color {
           switch transaction.category?.lowercased() ?? "" {
           case "food & dining", "food":
               return .orange
           case "transportation":
               return .blue
           case "shopping":
               return .purple
           case "entertainment":
               return .pink
           case "bills & utilities":
               return .green
           case "healthcare":
               return .red
           default:
               return .gray
           }
       }
    private var formattedAmount: String {
            let amount = transaction.amount?.doubleValue ?? 0
            return String(format: "$%.2f", abs(amount))
        }
        
        private var amountColor: Color {
            let amount = transaction.amount?.doubleValue ?? 0
            return amount >= 0 ? .green : .red
        }
        
        private var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: transaction.transactionDate ?? Date())
        }
    }
    


#Preview {
    VStack {
        TransactionRowView(transaction: {
                let transaction = Transaction()
                transaction.merchant = "Coffee Shop"
                transaction.category = "Food & Dining"
                transaction.amount = NSDecimalNumber(value: -25.99)
                transaction.paymentMethod = "Card"
                transaction.transactionDate = Date()
                return transaction
            }())
            
            Divider()
            
        TransactionRowView(transaction: {
                let transaction = Transaction()
                transaction.merchant = "Gas Station"
                transaction.category = "Transportation"
                transaction.amount = NSDecimalNumber(value: -45.00)
                transaction.paymentMethod = "Card"
                transaction.transactionDate = Date()
                return transaction
            }())
        }
        .padding()
}
