//
//  ContentView.swift
//  OrderTaker
//
//  Created by Miguel Pascual on 2026-01-15.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject var store = StoreService()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Group {
            if store.isUserLoggedIn {
                // Check if email is verified
                if let currentUser = store.auth.currentUser, !currentUser.isEmailVerified {
                    EmailVerificationView()
                        .environmentObject(store)
                } else {
                    MainTabView()
                        .environmentObject(store)
                }
            } else {
                LoginView()
                    .environmentObject(store)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            store.signIn() // Starts listening to auth state
        }
    }
}

#Preview {
    ContentView()
}
