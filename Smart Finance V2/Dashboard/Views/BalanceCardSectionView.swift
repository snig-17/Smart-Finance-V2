//
//  BalanceCardSectionView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 09/08/2025.
//

import SwiftUI
import CoreData

struct BalanceCardSectionView: View {
    let totalBalance: Double
    let balanceChange: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            // header with greeting and settings
            HStack {
                VStack(alignment:.leading, spacing: 4){
                    Text("Good Morning")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Text("Your Balance")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(action: {}){
                    Image(systemName: "gear")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            // main balance display
            HStack (alignment: .center, spacing: 8){
                Text("$")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                Text("\(totalBalance, specifier: "%.2f")")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                
            }
            // balance change indicator
            HStack (spacing: 6){
                Image(systemName: balanceChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption)
                    .foregroundColor(balanceChange >= 0 ? .green : .red)
                Text("\(abs(balanceChange), specifier: "%.2f") from last month")
                    .font(.caption)
                    .foregroundColor(.white)
                
            }
            // quick actions menu
            HStack(spacing: 16){
                quickActionButton("Add Money", icon: "plus.circle.fill", color: .green)
                quickActionButton("Send", icon: "arrow.up.circle.fill", color: .green)
                quickActionButton("Request", icon: "arrow.down.circle.fill", color: .green)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
       
    }
    // function for quick action buttons
        private func quickActionButton(_ title: String, icon: String, color: Color) -> some View {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
        }
}

#Preview {
    BalanceCardSectionView(totalBalance: 500, balanceChange: 40)
}
