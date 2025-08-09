//
//  BiometricSettingsView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari on 09/08/2025.
//

import SwiftUI

struct BiometricSettingsView: View {
    @EnvironmentObject var biometricManager: BiometricManager
    @AppStorage("biometricEnabled") private var biometricEnabled = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Biometric status info
                    biometricStatusView
                    
                    // Toggle control
                    biometricToggleView
                    
                } header: {
                    Text("Biometric Authentication")
                } footer: {
                    Text("When enabled, you'll need to authenticate with \(biometricManager.biometricType.displayName) each time you open the app to protect your financial data.")
                }
                
                Section {
                    // Additional security info
                    securityInfoView
                } header: {
                    Text("Security Information")
                }
            }
            .navigationTitle("Security Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Authentication Required", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                biometricManager.checkBiometricAvailability()
            }
        }
    }
    
    // MARK: - UI Components
    
    private var biometricStatusView: some View {
        HStack {
            Image(systemName: biometricManager.biometricType.iconName)
                .font(.title2)
                .foregroundColor(biometricManager.biometricType == .none ? .gray : .blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Authentication Method")
                    .font(.headline)
                
                Text(biometricManager.getBiometricStatusMessage())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var biometricToggleView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Enable Biometric Authentication")
                    .font(.headline)
                
                Text(biometricEnabled ? "Enabled" : "Disabled")
                    .font(.subheadline)
                    .foregroundColor(biometricEnabled ? .green : .secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $biometricEnabled)
                .disabled(biometricManager.biometricType == .none)
                .onChange(of: biometricEnabled) { _, newValue in
                    handleBiometricToggle(newValue)
                }
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
                title: "App Security",
                description: "Authentication is required each time you open the app"
            )
            
            Divider()
            
            securityInfoRow(
                icon: "key.fill",
                title: "Fallback Protection",
                description: "Use your device passcode if biometrics are unavailable"
            )
        }
        .padding(.vertical, 8)
    }
    
    private func securityInfoRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
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
    
    // MARK: - Actions
    
    private func handleBiometricToggle(_ isEnabled: Bool) {
        if isEnabled && biometricManager.biometricType == .none {
            // Can't enable if no biometric available
            biometricEnabled = false
            alertMessage = "Biometric authentication is not available on this device. Please set up Face ID or Touch ID in your device settings."
            showingAlert = true
        } else if isEnabled {
            // Enabling biometric authentication
            Task {
                let success = await testBiometricAuthentication()
                await MainActor.run {
                    if !success {
                        biometricEnabled = false
                        alertMessage = "Authentication failed. Please try again or check your biometric settings."
                        showingAlert = true
                    }
                }
            }
        }
        // If disabling, no additional action needed
    }
    
    private func testBiometricAuthentication() async -> Bool {
        // Test authentication when enabling
        if biometricManager.biometricType == .passcode {
            return await biometricManager.authenticateWithPasscode()
        } else {
            return await biometricManager.authenticateWithBiometric()
        }
    }
}

// MARK: - Preview
#Preview {
    BiometricSettingsView()
        .environmentObject(BiometricManager())
}
