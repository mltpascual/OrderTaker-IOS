import Foundation
import FirebaseFirestore

struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String { id ?? "" }
    let fullName: String
    let email: String
    let createdAt: String
    let role: String // 'user'
}

struct CakeOrder: Codable, Identifiable {
    @DocumentID var id: String?
    let itemName: String
    let customerName: String
    let quantity: Int
    let total: Double
    let notes: String
    let source: String
    let timestamp: String
    let pickupDate: String // YYYY-MM-DD
    let pickupTime: String // HH:MM
    var status: String // 'pending' | 'completed'
}

struct CakeItem: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let basePrice: Double
}

enum OrderStatus: String {
    case pending = "pending"
    case completed = "completed"
}
