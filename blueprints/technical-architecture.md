# Technical Architecture & Business Logic

## Data Structures

### User Profile (Firestore: `users/{uid}`)
```typescript
interface UserProfile {
  uid: string;
  fullName: string;
  email: string;
  createdAt: string;
  role: 'user';
}
```

### Order (Firestore: `users/{uid}/orders/{orderId}`)
```typescript
interface Order {
  id: string;
  itemName: string; // Primary display field
  customerName: string; // Secondary display field
  quantity: number;
  total: number;
  notes: string;
  source: string; // "Instagram", "Marketplace", "FB Page", etc. (Stored exactly as displayed)
  timestamp: string; // Creation time
  pickupDate: string; // YYYY-MM-DD
  pickupTime: string; // HH:MM
  status: 'pending' | 'completed';
}
```

### Menu Item (Firestore: `users/{uid}/menu/{itemId}`)
```typescript
interface CakeItem {
  id: string;
  name: string;
  basePrice: number;
}
```

## Logic Rules
1.  **Sorting Strategy**:
    *   **Earliest Pickup (Default)**: Sorts by `pickupDate` ASC, then `pickupTime` ASC.
    *   **Latest Pickup**: Sorts by `pickupDate` DESC, then `pickupTime` DESC.
2.  **Form Validation**:
    *   **Strict Mode**: The "Confirm" button is disabled if `Customer Name`, `Select Item`, `Pickup Date`, or `Pickup Time` are empty.
    *   **Defaults**: Pickup Date and Time default to empty strings to force user selection.
3.  **Source Defaulting**: All new orders default to `Marketplace`.
4.  **Filter Logic**:
    *   `Today`: Filter where `pickupDate === current_local_date` AND `status === 'pending'`.
    *   `Pending`: All orders with `status === 'pending'`.
    *   `Completed`: All orders with `status === 'completed'`.
    *   `Summary`: A specific view for daily production summaries.
5.  **Order Summary**:
    *   A dashboard widget that aggregates total quantities per `itemName` for a specific selected date.
    *   Includes both 'pending' and 'completed' orders to show total production requirement.
6.  **Sales Reporting Logic**:
    *   **KPIs**: Calculates 'Total Revenue' (from completed orders), 'Pipeline' (from pending orders), 'Total Orders', and 'Average Order Value'.
    *   **Top Selling Items**: Lists the top 5 `itemName` based on total `quantity` sold across all orders.
    *   **Orders by Source**: Aggregates order counts by `source` (e.g., "Instagram", "Marketplace").
    *   All calculations are derived from the `Order` collection.
7.  **Confirmations**:
    *   Moving an order to 'Completed' triggers a specific confirmation modal.
    *   Deleting an order triggers a specific rose-themed confirmation modal.
8.  **Custom Items**: The OrderForm allows a "Select Item Custom" option which enables manual Name and Price entry.
9.  **Navigation**: The `activeTab` state now supports `'orders'`, `'menu'`, and `'reports'`.
68. **Environment Configuration**: Sensitive data (Firebase API keys, etc.) is managed via `.env` files using Vite's `import.meta.env` system.