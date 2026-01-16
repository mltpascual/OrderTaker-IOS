import SwiftUI

struct MenuView: View {
    @EnvironmentObject var store: StoreService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Menu Management")
                        .font(Theme.headerFont)
                        .foregroundColor(Theme.Slate.s900)
                    
                    Text("\(store.menuItems.count) ITEMS IN CATALOG")
                        .font(Theme.labelFont)
                        .foregroundColor(Theme.Slate.s500)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                List {
                    ForEach(store.menuItems) { item in
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Theme.primary.opacity(0.1))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "birthday.cake.fill")
                                        .foregroundColor(Theme.primary)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.Slate.s900)
                                Text("Starting at $\(String(format: "%.2f", item.basePrice))")
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.Slate.s600)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Theme.Slate.s400)
                        }
                        .padding(.vertical, 8)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .padding(.horizontal, 8)
                
                Spacer()
                
                PrimaryButton(title: "ADD NEW ITEM", action: {})
                    .padding(24)
                    .padding(.bottom, 80)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(StoreService())
}
