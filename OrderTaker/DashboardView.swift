import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: StoreService
    @State private var selectedTab: String = "Today"
    
    private var todayStr: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    var filteredOrders: [CakeOrder] {
        let sorted = store.orders.sorted { (a, b) in
            if a.pickupDate != b.pickupDate {
                return a.pickupDate < b.pickupDate
            }
            return a.pickupTime < b.pickupTime
        }
        
        switch selectedTab {
        case "Today":
            return sorted.filter { $0.pickupDate == todayStr && $0.status == "pending" }
        case "Pending":
            return sorted.filter { $0.status == "pending" }
        case "Completed":
            return sorted.filter { $0.status == "completed" }
        default:
            return sorted
        }
    }
    
    @State private var orderToEdit: CakeOrder? = nil
    @State private var orderToDelete: CakeOrder? = nil
    @State private var showingDeleteAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Queue")
                            .font(Theme.headerFont)
                            .foregroundColor(Theme.Slate.s900)
                        
                        Text("\(filteredOrders.count) ORDERS")
                            .font(Theme.labelFont)
                            .foregroundColor(Theme.Slate.s500)
                    }
                    Spacer()
                    
                    HStack(spacing: 16) {

                        Button(action: { store.signOut() }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(Theme.Slate.s400)
                        }
                    }
                    .padding(8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Custom Tab Bar
                HStack(spacing: 0) {
                    TabButton(title: "Today", isSelected: selectedTab == "Today") { 
                        selectedTab = "Today"
                    }
                    TabButton(title: "Pending", isSelected: selectedTab == "Pending") { 
                        selectedTab = "Pending"
                    }
                    TabButton(title: "Completed", isSelected: selectedTab == "Completed") { 
                        selectedTab = "Completed"
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
                
                // Order List
                if filteredOrders.isEmpty {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 100)
                        Image(systemName: "tray.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Theme.Slate.s400.opacity(0.3))
                        Text("No orders found in \(selectedTab)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.Slate.s500)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    List {
                        ForEach(filteredOrders) { order in
                            OrderCard(
                                order: order,
                                onDuplicate: {
                                    var newOrder = order
                                    newOrder.id = nil
                                    store.addOrder(newOrder)
                                },
                                onEdit: { orderToEdit = order },
                                onDelete: {
                                    orderToDelete = order
                                    showingDeleteAlert = true
                                },
                                onStatusChange: { newStatus in
                                    if let id = order.id {
                                        store.updateOrderStatus(orderId: id, status: newStatus)
                                    }
                                }
                            )
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    orderToDelete = order
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    orderToEdit = order
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(Theme.Slate.s400)
                            }
                            .swipeActions(edge: .leading) {
                                if order.status == "pending" {
                                    Button {
                                        if let id = order.id {
                                            store.updateOrderStatus(orderId: id, status: "completed")
                                        }
                                    } label: {
                                        Label("Complete", systemImage: "checkmark.circle")
                                    }
                                    .tint(Theme.primary)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        store.fetchOrders()
                        store.fetchMenu()
                    }
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(item: $orderToEdit) { order in
                OrderFormView(editingOrder: order)
                    .environmentObject(store)
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Order?"),
                    message: Text("Are you sure you want to delete the order for \(orderToDelete?.customerName ?? "this customer")? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let id = orderToDelete?.id {
                            store.deleteOrder(orderId: id)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(isSelected ? Theme.primary : Theme.Slate.s500)
                
                ZStack {
                    Capsule()
                        .fill(Color.clear)
                        .frame(height: 3)
                    if isSelected {
                        Capsule()
                            .fill(Theme.primary)
                            .frame(height: 3)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ProductionSummaryView: View {
    let orders: [CakeOrder]
    
    var totals: [String: Int] {
        var dict: [String: Int] = [:]
        for order in orders {
            dict[order.itemName, default: 0] += order.quantity
        }
        return dict
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(totals.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    HStack(spacing: 8) {
                        Text("\(value)")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(Theme.primary)
                        Text(key)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Theme.Slate.s900)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(StoreService())
}
