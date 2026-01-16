import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var store: StoreService
    
    var stats: Stats {
        let orders = store.orders
        let completed = orders.filter { $0.status == "completed" }
        let pending = orders.filter { $0.status == "pending" }
        
        let revenue = completed.reduce(0) { $0 + $1.total }
        let pipeline = pending.reduce(0) { $0 + $1.total }
        let totalOrders = orders.count
        let avgValue = totalOrders > 0 ? (revenue + pipeline) / Double(totalOrders) : 0
        
        // Top Items
        var itemCounts: [String: Int] = [:]
        for o in orders { itemCounts[o.itemName, default: 0] += o.quantity }
        let topItems = itemCounts.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
        
        // Sources
        var sourceCounts: [String: Int] = [:]
        for o in orders { sourceCounts[o.source, default: 0] += 1 }
        let sources = sourceCounts.map { ($0.key, $0.value) }
        
        return Stats(revenue: revenue, pipeline: pipeline, totalOrders: totalOrders, avgValue: avgValue, topItems: topItems, sources: sources)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Text("Sales Report")
                    .font(Theme.headerFont)
                    .foregroundColor(Theme.Slate.s900)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                
                // KPIs Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(title: "TOTAL REVENUE", value: "$\(String(format: "%.0f", stats.revenue))", color: Theme.success)
                    StatCard(title: "PIPELINE", value: "$\(String(format: "%.0f", stats.pipeline))", color: Theme.primary)
                    StatCard(title: "TOTAL ORDERS", value: "\(stats.totalOrders)", color: Theme.Slate.s900)
                    StatCard(title: "AVG. ORDER", value: "$\(String(format: "%.0f", stats.avgValue))", color: Theme.Slate.s600)
                }
                .padding(.horizontal, 24)
                
                // Top Items Chart
                VStack(alignment: .leading, spacing: 20) {
                    Text("TOP SELLING ITEMS")
                        .font(Theme.labelFont)
                        .foregroundColor(Theme.Slate.s500)
                    
                    VStack(spacing: 16) {
                        ForEach(stats.topItems, id: \.0) { item, count in
                            HStack {
                                Text(item)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Theme.Slate.s900)
                                Spacer()
                                Text("\(count)")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(Theme.primary)
                            }
                            
                            // Simple bar
                            GeometryReader { geo in
                                Capsule()
                                    .fill(Theme.primary.opacity(0.1))
                                    .frame(height: 8)
                                    .overlay(
                                        Capsule()
                                            .fill(Theme.primary)
                                            .frame(width: geo.size.width * CGFloat(min(Double(count) / 20.0, 1.0)), height: 8), // Norm to 20 for mock
                                        alignment: .leading
                                    )
                            }
                            .frame(height: 8)
                        }
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(24)
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
        }
        .background(Theme.background.ignoresSafeArea())
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
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
    }
}

struct Stats {
    let revenue: Double
    let pipeline: Double
    let totalOrders: Int
    let avgValue: Double
    let topItems: [(String, Int)]
    let sources: [(String, Int)]
}

#Preview {
    ReportsView()
        .environmentObject(StoreService())
}
