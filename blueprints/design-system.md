
# Design System & UI/UX Blueprint

To maintain uniformity, every new component must adhere to these specific styling patterns:

## Color Palette
- **Background**: `#FDFDFD` (Off-white)
- **Primary**: Indigo (`bg-indigo-600`, `text-indigo-600`)
- **Success**: Emerald (`bg-emerald-500`, `text-emerald-500`)
- **Danger**: Rose (`bg-rose-500`, `text-rose-500`)
- **Accents**: Slate (`text-slate-400/500/900`)

## Typography & Labeling
- **Headers**: `text-3xl font-black tracking-tight`
- **Field Labels**: `text-[10px] font-black text-slate-500 uppercase tracking-[0.1em]`
- **Buttons**: `rounded-xl font-bold text-sm shadow-lg active:scale-95 transition-all`

## Component Anatomy
- **Cards**: `bg-white p-5 rounded-[1.5rem] border border-slate-100 shadow-sm`
- **Modals**: Fixed inset, `bg-slate-900/40` backdrop blur, `rounded-[2rem]` or `rounded-t-[2rem]` for mobile.
- **Inputs**: `bg-slate-50 border-2 border-transparent focus:border-indigo-500 rounded-xl`

## Order Card Hierarchy
To emphasize the product being made:
1.  **Primary**: Item Name (Bold, Slate-900) + Source Badge.
2.  **Secondary**: Customer Name (Slate-600, below Item Name).
3.  **Visual Anchor**: Large Quantity Badge (Left side).
4.  **Meta Data**: Price • Pickup Time (Uppercase, bold, small).

## Mobile-First Principles
- All forms must be optimized for iPhone displays (`max-h-[92vh]` and `overflow-y-auto`).
- Numeric inputs use `inputMode="decimal"` or `inputMode="numeric"` to trigger the correct keypad.
- Use the bottom navigation bar for primary mobile actions.
- Tap targets should be at least 44px in height.
