//
//  ContentView.swift
//  OrderTaker
//
//  Created by Miguel Pascual on 2026-01-15.
//

import SwiftUI

struct ContentView: View {
    @StateObject var store = StoreService()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Group {
            if store.isUserLoggedIn {
                MainTabView()
                    .environmentObject(store)
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
