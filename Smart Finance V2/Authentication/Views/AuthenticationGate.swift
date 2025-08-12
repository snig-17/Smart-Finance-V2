//
//  AuthenticationGate.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari on 09/08/2025.
//

import SwiftUI



struct AuthenticationGate: View {
    @StateObject private var biometricManager = BiometricManager()
    
    var body: some View {
        // ✅ FIXED: Remove Group and use direct view switching
        switch currentState {
        case .setup:
            BiometricSetupView()
                .environmentObject(biometricManager)
        case .authentication:
            BiometricAuthView()
                .environmentObject(biometricManager)
        case .authenticated:
            MainDashboardView()
                .environmentObject(biometricManager)
        }
    }
    
    private var currentState: AuthenticationState {
        if biometricManager.shouldShowSetup {
            return .setup
        } else if biometricManager.shouldShowAuthentication {
            return .authentication
        } else {
            return .authenticated
        }
    }
}

#Preview {
    AuthenticationGate()
}
