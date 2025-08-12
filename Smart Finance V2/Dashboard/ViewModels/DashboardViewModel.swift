//
//  DashboardViewModel.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari on 12/08/2025.
//

import SwiftUI
import CoreData

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var totalBalance: Double = 0.0
    @Published var balanceChange: Double = 0.0
    @Published var isLoading: Bool = false
    
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        calculateBalance()
    }
    
    func calculateBalance() {
        // Implementation for calculating balance from Core Data
        // This will be expanded when we add transaction management
    }
    
    func refreshData() {
        isLoading = true
        
        // Simulate data refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.calculateBalance()
            self.isLoading = false
        }
    }
}
