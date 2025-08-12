//
//  BiometricSettingsView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari on 09/08/2025.
//

import SwiftUI
import LocalAuthentication

struct BiometricSettingsView: View {
    @EnvironmentObject var biometricManager: BiometricManager
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var testResult: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    biometricStatusView
                    mandatorySecurityInfo
                } header: {
                    Text("Biometric Authentication")
                } footer: {
                    Text("Biometric authentication is mandatory and cannot be disabled. This ensures maximum security for your financial data.")
                }
                
                Section {
                    testAuthenticationButton
                    if !testResult.isEmpty {
                        testResultView
                    }
                } header: {
                    Text("Authentication Test")
                } footer: {
                    Text("Test your biometric authentication to ensure it's working properly.")
                }
                
                Section {
                    securityInfoView
                } header: {
                    Text("Security Information")
                }
                
                // Debug section for development
                Section {
                    debugInfoView
                } header: {
                    Text("System Information")
                }
            }
            .navigationTitle("Security Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Authentication Test", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - UI Components
    
    private var biometricStatusView: some View {
        HStack {
            Image(systemName: biometricManager.biometricType.iconName)
                .font(.title2)
                .foregroundColor(biometricManager.biometricType == .none ? .gray : .green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Authentication Method")
                    .font(.headline)
                
                Text(biometricStatusMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status indicator
            Text("REQUIRED")
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .foregroundColor(.green)
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
    
    private var mandatorySecurityInfo: some View {
        HStack {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Mandatory Security")
                    .font(.headline)
                
                Text("Biometric authentication cannot be disabled for your protection")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var testAuthenticationButton: some View {
        Button(action: testAuthentication) {
            HStack {
                Image(systemName: "checkmark.shield")
                    .foregroundColor(.blue)
                Text("Test Biometric Authentication")
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .disabled(biometricManager.biometricType == .none)
    }
    
    private var testResultView: some View {
        HStack {
            Image(systemName: testResult.contains("Success") ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(testResult.contains("Success") ? .green : .red)
            Text(testResult)
                .font(.subheadline)
                .foregroundColor(testResult.contains("Success") ? .green : .red)
        }
        .padding(.vertical, 4)
    }
    
    private var securityInfoView: some View {
        VStack(alignment: .leading, spacing: 16) {
            securityInfoRow(
                icon: "lock.shield",
                title: "Local Authentication",
                description: "Your biometric data never leaves your device"
            )
            
            Divider()
            
            securityInfoRow(
                icon: "checkmark.shield",
                title: "Always Required",
                description: "Authentication is required each time you open the app"
            )
            
            Divider()
            
            securityInfoRow(
                icon: "shield.checkered",
                title: "Maximum Security",
                description: "Mandatory biometrics provide the highest level of protection"
            )
            
            Divider()
            
            securityInfoRow(
                icon: "key.fill",
                title: "Fallback Protection",
                description: "Use your device passcode if biometrics are temporarily unavailable"
            )
        }
        .padding(.vertical, 8)
    }
    
    private var debugInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            debugInfoRow(title: "Biometric Type", value: biometricManager.biometricType.displayName)
            debugInfoRow(title: "Setup Completed", value: biometricManager.isSetupCompleted ? "Yes" : "No")
            debugInfoRow(title: "Currently Authenticated", value: biometricManager.isAuthenticated ? "Yes" : "No")
            
            if let error = biometricManager.authenticationError {
                debugInfoRow(title: "Last Error", value: error)
                    .foregroundColor(.red)
            }
        }
        .font(.caption)
        .foregroundColor(.secondary)
    }
    
    private func securityInfoRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private func debugInfoRow(title: String, value: String) -> some View {
        HStack {
            Text("\(title):")
                .fontWeight(.medium)
            Spacer()
            Text(value)
        }
    }
    
    // MARK: - Computed Properties
    
    private var biometricStatusMessage: String {
        switch biometricManager.biometricType {
        case .faceID:
            return "Face ID Authentication Active"
        case .touchID:
            return "Touch ID Authentication Active"
        case .none:
            return "Biometric authentication not available"
        @unknown default:
            return "Unknown biometric type"
        }
    }
    
    // MARK: - Actions
    
    private func testAuthentication() {
        testResult = "Testing..."
        
        Task {
            let success = await biometricManager.authenticateUser()
            
            await MainActor.run {
                if success {
                    testResult = "✅ Authentication successful!"
                    alertMessage = "Biometric authentication is working correctly!"
                } else {
                    testResult = "❌ Authentication failed"
                    alertMessage = biometricManager.authenticationError ?? "Authentication failed. Please try again."
                }
                showingAlert = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    BiometricSettingsView()
        .environmentObject(BiometricManager())
}
