//
//  ContentView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 09/08/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
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
                        balanceCardSection
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

extension ContentView {
    private var balanceCardSection : some View {
        Text("Balance Card (coming soon...)")
            .frame(height:100)
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
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
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
