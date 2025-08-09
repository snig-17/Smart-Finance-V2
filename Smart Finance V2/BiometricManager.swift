//
//  BiometricManager.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari on 09/08/2025.
//

import LocalAuthentication
import SwiftUI

// MARK: - biometric types

enum BiometricType {
    case touchID
    case faceID
    case none
    case passcode
    
    var displayName: String {
        switch self {
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        case .none:
            return "None"
        case .passcode:
            return "Passcode"
        }
    }
    
    var iconName: String {
        switch self {
        case .touchID:
            return "touchid"
        case .faceID:
            return "faceid"
        case .none:
            return "xmark.circle"
        case .passcode:
            return "lock"
        }
    }
}

// MARK: - authentication states

enum AuthenticationState {
    case authenticated
    case unauthenticated
    case unavailable
    case failed(String)
}

// MARK: - biometric manager

@MainActor
class BiometricManager: ObservableObject {
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var biometricType: BiometricType = .none
    
    private let context = LAContext()
    private let reason = "Authenticate to access Smart Finance App"
    
    init(){
        checkBiometricAvailability()
    }
    
    // MARK: - biometric availability check
    
    func checkBiometricAvailability() {
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            //determine biometric type
            switch context.biometryType {
            case .faceID:
                biometricType = .faceID
            case .touchID:
                biometricType = .touchID
           default :
                biometricType = .none
            }
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            biometricType = .passcode
        } else {
            biometricType = .none
            authenticationState = .unavailable
        }
    }
    
    // MARK: - authentication methods
    
    func authenticateWithBiometric() async -> Bool {
        guard biometricType != .none else {
            await MainActor.run {
                authenticationState = .unavailable
            }
            return false
        }
        
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason
            )
            
            await MainActor.run {
                if success {
                    authenticationState = .authenticated
                } else {
                    authenticationState = .failed("Authentication failed")
                }
            }
            
            return success
        } catch let error as LAError {
            await MainActor.run {
                authenticationState = .failed(handleAuthenticationError(error))
            }
            return false
        } catch {
            await MainActor.run {
                authenticationState = .failed("Unknown error occurred")
            }
            return false
        }
    }
    
    func authenticateWithPasscode() async -> Bool {
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason
            )
            
            await MainActor.run {
                if success {
                    authenticationState = .authenticated
                } else {
                    authenticationState = .failed("Authentication failed")
                }
            }
            
            return success
        } catch let error as LAError {
            await MainActor.run {
                authenticationState = .failed(handleAuthenticationError(error))
            }
            return false
        } catch {
            await MainActor.run {
                authenticationState = .failed("Unknown error occurred")
            }
            return false
        }
    }
    
    // MARK: - error handling
    private func handleAuthenticationError(_ error: LAError) -> String {
            switch error.code {
            case .biometryNotAvailable:
                return "Biometric authentication is not available"
            case .biometryNotEnrolled:
                return "No biometric authentication is enrolled"
            case .biometryLockout:
                return "Biometric authentication is locked out"
            case .userCancel:
                return "Authentication was cancelled"
            case .userFallback:
                return "User chose to use passcode"
            case .systemCancel:
                return "System cancelled authentication"
            case .passcodeNotSet:
                return "Passcode is not set on device"
            case .touchIDNotAvailable:
                return "Touch ID is not available"
            case .touchIDNotEnrolled:
                return "Touch ID is not enrolled"
            case .touchIDLockout:
                return "Touch ID is locked out"
            case .invalidContext:
                return "Authentication context is invalid"
            case .notInteractive:
                return "Authentication is not interactive"
            default:
                return "Authentication failed: \(error.localizedDescription)"
            }
        }
    // MARK: - session management
    func logout() {
           authenticationState = .unauthenticated
           // Invalidate current context for security
           context.invalidate()
       }
       
       func isAuthenticated() -> Bool {
           switch authenticationState {
           case .authenticated:
               return true
           default:
               return false
           }
       }
    // MARK: - settings support
    func getBiometricStatusMessage() -> String {
            switch biometricType {
            case .none:
                return "Biometric authentication not available"
            case .faceID:
                return "Face ID available"
            case .touchID:
                return "Touch ID available"
            case .passcode:
                return "Passcode authentication available"
            }
        }
}
