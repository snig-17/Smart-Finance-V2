//
//  SpendingTrendChart.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 13/08/2025.
//

import SwiftUI
import Charts

import SwiftUI
import Charts

struct SpendingTrendChart: View {
    let data: [SpendingTrend]
    @State private var selectedDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Chart Header - FIXED: Separated into its own computed property
            chartHeader
            
            // Chart
            Chart(data, id: \.date) { trend in
                LineMark(
                    x: .value("Date", trend.date),
                    y: .value("Amount", trend.amount)
                )
                .foregroundStyle(trend.type == .expense ? .red : .green)
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                // Area fill for expenses
                if trend.type == .expense {
                    AreaMark(
                        x: .value("Date", trend.date),
                        y: .value("Amount", trend.amount)
                    )
                    .foregroundStyle(expenseGradient)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
        }
        .padding()
        .background(cardBackground)
    }
    
    // MARK: - Computed Properties to Fix Compiler Complexity
    
    private var chartHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Spending Trends")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let selectedDate = selectedDate {
                selectedDateText
            }
        }
    }
    
    private var selectedDateText: some View {
        Group {
            if let selectedTrend = data.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate!) }) {
                Text("$\(selectedTrend.amount, specifier: "%.2f") on \(selectedDate!, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var expenseGradient: LinearGradient {
        LinearGradient(
            colors: [.red.opacity(0.3), .red.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemGray6))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

