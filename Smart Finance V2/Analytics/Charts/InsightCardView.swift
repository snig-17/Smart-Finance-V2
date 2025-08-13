//
//  InsightCardView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 13/08/2025.
//

import Foundation
import SwiftUI

struct InsightCardView: View {
    let insight: FinancialInsight
    
    var body: some View {
        HStack(spacing: 12) {
            // Priority indicator
            VStack {
                Image(systemName: iconForPriority(insight.priority))
                    .font(.title2)
                    .foregroundColor(colorForTrend(insight.trend))
                
                Circle()
                    .fill(colorForPriority(insight.priority))
                    .frame(width: 8, height: 8)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(insight.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(insight.value)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(colorForTrend(insight.trend))
                }
                
                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorForPriority(insight.priority), lineWidth: 1)
                )
        )
    }
    
    private func colorForTrend(_ trend: InsightTrend) -> Color {
        switch trend {
        case .positive: return .green
        case .negative: return .red
        case .neutral: return .blue
        }
    }
    
    private func colorForPriority(_ priority: InsightPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
    
    private func iconForPriority(_ priority: InsightPriority) -> String {
        switch priority {
        case .high: return "exclamationmark.triangle.fill"
        case .medium: return "info.circle.fill"
        case .low: return "lightbulb.fill"
        }
    }
}
