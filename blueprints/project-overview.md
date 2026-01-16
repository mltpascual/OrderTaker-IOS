# Project Overview: OrderTaker iOS

## Mission
OrderTaker is a high-end, professional Order Management System (OMS) designed specifically for boutique bakeries and small businesses. Built as a **native iOS application**, it prioritizes speed of entry, mobile-first responsiveness, and a premium aesthetic tailored for iPhone and iPad.

## Tech Stack
- **Platform**: Native iOS 17.0+
- **Language**: Swift 5.9
- **Framework**: SwiftUI (Declarative UI)
- **Backend/Auth**: Firebase (Authentication, Cloud Firestore)
- **Package Manager**: Swift Package Manager (SPM)
- **IDE**: Xcode 15.0+
- **Design System**: Custom `Theme.swift` with SF Pro fonts and SF Symbols iconography
- **Architecture**: MVVM with `StoreService` as the data layer (`ObservableObject`)

## Current State
The app is currently a fully functional native iOS application with:

1. **Authentication**: 
   - Email/Password login and registration
   - Automatic User Profile creation in Firestore
   - Persistent session management via Firebase Auth

2. **Order Management**: 
   - CRUD operations for bakery orders
   - **Smart Sorting**: Default sorting by 'Earliest Pickup' (Date + Time) to prioritize immediate deadlines
   - **Enhanced Validation**: Strict constraints ensuring Pickup Date and Time are entered before submission
   - **Optimistic Updates**: Instant local updates with Firebase sync
   - **Real-time Sync**: SwiftUI views automatically update via Combine publishers

3. **Menu Management**: 
   - Dynamic menu items that populate the order form
   - Add, edit, and delete menu items
   - Alphabetically sorted display
   - 20+ default bakery items included

4. **Production Summary**: 
   - Daily production totals aggregated by item
   - Date picker for historical views
   - Real-time quantity calculation

5. **Sales Reports**: 
   - KPI dashboard (Revenue, Pipeline, AOV, Total Orders)
   - Categorized sales reports (Cakes vs Desserts)
   - Order source breakdown for marketing insights
   - All-time statistics

6. **Advanced Features**:
   - **Full Dark Mode Support**: Adaptive color system using iOS system colors
   - **Sort Filters**: 4 sorting options (Date Earliest/Latest, Price Low/High) with auto-switching based on tab
   - CSV Import/Export for orders and menu
   - Swipe actions for quick edits
   - Context menus for secondary actions
   - Offline-first architecture with Firebase sync
   - Real-time cross-device synchronization

## App Structure

### Navigation
- **TabView**: Primary navigation with 5 tabs
  - Orders (DashboardView)
  - Summary (SummaryView)
  - Menu (MenuView)
  - Reports (ReportsView)
  - Settings (SettingsView)

### Views
- **LoginView**: Email/Password authentication
- **DashboardView**: Orders list with filtering (Today, Pending, Completed)
- **OrderFormView**: Add/Edit order with validation
- **MenuView**: Menu management
- **ReportsView**: Sales analytics
- **SummaryView**: Daily production summary
- **SettingsView**: CSV import/export and app settings
- **ProfileView**: User profile display

### Data Layer
- **StoreService**: Singleton `ObservableObject` that manages:
  - Firebase authentication state
  - Real-time Firestore listeners
  - CRUD operations with optimistic updates
  - CSV import/export logic

## Design Philosophy
- **Premium Aesthetic**: Boutique bakery styling with Indigo primary color
- **Speed of Entry**: Optimized forms for rapid order creation
- **Visual Clarity**: Clear hierarchy with quantity badges and status indicators
- **iOS Native**: Follows Apple Human Interface Guidelines
- **Accessibility**: VoiceOver support and proper semantic labels