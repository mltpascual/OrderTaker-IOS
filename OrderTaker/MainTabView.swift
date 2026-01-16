import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: StoreService
    @State private var selectedTab: Int = 0
    @State private var showingOrderForm = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                if selectedTab == 0 {
                    DashboardView()
                } else if selectedTab == 1 {
                    SummaryView()
                } else if selectedTab == 2 {
                    ReportsView() // Sales
                } else if selectedTab == 3 {
                    MenuView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Bottom Tab Bar
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    TabItem(icon: "tray.fill", label: "Orders", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    .frame(maxWidth: .infinity)
                    
                    TabItem(icon: "list.clipboard", label: "Summary", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                
                // Central Add Button
                Button(action: { showingOrderForm = true }) {
                    ZStack {
                        Circle()
                            .fill(Theme.primary)
                            .frame(width: 56, height: 56)
                            .shadow(color: Theme.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -20)
                .frame(width: 80)
                
                HStack(spacing: 0) {
                    TabItem(icon: "chart.line.uptrend.xyaxis", label: "Sales", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                    .frame(maxWidth: .infinity)
                    
                    TabItem(icon: "fork.knife", label: "Menu", isSelected: selectedTab == 3) {
                        selectedTab = 3
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 40)
            .padding(.top, 12)
            .padding(.bottom, 34)
            .background(
                Theme.cardBackground
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
            )
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .sheet(isPresented: $showingOrderForm) {
            OrderFormView()
                .environmentObject(store)
        }
    }
}

struct TabItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(height: 24)
                Text(label)
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(isSelected ? Theme.primary : Theme.Slate.s400)
            .frame(width: 60) // Keep width, height is implicit
        }
    }
}

#Preview {
    MainTabView()
}
