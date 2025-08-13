//
//  AnalyticsModels.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 13/08/2025.
//

import Foundation
import SwiftUI

// MARK: - data models for analytics

struct SpendingTrend {
    let date: Date
    let amount: Double
    let type: TransactionType
}

struct CategoryInsight {
    let category: String
    let totalSpent: Double
    let transactionCount: Int
    let percentage: Double
    let trend: Double
}

struct MonthlyComparison {
    let month: String
    let income: Double
    let expenses: Double
    let netFlow: Double
    let previousMonthChange: Double
}

struct FinancialInsight {
    let title: String
    let description: String
    let value: String
    let trend: InsightTrend
    let priority: InsightPriority
}

enum TransactionType {
    case income, expense
}

enum InsightTrend {
    case positive, negative, neutral
}

enum InsightPriority {
    case high, medium, low
}


