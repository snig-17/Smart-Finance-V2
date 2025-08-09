//
//  MainDashboardView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 09/08/2025.
//

import SwiftUI
import CoreData

struct MainDashboardView: View {
    //connect to coredata
    @Environment(\.managedObjectContext) private var viewContext
    //fetch transactions from database
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.transactionDate, ascending: false)], animation: .default)
    private var transactions: FetchedResults<Transaction>
    // state for showing add transactions
    @State private var showingAddTransactionView = false
    // MARK: - Computed Properties
    private var totalBalance: Double {
        transactions.reduce(0) { total, transaction in
            let amount = transaction.amount?.doubleValue ?? 0
            return total + amount
        }
    }

    private var balanceChange: Double {
        245.67 // Mock data
    }

    // MARK: - UI Components
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(spacing: 20){
                        balanceCard
                        recentTransactions
                        quickStatsSection
                    
                }
                .padding()
            }
            .navigationTitle("Smart Finance")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                        addButton
                }
            }
        }
    }
    
}

extension MainDashboardView {
    private var balanceCard: some View {
        BalanceCardSectionView(totalBalance: totalBalance, balanceChange: balanceChange)
    }
    private var recentTransactions: some View {
        RecentTransactionsSectionView(transactions: Array(transactions))
    }
    private var quickStatsSection : some View {
        Text("Stats (coming soon...)")
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
    }
    private var addButton : some View {
        Button(action: addTransaction) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)
        }
    }
    private func addTransaction() {
        print("Add transaction tapped")
    }
}
// MARK: - Preview
    #Preview {
        MainDashboardView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
