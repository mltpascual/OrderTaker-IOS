import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: StoreService
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var isRegistering = false
    @State private var showingForgotPassword = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var isSigningInWithGoogle = false
    
    // Map Firebase error codes to user-friendly messages
    private func handleAuthResult(_ error: Error?) {
        guard let error = error else { return }
        
        let errorCode = (error as NSError).code
        let domain = (error as NSError).domain
        
        // Check for custom success messages (email verification, password reset)
        if domain == "EmailVerificationSent" || domain == "PasswordResetSent" {
            successMessage = error.localizedDescription
            errorMessage = ""
            return
        }
        
        // Check for email verification needed (after signup) - don't show message, user will be redirected
        if domain == "EmailVerificationNeeded" {
            // User will be automatically redirected to EmailVerificationView
            return
        }
        
        // Check for email verification error (on login)
        if domain == "EmailVerificationError" {
            // User will be automatically redirected to EmailVerificationView
            return
        }
        
        // Firebase Auth error codes
        if domain == "FIRAuthErrorDomain" {
            switch errorCode {
            case 17999: // ERROR_INVALID_CUSTOM_TOKEN
                errorMessage = "Invalid email or password. Please try again."
            case 17009: // ERROR_WRONG_PASSWORD
                errorMessage = "Invalid email or password. Please try again."
            case 17008: // ERROR_INVALID_EMAIL
                errorMessage = "Invalid email format. Please check and try again."
            case 17011: // ERROR_USER_NOT_FOUND
                errorMessage = "Invalid email or password. Please try again."
            case 17007: // ERROR_EMAIL_ALREADY_IN_USE
                errorMessage = "This email is already registered. Please sign in instead."
            case 17020: // ERROR_NETWORK_REQUEST_FAILED
                errorMessage = "Connection error. Please check your internet and try again."
            case 17010: // ERROR_WEAK_PASSWORD
                errorMessage = "Password is too weak. Please use a stronger password."
            case 17026: // ERROR_TOO_MANY_REQUESTS
                errorMessage = "Too many failed attempts. Please try again later."
            default:
                // For other Firebase errors, check the message pattern
                let errorDescription = error.localizedDescription.lowercased()
                if errorDescription.contains("password") || errorDescription.contains("credential") || errorDescription.contains("malformed") || errorDescription.contains("expired") {
                    errorMessage = "Invalid email or password. Please try again."
                } else if errorDescription.contains("network") || errorDescription.contains("connection") {
                    errorMessage = "Connection error. Please check your internet and try again."
                } else {
                    errorMessage = "Something went wrong. Please try again."
                }
            }
            successMessage = ""
            return
        }
        
        // Check for common error message patterns
        let errorDescription = error.localizedDescription.lowercased()
        if errorDescription.contains("password") || errorDescription.contains("credential") || errorDescription.contains("malformed") {
            errorMessage = "Invalid email or password. Please try again."
        } else if errorDescription.contains("network") || errorDescription.contains("connection") {
            errorMessage = "Connection error. Please check your internet and try again."
        } else if errorDescription.contains("too many") {
            errorMessage = "Too many failed attempts. Please try again later."
        } else {
            errorMessage = "Something went wrong. Please try again."
        }
        successMessage = ""
    }

    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Logo / Title
            VStack(spacing: 8) {
                Text("OrderTaker")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(Theme.primary)
                
                Text("PRO EDITION")
                    .font(Theme.labelFont)
                    .foregroundColor(Theme.Slate.s400)
                    .kerning(4)
            }
            
            VStack(spacing: 20) {
                if isRegistering {
                    InputField(label: "FULL NAME", text: $fullName, placeholder: "Your Name")
                }
                
                InputField(label: "EMAIL ADDRESS", text: $email, placeholder: "hello@bakery.com")
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                VStack(alignment: .leading, spacing: 8) {
                    InputField(label: "PASSWORD", text: $password, placeholder: "••••••••", isSecure: true)
                    
                    // Forgot Password (only show when signing in) - positioned at lower right
                    if !isRegistering {
                        HStack {
                            Spacer()
                            Button(action: {
                                showingForgotPassword = true
                            }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Theme.primary)
                            }
                        }
                    }
                }
                
                // Error message
                if !errorMessage.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.danger)
                        
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.danger)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Theme.danger.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.danger.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Success message
                if !successMessage.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.primary)
                        
                        Text(successMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.Slate.s600)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Theme.primary.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.primary.opacity(0.3), lineWidth: 1)
                    )
                }
                
                PrimaryButton(title: isRegistering ? "CREATE ACCOUNT" : "SIGN IN", action: {
                    errorMessage = ""
                    successMessage = ""
                    if isRegistering {
                        store.emailSignUp(email: email, password: password, fullName: fullName) { error in
                            handleAuthResult(error)
                        }
                    } else {
                        store.emailSignIn(email: email, password: password) { error in
                            handleAuthResult(error)
                        }
                    }
                }, isDisabled: email.isEmpty || password.isEmpty || (isRegistering && fullName.isEmpty))

                
                Button(action: {
                    withAnimation {
                        isRegistering.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(isRegistering ? "Already have an account?" : "Don't have an account?")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.Slate.s600)
                        Text(isRegistering ? "Sign In" : "Sign Up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Theme.primary)
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Social Login - Google only
            VStack(spacing: 16) {
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(Theme.Slate.s400.opacity(0.3))
                    Text("OR CONTINUE WITH").font(Theme.labelFont).foregroundColor(Theme.Slate.s400)
                    Rectangle().frame(height: 1).foregroundColor(Theme.Slate.s400.opacity(0.3))
                }
                
                Button(action: {
                    signInWithGoogle()
                }) {
                    HStack(spacing: 12) {
                        if isSigningInWithGoogle {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Theme.Slate.s900))
                                .scaleEffect(0.9)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Theme.Slate.s900)
                        }
                        Text(isSigningInWithGoogle ? "Signing in..." : "Continue with Google")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.Slate.s900)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Theme.cardBackground)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.Slate.s400.opacity(0.2), lineWidth: 1)
                    )
                }
                .disabled(isSigningInWithGoogle)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Theme.background.ignoresSafeArea())
        .alert("Reset Password", isPresented: $showingForgotPassword) {
            TextField("Email address", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            Button("Send Reset Link") {
                guard !email.isEmpty else { return }
                store.sendPasswordReset(email: email) { error in
                    if let error = error {
                        handleAuthResult(error)
                    } else {
                        let successError = NSError(
                            domain: "PasswordResetSent",
                            code: 3001,
                            userInfo: [NSLocalizedDescriptionKey: "Password reset email sent! Check your inbox for instructions."]
                        )
                        handleAuthResult(successError)
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter your email address to receive a password reset link.")
        }
    }
    
    
    private func signInWithGoogle() {
        isSigningInWithGoogle = true
        errorMessage = ""
        successMessage = ""
        
        store.googleSignIn { error in
            DispatchQueue.main.async {
                self.isSigningInWithGoogle = false
                if let error = error {
                    self.handleAuthResult(error)
                }
                // If successful, user will be automatically logged in by Firebase Auth state listener
            }
        }
    }
}

struct SocialButton: View {
    let icon: String
    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Theme.Slate.s900)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Theme.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.Slate.s400.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(StoreService())
}
