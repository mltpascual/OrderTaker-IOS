# Project Overview: OrderTaker PWA

## Mission
OrderTaker is a high-end, professional Order Management System (OMS) designed specifically for boutique bakeries and small businesses. It prioritizes speed of entry, mobile-first responsiveness, and a premium aesthetic.

## Tech Stack
- **Frontend**: React 19 (Vite)
- **Styling**: Tailwind CSS (Utility-first, with specific custom design tokens)
- **Backend/Auth**: Firebase (Authentication, Firestore ready)
- **Environment**: Configuration via `.env` files for security.
- **Icons/Visuals**: Inline SVG with 2.5px stroke width for a "bold" premium feel.
- **Fonts**: Inter (Sans-serif), heavy usage of `font-black` (900) for headers and labels.

## Current State
The app is currently a single-page PWA with:
1. **Authentication**: Email/Password and Google Login with automatic User Profile creation in Firestore.
2. **Order Management**: 
   - CRUD operations for cake orders.
   - **Smart Sorting**: Default sorting by 'Earliest Pickup' (Date + Time) to prioritize immediate deadlines.
   - **Enhanced Validation**: Strict constraints ensuring Pickup Date and Time are entered before confirmation.
3. **Menu Management**: Dynamic menu items that populate the order form.
4. **Queue Logic**: Automated filtering for 'Today' (Pending only), 'Pending', and 'Completed' orders.
5. **Sales Reports**: A dedicated section providing key performance indicators (KPIs), top-selling items, and order source breakdowns for business insights.