//
//  ContentView.swift
//  OrderTaker
//
//  Created by Miguel Pascual on 2026-01-15.
//

import SwiftUI

struct ContentView: View {
    @StateObject var store = StoreService()
    
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
        .onAppear {
            store.signIn() // Starts listening to auth state
        }
    }
}

#Preview {
    ContentView()
}
