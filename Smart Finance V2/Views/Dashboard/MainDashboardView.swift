//
//  MainDashboardView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 09/08/2025.
//

import SwiftUI
import CoreData

struct MainDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var biometricManager: BiometricManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.transactionDate, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>
    
    @State private var showingAddTransactionView = false
    @State private var showingSettings = false

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
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Debug section (remove in production)
                    debugSection
                    balanceCard
                    recentTransactions
                    quickStatsSection
                }
                .padding()
            }
            .navigationTitle("Smart Finance")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(biometricManager)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    // Debug section
    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🔍 MAIN DASHBOARD DEBUG:")
                .font(.headline)
                .foregroundColor(.blue)
            
            Text("Setup Completed: \(biometricManager.isSetupCompleted ? "✅ YES" : "❌ NO")")
                .font(.caption)
            
            Text("Is Authenticated: \(biometricManager.isAuthenticated ? "✅ YES" : "❌ NO")")
                .font(.caption)
            
            Text("Biometric Type: \(biometricManager.biometricType.displayName)")
                .font(.caption)
            
            if let error = biometricManager.authenticationError {
                Text("Error: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
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
        .environmentObject(BiometricManager())
}
