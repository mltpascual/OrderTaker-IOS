import SwiftUI
import FirebaseAuth
import Combine

struct EmailVerificationView: View {
    @EnvironmentObject var store: StoreService
    @State private var message = ""
    @State private var isResending = false
    @State private var isChecking = false
    
    var userEmail: String {
        store.auth.currentUser?.email ?? "your email"
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Email Icon
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "envelope.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Theme.primary)
            }
            
            // Main Content
            VStack(spacing: 16) {
                Text("Verify Your Email")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(Theme.Slate.s900)
                
                Text("We sent a verification link to")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.Slate.s500)
                
                Text(userEmail)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Theme.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.primary.opacity(0.1))
                    .cornerRadius(8)
                
                Text("Click the link in the email to verify your account and continue.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.Slate.s500)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
                
                Text("Don't see the email? Check your spam or junk folder.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.Slate.s400)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 4)
            }
            
            // Message (success or error)
            if !message.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: message.contains("sent") ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(message.contains("sent") ? Theme.primary : Theme.danger)
                    
                    Text(message)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.Slate.s600)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(12)
                .background((message.contains("sent") ? Theme.primary : Theme.danger).opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke((message.contains("sent") ? Theme.primary : Theme.danger).opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 24)
            }
            
            // Action Buttons
            VStack(spacing: 12) {
                PrimaryButton(title: isChecking ? "Checking..." : "I've Verified, Continue", action: {
                    checkVerificationStatus()
                }, isDisabled: isChecking)
                
                Button(action: {
                    resendVerificationEmail()
                }) {
                    HStack(spacing: 6) {
                        if isResending {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Theme.primary))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .bold))
                        }
                        Text(isResending ? "Sending..." : "Resend Verification Email")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(Theme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.primary.opacity(0.1))
                    .cornerRadius(Theme.cornerRadius)
                }
                .disabled(isResending)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            Spacer()
            
            // Sign Out Option
            Button(action: {
                store.signOut()
            }) {
                Text("Sign Out")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Slate.s500)
            }
            .padding(.bottom, 40)
        }
        .background(Theme.background.ignoresSafeArea())
    }
    
    private func checkVerificationStatus() {
        isChecking = true
        message = ""
        
        // Reload user to get latest verification status
        store.auth.currentUser?.reload { [weak store] error in
            DispatchQueue.main.async {
                self.isChecking = false
                
                if let error = error {
                    self.message = "Error checking status: \(error.localizedDescription)"
                    return
                }
                
                if store?.auth.currentUser?.isEmailVerified == true {
                    // Email is verified! Trigger UI update
                    self.message = "Email verified! Redirecting..."
                    // Trigger objectWillChange to refresh ContentView
                    store?.objectWillChange.send()
                } else {
                    self.message = "Email not verified yet. Please check your inbox (including spam folder) and click the verification link."
                }
            }
        }
    }
    
    private func resendVerificationEmail() {
        isResending = true
        message = ""
        
        store.auth.currentUser?.sendEmailVerification { error in
            isResending = false
            
            if let error = error {
                message = "Error: \(error.localizedDescription)"
            } else {
                message = "Verification email sent! Check your inbox."
            }
        }
    }
}

#Preview {
    EmailVerificationView()
        .environmentObject(StoreService())
}
