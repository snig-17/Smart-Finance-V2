//
//  BiometricManager.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari on 09/08/2025.
//

import SwiftUI
import LocalAuthentication

@MainActor
class BiometricManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isSetupCompleted = false
    @Published var biometricType: LABiometryType = .none
    @Published var authenticationError: String?
    
    private let context = LAContext()
    private let setupCompletedKey = "BiometricSetupCompleted"
    
    init() {
        checkBiometricAvailability()
        loadSetupStatus()
    }
    
    // MARK: - Setup Status Management
    
    private func loadSetupStatus() {
        isSetupCompleted = UserDefaults.standard.bool(forKey: setupCompletedKey)
    }
    
    func completeSetup() {
        isSetupCompleted = true
        UserDefaults.standard.set(true, forKey: setupCompletedKey)
    }
    
    // MARK: - Biometric Availability
    
    func checkBiometricAvailability() {
        var error: NSError?
        
        // ✅ FIXED: Use correct LAPolicy
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        } else {
            biometricType = .none
            if let error = error {
                authenticationError = error.localizedDescription
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    func authenticateUser() async -> Bool {
        guard biometricType != .none else {
            authenticationError = "Biometric authentication not available"
            return false
        }
        
        let context = LAContext()
        context.localizedCancelTitle = "Use Passcode"
        context.localizedFallbackTitle = "Use Passcode"
        
        let reason = "Authenticate to access your financial data"
        
        do {
            // ✅ FIXED: Use correct LAPolicy
            let result = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            
            if result {
                isAuthenticated = true
                authenticationError = nil
                return true
            } else {
                authenticationError = "Authentication was cancelled"
                return false
            }
        } catch {
            authenticationError = error.localizedDescription
            return false
        }
    }
    
    func logout() {
        isAuthenticated = false
    }
    
    // MARK: - Computed Properties for UI
    
    var shouldShowSetup: Bool {
        return !isSetupCompleted
    }
    
    var shouldShowAuthentication: Bool {
        return isSetupCompleted && !isAuthenticated
    }
    
    var shouldShowMainApp: Bool {
        return isSetupCompleted && isAuthenticated
    }
}


