//
//  BiometricSetupView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari on 09/08/2025.
//

import SwiftUI

struct BiometricSetupView: View {
    @EnvironmentObject var biometricManager: BiometricManager // ✅ FIXED: Use EnvironmentObject
    @State private var isSettingUp = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.green, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                welcomeSection
                setupSection
                
                if showError {
                    errorMessageView
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - UI Components
    
    private var welcomeSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "banknote.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
            
            Text("Welcome to SmartFinance!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Your Personal Finance Companion")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
    
    private var setupSection: some View {
        VStack(spacing: 25) {
            // Security icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isSettingUp ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isSettingUp)
                
                Image(systemName: biometricManager.biometricType.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 15) {
                Text("Secure Your Financial Data")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Set up \(biometricManager.biometricType.displayName) to protect your personal financial information with the highest level of security.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 15) {
                // Security features
                securityFeatureRow(icon: "lock.shield", text: "Bank-level security")
                securityFeatureRow(icon: "eye.slash", text: "Your data never leaves your device")
                securityFeatureRow(icon: "checkmark.shield", text: "Required every time you open the app")
            }
            
            // Setup button
            Button(action: {
                Task {
                    await setupBiometric()
                }
            }) {
                HStack {
                    if isSettingUp {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: biometricManager.biometricType.iconName)
                            .font(.title3)
                    }
                    
                    Text(isSettingUp ? "Setting up..." : "Set up \(biometricManager.biometricType.displayName)")
                        .font(.headline)
                }
                .foregroundColor(.green)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .disabled(isSettingUp || biometricManager.biometricType == .none)
            .padding(.horizontal)
        }
    }
    
    private func securityFeatureRow(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 24)
            
            Text(text)
                .foregroundColor(.white.opacity(0.9))
                .font(.subheadline)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private var errorMessageView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("Setup Failed")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text(errorMessage)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await setupBiometric()
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.2))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.red.opacity(0.2))
        .cornerRadius(12)
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Actions
    
    private func setupBiometric() async {
        await MainActor.run {
            isSettingUp = true
            showError = false
        }
        
        // ✅ FIXED: Use the correct method
        let success = await biometricManager.authenticateUser()
        
        await MainActor.run {
            isSettingUp = false
            
            if success {
                // Complete the setup
                biometricManager.completeSetup()
            } else {
                handleSetupFailure()
            }
        }
    }
    
    private func handleSetupFailure() {
        errorMessage = biometricManager.authenticationError ?? "Setup failed. Please try again."
        showError = true
        
        // Auto-hide error after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            showError = false
        }
    }
}

// MARK: - Preview
#Preview {
    BiometricSetupView()
        .environmentObject(BiometricManager()) // ✅ FIXED: Use environmentObject
}
