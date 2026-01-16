import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: StoreService
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var isRegistering = false
    @State private var errorMessage = ""
    
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
                
                InputField(label: "PASSWORD", text: $password, placeholder: "••••••••", isSecure: true)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(Theme.danger)
                }
                
                PrimaryButton(title: isRegistering ? "CREATE ACCOUNT" : "SIGN IN", action: {
                    errorMessage = ""
                    if isRegistering {
                        store.emailSignUp(email: email, password: password, fullName: fullName) { error in
                            if let error = error { errorMessage = error.localizedDescription }
                        }
                    } else {
                        store.emailSignIn(email: email, password: password) { error in
                            if let error = error { errorMessage = error.localizedDescription }
                        }
                    }
                }, isDisabled: email.isEmpty || password.isEmpty || (isRegistering && fullName.isEmpty))
                
                Button(action: {
                    withAnimation {
                        isRegistering.toggle()
                    }
                }) {
                    Text(isRegistering ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.Slate.s600)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Social Login Dummy
            VStack(spacing: 16) {
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(Theme.Slate.s400.opacity(0.3))
                    Text("OR CONTINUE WITH").font(Theme.labelFont).foregroundColor(Theme.Slate.s400)
                    Rectangle().frame(height: 1).foregroundColor(Theme.Slate.s400.opacity(0.3))
                }
                
                HStack(spacing: 20) {
                    SocialButton(icon: "apple.logo")
                    SocialButton(icon: "person.crop.circle.fill") // Google symbol placeholder
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Theme.background.ignoresSafeArea())
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
