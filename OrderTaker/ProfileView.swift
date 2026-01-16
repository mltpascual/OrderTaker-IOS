import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: StoreService
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Circle()
                        .fill(Theme.primary.opacity(0.1))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundColor(Theme.primary)
                        )
                    
                    VStack(spacing: 4) {
                        Text(store.currentUser?.fullName ?? "User")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Theme.Slate.s900)
                        
                        Text(store.currentUser?.email ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.Slate.s500)
                    }
                }
                .padding(.top, 40)
                
                // Menu Items
                VStack(spacing: 0) {
                    ProfileMenuItem(icon: "person.circle", title: "Account Settings", action: {})
                    Divider().padding(.leading, 60)
                    ProfileMenuItem(icon: "bell", title: "Notifications", action: {})
                    Divider().padding(.leading, 60)
                    ProfileMenuItem(icon: "questionmark.circle", title: "Help & Support", action: {})
                    Divider().padding(.leading, 60)
                    ProfileMenuItem(icon: "info.circle", title: "About", action: {})
                }
                .background(Theme.cardBackground)
                .cornerRadius(16)
                .padding(.horizontal, 24)
                
                // Sign Out Button
                Button(action: { store.signOut() }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 16, weight: .bold))
                        Text("Sign Out")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.danger)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
            }
            .padding(.bottom, 100)
        }
        .background(Theme.background.ignoresSafeArea())
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Theme.primary)
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.Slate.s900)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Slate.s400)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(StoreService())
}
