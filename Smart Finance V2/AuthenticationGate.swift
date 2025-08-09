//
//  AuthenticationGate.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 09/08/2025.
//


import SwiftUI

struct AuthenticationGate<Content: View>: View {
    @StateObject private var biometricManager = BiometricManager()
    @AppStorage("biometricEnabled") private var biometricEnabled = false
    @State private var showingAuthenticationView = false
    
    let content: Content
    
    init(@ViewBuilder content: @escaping () -> Content){
        self.content = content()
    }
    
    var body: some View {
        Group {
            if biometricEnabled && !biometricManager.isAuthenticated(){
                BiometricAuthView(biometricManager: biometricManager)
            } else {
                // show main app content
                content
                    .environmentObject(biometricManager)
            }
        }
        .onAppear {
            checkAuthenticationNeeded()
        }
        .onChange(of: biometricEnabled) {_, newValue in
            if newValue && !biometricManager.isAuthenticated(){
                biometricManager.logout()
            }
        }
    }
    
    private func checkAuthenticationNeeded(){
        if biometricEnabled && !biometricManager.isAuthenticated(){
            biometricManager.logout()
        }
    }
}

// MARK: - preview

#Preview {
    AuthenticationGate{
        MainDashboardView()
    }
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}
