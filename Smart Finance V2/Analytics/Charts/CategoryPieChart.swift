//
//  CategoryPieChart.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 13/08/2025.
//

import Foundation
import SwiftUI
import Charts

struct CategoryPieChart: View {
    let data: [CategoryInsight]
    @State private var selectedCategory: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Spending by Category")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                // Pie Chart
                Chart(data, id: \.category) { insight in
                    SectorMark(
                        angle: .value("Percentage", insight.percentage),
                        innerRadius: .ratio(0.4),
                        angularInset: 2
                    )
                    .foregroundStyle(colorForCategory(insight.category))
                    .opacity(selectedCategory == nil || selectedCategory == insight.category ? 1.0 : 0.5)
                }
                .frame(width: 120, height: 120)
               
                
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(data.prefix(5), id: \.category) { insight in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(colorForCategory(insight.category))
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(insight.category)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                
                                Text("\(insight.percentage, specifier: "%.1f")%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("$\(insight.totalSpent, specifier: "%.0f")")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = selectedCategory == insight.category ? nil : insight.category
                            }
                        }
                    }
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
    
    private func colorForCategory(_ category: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .yellow]
        let hash = category.hashValue
        return colors[abs(hash) % colors.count]
    }
}
