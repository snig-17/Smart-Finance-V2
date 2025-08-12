//
//  Smart_Finance_V2App.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 09/08/2025.
//

import SwiftUI

@main
struct Smart_Finance_V2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
