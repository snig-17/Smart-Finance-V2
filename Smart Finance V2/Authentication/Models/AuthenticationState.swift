//
//  AuthenticationState.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari on 12/08/2025.
//

import Foundation

enum AuthenticationState {
    case setup
    case authentication
    case authenticated
}

enum BiometricAuthenticationError: Error, LocalizedError {
    case notAvailable
    case notEnrolled
    case authenticationFailed(String)
    case userCancel
    case systemCancel
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available on this device"
        case .notEnrolled:
            return "No biometric authentication is enrolled. Please set up Face ID or Touch ID in Settings"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .userCancel:
            return "Authentication was cancelled by user"
        case .systemCancel:
            return "Authentication was cancelled by system"
        }
    }
}
