# AI Agent Handover Protocol

## 🤖 Context for the Next Agent
This document serves as the primary context injection point for any AI agent taking over development of the **OrderTaker iOS App**. It summarizes the architectural decisions, file structure, and business logic constraints currently in place.

---

## 🏗️ Core Architecture (Crucial)

### 1. Swift & Xcode Setup
*   **Environment**: This project is a **native iOS application** built with **SwiftUI** and managed via **Xcode**.
*   **Dependencies**: Packages are managed via **Swift Package Manager (SPM)** and include Firebase iOS SDK.
*   **Build System**: Xcode project (`.xcodeproj`) with support for iOS 17.0+.

### 2. Backend Strategy (Firebase)
*   **Auth**: Email/Password authentication via Firebase Auth iOS SDK.
*   **Database**: Cloud Firestore with real-time listeners.
*   **Data Isolation**: All data is scoped to the user via Firestore security rules.
    *   `users/{uid}/orders/{orderId}`
    *   `users/{uid}/menu/{menuId}`
    *   `users/{uid}` (UserProfile document)
*   **Realtime**: State in `StoreService` is driven by `addSnapshotListener`. The service acts as an `ObservableObject` and publishes changes to SwiftUI views. Do not rely on manual fetch calls; rely on the listeners to update `@Published` properties automatically.

---

## 📂 File System Map

*   **`OrderTakerApp.swift`**: The app entry point. Initializes Firebase and sets up the `StoreService` environment object.
*   **`StoreService.swift`**: Centralized data service.
    *   Manages authentication state.
    *   Maintains real-time listeners for `orders` and `menuItems`.
    *   Provides CRUD methods with optimistic updates.
    *   Handles CSV import/export.
*   **`Models.swift`**: Data models (`UserProfile`, `CakeOrder`, `CakeItem`, `OrderStatus` enum).
*   **`Theme.swift`**: Centralized design system (colors, fonts, corner radii).
*   **`UIComponents.swift`**: Reusable SwiftUI components (`PrimaryButton`, `OrderCard`, `InputField`, etc.).
*   **Views**:
    *   **`LoginView.swift`**: Email/Password authentication UI.
    *   **`ContentView.swift`**: Root view controller that determines auth state.
    *   **`MainTabView.swift`**: Tab bar navigation (Orders, Summary, Menu, Reports, Settings).
    *   **`DashboardView.swift`**: Orders list with filtering (Today, Pending, Completed).
    *   **`OrderFormView.swift`**: Add/Edit order form with validation.
    *   **`MenuView.swift`**: Menu item management.
    *   **`ReportsView.swift`**: Sales analytics dashboard.
    *   **`SummaryView.swift`**: Daily production summary.
    *   **`SettingsView.swift`**: App settings and CSV import/export.
    *   **`ProfileView.swift`**: User profile display.
*   **`MockData.swift`**: Sample data for testing.
*   **`blueprints/`**:
    *   `design-system.md`: UI/UX rules (Colors, Typography, Component patterns).
    *   `technical-architecture.md`: Data schemas and Business Logic.
    *   `project-overview.md`: High-level goals and tech stack.

---

## 🧠 Business Logic & Rules

### Order Processing
1.  **Validation**: An order cannot be submitted without Customer Name, Item Name, Source, Pickup Date, and Pickup Time.
2.  **Date Handling**: Use local date strings (`yyyy-MM-dd`) stored in Firestore. Avoid UTC conversions for pickup dates to prevent "off-by-one-day" errors.
3.  **Status**: Orders are binary: `'pending'` or `'completed'`.
4.  **Source Tracking**: Critical for marketing reports. Defaults to 'Marketplace'.
5.  **Optimistic Updates**: `StoreService` applies changes locally immediately, then syncs to Firestore. Real-time listeners ensure eventual consistency.

### Data Synchronization
1.  **Real-time Listeners**: `StoreService` uses `addSnapshotListener` for orders and menu items. All SwiftUI views observe `@Published` properties and update automatically.
2.  **Firestore Security**: User data is isolated via Firestore security rules. Only authenticated users can access their own data.

### UI/UX Standards
1.  **iOS Native Patterns**: Use `.sheet()`, `.alert()`, and `.confirmationDialog()` for modals.
2.  **SwiftUI Bindings**: Use `@Binding`, `@State`, and `@EnvironmentObject` for state management.
3.  **Theme Consistency**: Always reference `Theme.swift` for colors, fonts, and corner radii.
4.  **Accessibility**: Ensure proper labels for VoiceOver support.
5.  **Dark Mode**: 
    - Use adaptive colors from `Theme.swift` (e.g., `Theme.cardBackground`, `Theme.inputBackground`)
    - Apply `.preferredColorScheme()` to views that need immediate updates when dark mode toggles
    - Settings uses `@AppStorage("isDarkMode")` to persist user preference
6.  **Sort Filters**:
    - `SortOption` enum with 4 cases: `.dateEarliest`, `.dateLatest`, `.priceLow`, `.priceHigh`
    - Auto-switching: Completed tab defaults to Latest, Today/Pending default to Earliest
    - Use `.onChange(of: selectedTab)` to trigger auto-switching logic

---

## 🔮 Future Trajectory / Known Context
*   The app is designed to look **premium** with a boutique bakery aesthetic.
*   Current focus is on **speed of entry** and **visual clarity** for order management.
*   Next logical steps (if requested) might involve:
    *   Search functionality across orders.
    *   Push notifications for order reminders.
    *   Image attachments for custom cake designs (requires Firebase Storage SDK).
    *   TestFlight distribution for beta testing.

---

**Instruction to Agent**: When making changes, always check `blueprints/design-system.md` to ensure you are using the correct SwiftUI modifiers and `Theme` constants (e.g., `Theme.primary`, `Theme.cardCornerRadius`, `Theme.headerFont`).
