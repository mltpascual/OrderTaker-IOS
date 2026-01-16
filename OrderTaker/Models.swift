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

struct CakeItem: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    let name: String
    let basePrice: Double
    var category: String? // "Cake", "Dessert", or "Other" - nil for existing items (uses fallback)
    
    static func == (lhs: CakeItem, rhs: CakeItem) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.basePrice == rhs.basePrice && lhs.category == rhs.category
    }
}

enum OrderStatus: String {
    case pending = "pending"
    case completed = "completed"
}
