//
//  ContentView.swift
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
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(spacing: 20){
                        balanceCard
                        recentTransactionSection
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
        BalanceCardSectionView(totalBalance: 50, balanceChange: 100)
    }
    private var recentTransactionSection : some View {
        Text("Transactions (coming soon...)")
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
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

    #Preview {
        MainDashboardView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
