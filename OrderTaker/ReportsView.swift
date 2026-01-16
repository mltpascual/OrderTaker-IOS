import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var store: StoreService
    
    let cakeItems = [
        "Chocolate Cake (6\")",
        "Red Velvet Cake (6\")",
        "Red Velvet Cake (8\")",
        "Sansrival Cake (6\")",
        "Sansrival Cake (8\")",
        "Ube Leche Flan Cake (6\")",
        "Ube Leche Flan Cake (8\")",
        "Ube Macapuno Cake (6\")",
        "Ube Macapuno Cake (8\")",
        "Custard Cake (8x8\")",
        "Custard Cake (9x13)"
    ]
    
    let dessertItems = [
        "Brownies (8x8\")",
        "Butterscotch Brownies (8x8\")",
        "Leche Flan",
        "Cheese Rolls",
        "Crinkles",
        "Kuntsinta",
        "Puto"
    ]
    
    var stats: Stats {
        let orders = store.orders
        let completed = orders.filter { $0.status == "completed" }
        let pending = orders.filter { $0.status == "pending" }
        
        let revenue = completed.reduce(0) { $0 + $1.total }
        let pipeline = pending.reduce(0) { $0 + $1.total }
        let totalOrders = orders.count
        let avgValue = totalOrders > 0 ? (revenue + pipeline) / Double(totalOrders) : 0
        
        // All Items with counts
        var itemCounts: [String: Int] = [:]
        for o in orders { itemCounts[o.itemName, default: 0] += o.quantity }
        
        // Categorize items
        var cakes: [(String, Int)] = []
        var desserts: [(String, Int)] = []
        var other: [(String, Int)] = []
        
        for (itemName, count) in itemCounts {
            // Look up the menu item to check if it has a category
            let menuItem = store.menuItems.first { $0.name == itemName }
            
            if let category = menuItem?.category {
                // Use menu item's category field
                if category == "Cake" {
                    cakes.append((itemName, count))
                } else if category == "Dessert" {
                    desserts.append((itemName, count))
                } else {
                    other.append((itemName, count))
                }
            } else {
                // Fallback to hardcoded arrays for existing items without category
                if cakeItems.contains(itemName) {
                    cakes.append((itemName, count))
                } else if dessertItems.contains(itemName) {
                    desserts.append((itemName, count))
                } else {
                    other.append((itemName, count))
                }
            }
        }
        
        // Sort each category by count descending
        cakes.sort { $0.1 > $1.1 }
        desserts.sort { $0.1 > $1.1 }
        other.sort { $0.1 > $1.1 }
        
        // Sources
        var sourceCounts: [String: Int] = [:]
        for o in orders { sourceCounts[o.source, default: 0] += 1 }
        let sources = sourceCounts.map { ($0.key, $0.value) }
        
        return Stats(revenue: revenue, pipeline: pipeline, totalOrders: totalOrders, avgValue: avgValue, cakes: cakes, desserts: desserts, other: other, sources: sources)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Sales Report")
                    .font(Theme.headerFont)
                    .foregroundColor(Theme.Slate.s900)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                
                // KPIs Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    StatCard(title: "TOTAL REVENUE", value: "$\(String(format: "%.0f", stats.revenue))", color: Theme.success)
                    StatCard(title: "PIPELINE", value: "$\(String(format: "%.0f", stats.pipeline))", color: Theme.primary)
                    StatCard(title: "TOTAL ORDERS", value: "\(stats.totalOrders)", color: Theme.Slate.s900)
                    StatCard(title: "AVG. ORDER", value: "$\(String(format: "%.0f", stats.avgValue))", color: Theme.Slate.s600)
                }
                .padding(.horizontal, 24)
                
                // Cakes Section
                if !stats.cakes.isEmpty {
                    ItemCategorySection(title: "CAKES", items: stats.cakes, color: Theme.primary)
                }
                
                // Desserts Section
                if !stats.desserts.isEmpty {
                    ItemCategorySection(title: "DESSERTS", items: stats.desserts, color: Theme.success)
                }
                
                // Other Items Section
                if !stats.other.isEmpty {
                    ItemCategorySection(title: "OTHER ITEMS", items: stats.other, color: Theme.Slate.s600)
                }
            }
            .padding(.bottom, 100)
        }
        .background(Theme.background.ignoresSafeArea())
    }
}

struct ItemCategorySection: View {
    let title: String
    let items: [(String, Int)]
    let color: Color
    
    var maxCount: Int {
        items.map { $0.1 }.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(Theme.labelFont)
                .foregroundColor(Theme.Slate.s500)
            
            VStack(spacing: 16) {
                ForEach(items, id: \.0) { item, count in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(item)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Theme.Slate.s900)
                            Spacer()
                            Text("\(count)")
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(color)
                        }
                        
                        // Simple bar
                        GeometryReader { geo in
                            Capsule()
                                .fill(color.opacity(0.1))
                                .frame(height: 8)
                                .overlay(
                                    Capsule()
                                        .fill(color)
                                        .frame(width: geo.size.width * CGFloat(Double(count) / Double(maxCount)), height: 8),
                                    alignment: .leading
                                )
                        }
                        .frame(height: 8)
                    }
                }
            }
        }
        .padding(24)
        .background(Theme.cardBackground)
        .cornerRadius(24)
        .padding(.horizontal, 24)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(Theme.labelFont)
                .foregroundColor(Theme.Slate.s500)
            
            Text(value)
                .font(.system(size: 24, weight: .black))
                .foregroundColor(color)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
    }
}

struct Stats {
    let revenue: Double
    let pipeline: Double
    let totalOrders: Int
    let avgValue: Double
    let cakes: [(String, Int)]
    let desserts: [(String, Int)]
    let other: [(String, Int)]
    let sources: [(String, Int)]
}

#Preview {
    ReportsView()
        .environmentObject(StoreService())
}
