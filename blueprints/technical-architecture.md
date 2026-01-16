# Technical Architecture & Business Logic

## Data Structures

All data models are defined in `Models.swift` using Swift structs with `Codable` and `Identifiable` conformance for Firestore integration.

### UserProfile (Firestore: `users/{uid}`)
```swift
struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String { id ?? "" }
    let fullName: String
    let email: String
    let createdAt: String
    let role: String // 'user'
}
```

### CakeOrder (Firestore: `users/{uid}/orders/{orderId}`)
```swift
struct CakeOrder: Codable, Identifiable {
    @DocumentID var id: String?
    let itemName: String        // Primary display field
    let customerName: String    // Secondary display field
    let quantity: Int
    let total: Double
    let notes: String
    let source: String          // "Marketplace", "Paula", "FB Page", etc.
    let timestamp: String       // Creation time (ISO8601)
    let pickupDate: String      // yyyy-MM-dd
    let pickupTime: String      // HH:mm
    var status: String          // 'pending' | 'completed'
}
```

### CakeItem (Firestore: `users/{uid}/menu/{itemId}`)
```swift
struct CakeItem: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let basePrice: Double
}
```

### OrderStatus Enum
```swift
enum OrderStatus: String {
    case pending = "pending"
    case completed = "completed"
}
```

---

## StoreService Architecture

The `StoreService` class is an `ObservableObject` that manages all data operations:

### Published Properties
- `@Published var orders: [CakeOrder]` - Real-time synced orders
- `@Published var menuItems: [CakeItem]` - Real-time synced menu items
- `@Published var currentUser: UserProfile?` - Current authenticated user

### Real-time Listeners
- `ordersListener: ListenerRegistration?` - Firestore snapshot listener for orders
- `menuListener: ListenerRegistration?` - Firestore snapshot listener for menu items
- `userListener: ListenerRegistration?` - Firestore snapshot listener for user profile

### Key Methods
1. **Authentication**
   - `signIn()` - Sets up auth state listener and fetches data
   - `emailSignIn(email:password:completion:)` - Email/password login
   - `emailSignUp(email:password:fullName:completion:)` - New user registration
   - `signOut()` - Removes listeners and signs out

2. **Orders CRUD**
   - `fetchOrders()` - Establishes real-time listener
   - `addOrder(_:)` - Adds order with optimistic update
   - `updateOrder(_:)` - Updates order with optimistic update
   - `updateOrderStatus(orderId:status:)` - Changes order status
   - `deleteOrder(orderId:)` - Deletes order with optimistic update

3. **Menu CRUD**
   - `fetchMenu()` - Establishes real-time listener
   - `addMenuItem(_:)` - Adds menu item with optimistic update
   - `updateMenuItem(_:)` - Updates menu item
   - `deleteMenuItem(itemId:)` - Deletes menu item with optimistic update

4. **CSV Operations**
   - `exportOrdersToCSV() -> String` - Exports orders to tab-delimited CSV
   - `importOrdersFromCSV(_:)` - Imports orders from CSV
   - `exportMenuToCSV() -> String` - Exports menu to CSV
   - `importMenuFromCSV(_:)` - Imports menu from CSV

---

## Business Logic Rules

### 1. Sorting Strategy
*   **Earliest Pickup (Default)**: Orders are fetched from Firestore with `.order(by: "pickupDate").order(by: "pickupTime")`, ensuring earliest deadlines appear first.
*   **SwiftUI Sorting**: Additional sorting can be applied in views using `.sorted(by:)`.

### 2. Form Validation
*   **Strict Mode**: The "Add Order" button in `OrderFormView` is disabled if:
    - Customer Name is empty
    - Item Name is empty
    - Pickup Date is empty
    - Pickup Time is empty
*   **Defaults**: Pickup Date and Time default to empty strings to force user selection.
*   **Source Defaulting**: All new orders default to `"Marketplace"` if not specified.

### 3. Date Handling
*   **Storage Format**: `yyyy-MM-dd` for dates, `HH:mm` for times (stored as strings in Firestore).
*   **Display Format**: Converted to localized formats in views using `DateFormatter`.
*   **No UTC Conversion**: Local date strings prevent "off-by-one-day" errors.

### 4. Filter Logic
Filtering is performed in SwiftUI views, not in Firestore queries:
*   **Today**: `pickupDate == current_local_date` AND `status == 'pending'`
*   **Pending**: `status == 'pending'`
*   **Completed**: `status == 'completed'`

### 5. Production Summary
*   Aggregates total quantities per `itemName` for a specific selected date.
*   Includes both 'pending' and 'completed' orders to show total production requirement.
*   Performed client-side in `SummaryView` using Swift's `Dictionary(grouping:)`.

### 6. Sales Reporting Logic
All calculations are derived client-side from the `orders` array in `ReportsView`:
*   **Total Revenue**: Sum of `total` from completed orders.
*   **Pipeline**: Sum of `total` from pending orders.
*   **Total Orders**: Count of all orders.
*   **Average Order Value**: Total revenue ÷ total orders.
*   **Top Selling Items**: Top 5 `itemName` based on total `quantity` sold.
*   **Orders by Source**: Aggregated order counts by `source` field.

### 7. Optimistic Updates
*   All write operations (add, update, delete) apply changes to local `@Published` arrays **immediately**.
*   Firestore sync happens asynchronously.
*   Real-time listeners ensure eventual consistency if optimistic updates fail.

### 8. Confirmations
*   **Mark as Completed**: `.confirmationDialog()` with success theme.
*   **Delete Order**: `.alert()` with danger theme.
*   **Restore to Pending**: Context menu action.

### 9. Custom Items
*   `OrderFormView` allows selecting "Custom Item" which enables manual Name and Price entry.
*   Menu items populate a `Picker` for quick selection.

### 10. Navigation
*   **TabView**: Primary navigation with 5 tabs (Orders, Summary, Menu, Reports, Settings).
*   **NavigationStack**: Used within tabs for hierarchical flows (e.g., editing orders).

### 11. Environment Configuration
*   Firebase configuration is loaded from `GoogleService-Info.plist`.
*   No environment variables are used; all config is handled by Firebase SDK.

---

## Firestore Security Rules (Recommended)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /orders/{orderId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /menu/{menuId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

---

## CSV Format Specifications

### Orders CSV (Tab-Delimited)
```
Date	Time	Order	Quantity	Cost	Name	Status	Notes	Source
Friday, January 16, 2026	12:00 PM	Leche Flan	1	$10.00	John Doe	completed		Marketplace
```

### Menu CSV (Tab-Delimited)
```
Item Name	Base Price
Custard Cake (8x8")	$25.00
Leche Flan	$10.00
```

---

## Error Handling

- **Authentication Errors**: Displayed via `.alert()` in `LoginView`.
- **Firestore Errors**: Logged to console; optimistic updates revert on failure.
- **CSV Import Errors**: Skips invalid rows and logs warnings; reports success/error counts.