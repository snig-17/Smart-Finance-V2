//
//  LABiometryType+Extensions.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari on 12/08/2025.
//

import LocalAuthentication

extension LABiometryType {
    var displayName: String {
        switch self {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .none:
            return "None"
        @unknown default:
            return "Unknown"
        }
    }
    
    var iconName: String {
        switch self {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .none:
            return "lock.fill"
        @unknown default:
            return "lock.fill"
        }
    }
}
