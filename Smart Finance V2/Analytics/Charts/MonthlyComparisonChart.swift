//
//  MonthlyComparisonChart.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 13/08/2025.
//

import Foundation
import SwiftUI
import Charts

struct MonthlyComparisonChart: View {
    let data: [MonthlyComparison]
    @State private var showIncome = true
    @State private var showExpenses = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with toggles
            HStack {
                Text("Monthly Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Toggle("Income", isOn: $showIncome)
                        .toggleStyle(ChartToggleStyle(color: .green))
                    
                    Toggle("Expenses", isOn: $showExpenses)
                        .toggleStyle(ChartToggleStyle(color: .red))
                }
            }
            
            // Chart
            Chart {
                ForEach(data, id: \.month) { comparison in
                    if showIncome {
                        BarMark(
                            x: .value("Month", comparison.month),
                            y: .value("Income", comparison.income)
                        )
                        .foregroundStyle(.green)
                        .position(by: .value("Type", "Income"))
                    }
                    
                    if showExpenses {
                        BarMark(
                            x: .value("Month", comparison.month),
                            y: .value("Expenses", comparison.expenses)
                        )
                        .foregroundStyle(.red)
                        .position(by: .value("Type", "Expenses"))
                    }
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .currency(code: "USD"))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// Custom toggle style for chart legends
struct ChartToggleStyle: ToggleStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(configuration.isOn ? color : Color.gray)
                .frame(width: 8, height: 8)
            
            configuration.label
                .font(.caption)
                .foregroundColor(configuration.isOn ? .primary : .secondary)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                configuration.isOn.toggle()
            }
        }
    }
}
