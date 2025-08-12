//
//  TransactionModel.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 12/08/2025.
//

import Foundation

struct TransactionModel {
    let id: UUID
    var amount: Double
    var transaction: String
    var date: Date
    var categoryName: String
    
    // MARK: - computed properties
    
    var isIncome: Bool {
        return amount > 0
    }
    var isExpense: Bool {
        return amount < 0
    }
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: abs(amount))) ?? "$0.00"
    }

}
