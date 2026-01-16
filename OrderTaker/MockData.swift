import Foundation

extension CakeOrder {
    static let mockOrders: [CakeOrder] = [
        CakeOrder(
            id: "1",
            itemName: "Chocolate Ganache Cake",
            customerName: "Alice Johnson",
            quantity: 1,
            total: 45.0,
            notes: "Happy Birthday Alice!",
            source: "Instagram",
            timestamp: "2026-01-15T10:00:00Z",
            pickupDate: "2026-01-16",
            pickupTime: "14:00",
            status: "pending"
        ),
        CakeOrder(
            id: "2",
            itemName: "Red Velvet Special",
            customerName: "Bob Smith",
            quantity: 2,
            total: 90.0,
            notes: "Extra frosting please",
            source: "Marketplace",
            timestamp: "2026-01-15T11:00:00Z",
            pickupDate: "2026-01-16",
            pickupTime: "10:30",
            status: "pending"
        ),
        CakeOrder(
            id: "3",
            itemName: "Vanilla Bean Cupcakes",
            customerName: "Charlie Brown",
            quantity: 12,
            total: 36.0,
            notes: "",
            source: "FB Page",
            timestamp: "2026-01-14T09:00:00Z",
            pickupDate: "2026-01-15",
            pickupTime: "16:00",
            status: "completed"
        )
    ]
}

extension CakeItem {
    static let mockMenu: [CakeItem] = [
        CakeItem(id: "m1", name: "Chocolate Ganache Cake", basePrice: 45.0),
        CakeItem(id: "m2", name: "Red Velvet Special", basePrice: 45.0),
        CakeItem(id: "m3", name: "Vanilla Bean Cupcakes", basePrice: 3.0)
    ]
}
