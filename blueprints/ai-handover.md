# AI Agent Handover Protocol

## 🤖 Context for the Next Agent
This document serves as the primary context injection point for any AI agent taking over development of the **OrderTaker PWA**. It summarizes the architectural decisions, file structure, and business logic constraints currently in place.

---

## 🏗️ Core Architecture (Crucial)

### 1. Vite & ESM Setup
*   **Environment**: This project uses **Vite** as the build tool and development server.
*   **Dependencies**: Packages are managed via `npm` and installed in `node_modules`.
*   **Configuration**: Environment variables are managed via `.env` files. Use `import.meta.env.VITE_*` in the code.

### 2. Backend Strategy (Firebase)
*   **Auth**: Google & Email/Password.
*   **Database**: Cloud Firestore.
*   **Data Isolation**: All data is scoped to the user.
    *   `users/{uid}/orders/{orderId}`
    *   `users/{uid}/menu/{menuId}`
*   **Realtime**: State in `App.tsx` is driven by `onSnapshot` listeners. Do not rely on manual `fetch` calls for reading data; rely on the listener to update the state automatically.

---

## 📂 File System Map

*   **`index.html`**: The shell. Contains the Import Map, Tailwind CDN, and Font imports.
*   **`firebase.ts`**: Centralized export for all Firebase functions. Edit this if adding new Firebase services (e.g., Storage).
*   **`App.tsx`**: The main controller.
    *   Manages Global State (`orders`, `menu`).
    *   Handles Routing (via `activeTab` state).
    *   Contains the core layout (Navbar, Mobile Tab Bar).
*   **`components/OrderForm.tsx`**: The heaviest component.
    *   Handles validation logic.
    *   Manages "Custom Item" logic vs "Menu Selection".
    *   Handles date/time inputs.
*   **`components/SalesReports.tsx`**:
    *   Pure client-side calculation of KPIs.
    *   Receives `orders` array and derives stats (Revenue, Pipeline, Top Items).
*   **`blueprints/`**:
    *   `design-system.md`: UI rules (Colors, Typography).
    *   `technical-architecture.md`: Data schemas and Business Logic.
    *   `project-overview.md`: High-level goals.

---

## 🧠 Business Logic & Rules

### Order Processing
1.  **Validation**: An order cannot be submitted without a Name, Item, Source, Pickup Date, and Time.
2.  **Date Handling**: Use local date strings (`YYYY-MM-DD`). Avoid UTC conversions for pickup dates to prevent "off-by-one-day" errors.
3.  **Status**: Orders are binary: `'pending'` or `'completed'`.
4.  **Source Tracking**: Critical for the marketing report. Defaults to 'Marketplace'.

### UI/UX Standards
1.  **Mobile First**: Ensure bottom padding (`pb-24`) exists on main containers so content isn't hidden behind the fixed mobile nav bar.
2.  **Input Modes**: Always use `inputMode="decimal"` for prices to trigger the correct mobile keyboard.
3.  **Feedback**: Use the existing Modal patterns for confirmations (Rose for delete, Emerald for complete).

---

## 🔮 Future Trajectory / Known Context
*   The app is designed to look "Premium" (Boutique Bakery style).
*   Current focus is on "Speed of Entry" and "Visual Clarity".
*   Next logical steps (if requested) might involve:
    *   Search functionality.
    *   Export to CSV.
    *   Image attachments for cake designs (requires Firebase Storage).

---

**Instruction to Agent**: When making changes, always check `blueprints/design-system.md` to ensure you are using the correct Tailwind utility classes (e.g., `font-black`, `text-slate-900`, `rounded-[1.5rem]`).
