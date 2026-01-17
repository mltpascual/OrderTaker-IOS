import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: StoreService
    @State private var selectedTab: String = "Today"
    @State private var showingSettings = false
    @State private var sortOption: SortOption = .dateEarliest
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    
    enum SortOption: String, CaseIterable {
        case dateEarliest = "Date: Earliest"
        case dateLatest = "Date: Latest"
        case priceLow = "Price: Low to High"
        case priceHigh = "Price: High to Low"
    }
    
    private var todayStr: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    var filteredOrders: [CakeOrder] {
        var orders: [CakeOrder] = store.orders
        
        // Step 1: Apply search filter (searches ALL orders)
        if !searchText.isEmpty {
            orders = orders.filter { order in
                order.customerName.localizedCaseInsensitiveContains(searchText) ||
                order.itemName.localizedCaseInsensitiveContains(searchText) ||
                order.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Step 2: Filter based on selected tab (only if NOT searching)
        if searchText.isEmpty {
            switch selectedTab {
            case "Today":
                orders = orders.filter { $0.pickupDate == todayStr && $0.status == "pending" }
            case "Pending":
                orders = orders.filter { $0.status == "pending" && $0.pickupDate != todayStr }
            case "Completed":
                orders = orders.filter { $0.status == "completed" }
            default:
                break
            }
        }
        
        // Step 3: Apply sorting based on selected sort option
        switch sortOption {
        case .dateEarliest:
            return orders.sorted { (a, b) in
                if a.pickupDate != b.pickupDate {
                    return a.pickupDate < b.pickupDate
                }
                return a.pickupTime < b.pickupTime
            }
        case .dateLatest:
            return orders.sorted { (a, b) in
                if a.pickupDate != b.pickupDate {
                    return a.pickupDate > b.pickupDate
                }
                return a.pickupTime > b.pickupTime
            }
        case .priceLow:
            return orders.sorted { $0.total < $1.total }
        case .priceHigh:
            return orders.sorted { $0.total > $1.total }
        }
    }
    
    @State private var orderToEdit: CakeOrder? = nil
    @State private var orderToDelete: CakeOrder? = nil
    @State private var showingDeleteAlert: Bool = false
    @State private var orderToComplete: CakeOrder? = nil
    @State private var showingCompleteAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Queue")
                            .font(Theme.headerFont)
                            .foregroundColor(Theme.Slate.s900)
                        
                        Text("\(filteredOrders.count) ORDERS\(searchText.isEmpty ? "" : " (filtered)")")
                            .font(Theme.labelFont)
                            .foregroundColor(Theme.Slate.s500)
                    }
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: { 
                            isSearching.toggle()
                            if !isSearching {
                                searchText = "" // Clear search when closing
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(isSearching || !searchText.isEmpty ? Theme.primary : Theme.Slate.s400)
                        }
                        
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(Theme.Slate.s400)
                        }

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
                .padding(.bottom, 8)
                
                // Search Bar
                if isSearching || !searchText.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.Slate.s400)
                        
                        TextField("Search customer, item, or notes...", text: $searchText)
                            .font(.system(size: 14))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.Slate.s400)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Theme.inputBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                }
                
                // Sort Filter
                HStack {
                    Spacer()
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: { sortOption = option }) {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Theme.Slate.s500)
                            Text(sortOption.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Theme.Slate.s600)
                                .frame(minWidth: 110, alignment: .leading) // Fixed width prevents text overflow when switching filters
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Theme.Slate.s400)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.cardBackground)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 6)
                
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
                                    // Show confirmation for completing orders in Today and Pending tabs
                                    if newStatus == "completed" && (selectedTab == "Today" || selectedTab == "Pending") {
                                        orderToComplete = order
                                        showingCompleteAlert = true
                                    } else {
                                        // For other status changes (e.g., restore to pending from completed tab), apply directly
                                        if let id = order.id {
                                            store.updateOrderStatus(orderId: id, status: newStatus)
                                        }
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
            .onChange(of: selectedTab) { newTab in
                // Auto-switch sort option based on selected tab
                if newTab == "Completed" {
                    sortOption = .dateLatest  // Latest first for completed orders
                } else {
                    sortOption = .dateEarliest  // Earliest first for today and pending
                }
            }
            .sheet(item: $orderToEdit) { order in
                OrderFormView(editingOrder: order)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
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
            .alert(isPresented: $showingCompleteAlert) {
                Alert(
                    title: Text("Complete Order?"),
                    message: Text("Mark the order for \(orderToComplete?.customerName ?? "this customer") as completed?"),
                    primaryButton: .default(Text("Complete")) {
                        if let id = orderToComplete?.id {
                            store.updateOrderStatus(orderId: id, status: "completed")
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
                    .background(Theme.cardBackground)
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
