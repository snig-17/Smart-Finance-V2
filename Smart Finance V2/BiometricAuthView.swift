//
//  BiometricAuthView.swift
//  Smart Finance V2
//
//  Created by Snigdha Tiwari  on 09/08/2025.
//

import SwiftUI

struct BiometricAuthView: View {
    @ObservedObject var biometricManager: BiometricManager
    @State private var isAuthenticating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                appBrandingSection
                authenticationSection
                if showError {
                    errorMessageView
                }
                Spacer()
                Spacer()
            }
            .padding()
        }
        .onAppear {
            Task {
               // await performAuthentication()
            }
        }
    }
    // MARK: - UI components
    
    private var appBrandingSection: some View {
        VStack(spacing: 16){
            Image(systemName: "banknote.fill")
                .font(.system(size:80))
                .foregroundColor(.white)
                .background(
                    Circle().fill(Color.white.opacity(0.2))
                            .frame(width: 120, height: 120))
                
            Text("SmartFinance")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("Your Personal Finance Companion") .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        
    }
    private var authenticationSection: some View {
        VStack(spacing: 24) {
            //biometric icon
            Image(systemName: biometricManager.biometricType.iconName)
                .font(.system(size: 50))
                .foregroundColor(.white)
                .frame(width:80, height: 80)
                .background(
                    Circle().fill(Color.white.opacity(0.2))
                )
                .scaleEffect(isAuthenticating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(), value: isAuthenticating)
            
            VStack(spacing: 8) {
                Text("Authenticate to Continue")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Use \(biometricManager.biometricType.displayName) to access your account")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            authenticationButtons
        }
    }
    private var authenticationButtons: some View {
        VStack(spacing: 16){
            // primary authentication button
            Button(action: {
                Task {
                    await performAuthentication()
                }
            }) {
                HStack {
                    if isAuthenticating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue)).scaleEffect(0.8)
                    } else {
                        Image(systemName: biometricManager.biometricType.iconName).font(.title3)
                    }
                    
                    Text(isAuthenticating ? "Authenticating..." : "Authenticate with \(biometricManager.biometricType.displayName)").font(.headline)
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
            .disabled(isAuthenticating || biometricManager.biometricType == .none)
            
            // fallback to passcode button
            if biometricManager.biometricType != .passcode && biometricManager.biometricType != .none {
                Button(action: {
                    Task {
                        await authenticateWithPasscode()
                    }
                }) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .font(.title3)
                        Text("Use Passcode")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
                .disabled(isAuthenticating)
            }
        }
        .padding(.horizontal)
    }
    
    private var errorMessageView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                Text("Authentication Failed")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            Text(errorMessage)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.red.opacity(0.3))
        .cornerRadius(12)
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - authentication methods
    
    private func performAuthentication() async {
            await MainActor.run {
                isAuthenticating = true
                showError = false
            }
            
            let success: Bool
            
            if biometricManager.biometricType == .passcode {
                success = await biometricManager.authenticateWithPasscode()
            } else {
                success = await biometricManager.authenticateWithBiometric()
            }
            
            await MainActor.run {
                isAuthenticating = false
                
                if !success {
                    handleAuthenticationFailure()
                }
            }
        }
        
        private func authenticateWithPasscode() async {
            await MainActor.run {
                isAuthenticating = true
                showError = false
            }
            
            let success = await biometricManager.authenticateWithPasscode()
            
            await MainActor.run {
                isAuthenticating = false
                
                if !success {
                    handleAuthenticationFailure()
                }
            }
        }
        
        private func handleAuthenticationFailure() {
            switch biometricManager.authenticationState {
            case .failed(let message):
                errorMessage = message
                showError = true
                
                // Auto-hide error after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showError = false
                }
            default:
                break
            }
        }
}

// MARK: - Preview
#Preview {
    BiometricAuthView(biometricManager: BiometricManager())
}
