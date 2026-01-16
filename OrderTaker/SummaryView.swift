import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var store: StoreService
    @State private var selectedDate = Date()
    
    var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: selectedDate)
    }
    
    var totals: [String: Int] {
        var dict: [String: Int] = [:]
        let filtered = store.orders.filter { $0.pickupDate == formattedSelectedDate }
        
        for order in filtered {
            dict[order.itemName, default: 0] += order.quantity
        }
        return dict
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order Summary")
                        .font(Theme.headerFont)
                        .foregroundColor(Theme.Slate.s900)
                    
                    Text("TOTAL ITEMS TO BAKE")
                        .font(Theme.labelFont)
                        .foregroundColor(Theme.Slate.s500)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Theme.primary)
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .accentColor(Theme.primary)
                    Spacer()
                }
                .padding(12)
                .background(Theme.cardBackground)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20) // Normal top padding
            .padding(.bottom, 12)
            
            ScrollView {
                if totals.isEmpty {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 50)
                        Image(systemName: "basket")
                            .font(.system(size: 48))
                            .foregroundColor(Theme.Slate.s400.opacity(0.3))
                        Text("No orders for this date")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.Slate.s500)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    VStack(spacing: 12) {
                        ForEach(totals.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            HStack(spacing: 12) {
                                // Item Name
                                Text(key)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.Slate.s900)
                                
                                Spacer()
                                
                                // Quantity Badge (matching order card style)
                                VStack {
                                    Text("\(value)")
                                        .font(.system(size: 20, weight: .black))
                                        .foregroundColor(Theme.primary)
                                    Text("QTY")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(Theme.Slate.s500)
                                }
                                .frame(width: 50, height: 50)
                                .background(Theme.primary.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .padding(12)
                            .background(Theme.cardBackground)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            
            Spacer()
        }
        .background(Theme.background.ignoresSafeArea())
    }
}

#Preview {
    SummaryView()
        .environmentObject(StoreService())
}
