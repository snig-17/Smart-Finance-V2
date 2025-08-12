//
//  BiometricAuthView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari on 09/08/2025.
//

import SwiftUI

struct BiometricAuthView: View {
    @EnvironmentObject var biometricManager: BiometricManager // ✅ Use EnvironmentObject
    @State private var isAuthenticating = false
    @State private var showError = false
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App branding
                appBrandingSection
                
                // Authentication section
                authenticationSection
                
                // Error message
                if showError {
                    errorMessageView
                }
                
                Spacer()
                
                // Footer
                footerSection
            }
            .padding()
        }
        .onAppear {
            // Auto-authenticate when view appears
            Task {
                await authenticateUser()
            }
        }
    }
    
    // MARK: - UI Components
    
    private var appBrandingSection: some View {
        VStack(spacing: 16) {
            // App icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "banknote.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            Text("SmartFinance")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Welcome back!")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private var authenticationSection: some View {
        VStack(spacing: 30) {
            // Biometric icon with pulse animation
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    .opacity(pulseAnimation ? 0.3 : 0.6)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: biometricManager.biometricType.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .onAppear {
                pulseAnimation = true
            }
            
            VStack(spacing: 16) {
                Text("Authentication Required")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Use \(biometricManager.biometricType.displayName) to access your financial data")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Authentication button
            Button(action: {
                Task {
                    await authenticateUser()
                }
            }) {
                HStack(spacing: 12) {
                    if isAuthenticating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: biometricManager.biometricType.iconName)
                            .font(.title3)
                    }
                    
                    Text(isAuthenticating ? "Authenticating..." : "Authenticate with \(biometricManager.biometricType.displayName)")
                        .font(.headline)
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .disabled(isAuthenticating || biometricManager.biometricType == .none)
            .padding(.horizontal)
        }
    }
    
    private var errorMessageView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("Authentication Failed")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text(biometricManager.authenticationError ?? "Please try again")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await authenticateUser()
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
    
    private var footerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "lock.shield")
                    .foregroundColor(.white.opacity(0.6))
                Text("Your financial data is protected")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text("Biometric data never leaves your device")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
    }
    
    // MARK: - Actions
    
    private func authenticateUser() async {
        await MainActor.run {
            isAuthenticating = true
            showError = false
        }
        
        let success = await biometricManager.authenticateUser()
        
        await MainActor.run {
            isAuthenticating = false
            
            if !success {
                showError = true
                
                // Auto-hide error after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showError = false
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    BiometricAuthView()
        .environmentObject(BiometricManager())
}
