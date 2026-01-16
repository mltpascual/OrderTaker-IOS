# Design System & UI/UX Blueprint

To maintain uniformity, every new component must adhere to these specific styling patterns based on the **SwiftUI Theme** system.

---

## Color Palette

Defined in `Theme.swift`:

### Static Colors
- **Primary**: Indigo `#4F46E5` → `Theme.primary`
- **Success**: Emerald `#10B981` → `Theme.success`
- **Danger**: Rose `#F43F5E` → `Theme.danger`

### Adaptive Colors (Dark Mode Support)
The app uses iOS system colors that automatically adapt to light/dark mode:

- **Backgrounds**:
  - `Theme.background` → `.systemGroupedBackground` (off-white in light, dark gray in dark)
  - `Theme.cardBackground` → `.secondarySystemGroupedBackground` (white in light, elevated dark in dark)
  - `Theme.inputBackground` → `.tertiarySystemGroupedBackground` (light gray in light, input dark in dark)

- **Text Colors**:  
  - `Theme.primaryText` → `.label` (black in light, white in dark)
  - `Theme.secondaryText` → `.secondaryLabel` (gray in light, light gray in dark)
  - `Theme.tertiaryText` → `.tertiaryLabel`

- **Slate Shades** (now adaptive):
  - `Theme.Slate.s400` → `.tertiaryLabel`
  - `Theme.Slate.s500` → `.secondaryLabel`
  - `Theme.Slate.s600` → `.secondaryLabel`
  - `Theme.Slate.s900` → `.label`

---

## Typography & Labeling

Defined in `Theme.swift`:

- **Headers**: `Theme.headerFont` → SF Pro, 30pt, Black (.black weight)
- **Field Labels**: `Theme.labelFont` → SF Pro, 10pt, Black, Uppercase
- **Buttons**: `Theme.buttonFont` → SF Pro, 14pt, Bold

### Usage Example:
```swift
Text("Order Details")
    .font(Theme.headerFont)
    .foregroundColor(Theme.Slate.s900)
```

---

## Component Anatomy

### Cards
- Background: White
- Padding: 12pt
- Corner Radius: `Theme.cardCornerRadius` (24pt)
- Border: `Theme.Slate.s400.opacity(0.1)`, 1pt
- Shadow: `.shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)`

```swift
VStack { /* content */ }
    .padding(12)
    .background(Color.white)
    .cornerRadius(Theme.cardCornerRadius)
    .overlay(
        RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
            .stroke(Theme.Slate.s400.opacity(0.1), lineWidth: 1)
    )
    .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
```

### Modals
- Presentation: `.sheet()` or `.fullScreenCover()`
- Corner Radius: `Theme.modalCornerRadius` (32pt)
- Background: System background with blur effect

### Input Fields
- Background: `Theme.background`
- Padding: 14pt
- Corner Radius: 12pt
- Focus State: Use `@FocusState` for keyboard management

```swift
TextField("Enter customer name", text: $customerName)
    .padding(14)
    .background(Theme.background)
    .cornerRadius(12)
```

---

## OrderCard Hierarchy

To emphasize the product being made:

1.  **Visual Anchor**: Quantity Badge (Left side, 50x50pt, primary background with opacity)
2.  **Primary Info**: Customer Name (16pt, Bold, Slate 900)
3.  **Secondary Info**: Item Name (14pt, Medium, Slate 600)
4.  **Meta Data**: Price • Pickup Date/Time (12pt, Bold/Medium, Slate 500/900)
5.  **Actions**: Status toggle and duplicate buttons (Right side column)

---

## iOS Native Principles

- **Navigation**: Use `TabView` for primary navigation, `NavigationStack` for hierarchical flows
- **State Management**: `@State`, `@Binding`, `@EnvironmentObject`, `@Published`
- **Modal Presentation**: `.sheet()` for forms, `.alert()` for confirmations
- **Keyboard**: Use `.keyboardType(.decimalPad)` for price inputs, `.keyboardType(.numberPad)` for quantities
- **Gestures**: `.contextMenu` for secondary actions, `.swipeActions()` for quick edits
- **Tap Targets**: Minimum 44x44pt for interactive elements
- **Accessibility**: Use `.accessibilityLabel()` and `.accessibilityHint()` for VoiceOver support

---

## Button Styles

### Primary Button
```swift
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.buttonFont)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isDisabled ? Theme.Slate.s400 : Theme.primary)
                .cornerRadius(Theme.cornerRadius)
                .shadow(color: isDisabled ? .clear : Theme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(isDisabled)
        .buttonStyle(ScaleButtonStyle())
    }
}
```

### Scale Effect
All buttons should use `.buttonStyle(ScaleButtonStyle())` for tactile feedback:
```swift
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
```

---

## New Components

### Sort Filter Button
Menu-style dropdown with current sort option display:
- Icon + Text + Chevron layout
- Fixed minWidth (110pt) to prevent text overflow
- Background: `Theme.cardBackground`
- Rounded corners (8pt)
- 4 sort options: Date (Earliest/Latest), Price (Low/High)

```swift
Menu {
    ForEach(SortOption.allCases, id: \.self) { option in
        Button(action: { sortOption = option }) {
            HStack {
                Text(option.rawValue)
                if sortOption == option {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
} label: {
    HStack(spacing: 6) {
        Image(systemName: "arrow.up.arrow.down")
        Text(sortOption.rawValue)
            .frame(minWidth: 110, alignment: .leading)
        Image(systemName: "chevron.down")
    }
}
```

### Quantity Badge
Used in order cards and summary items:
- 50x50pt rounded square
- Large number (20pt, black weight, primary color)
- "QTY" label below (8pt, bold, slate)
- Background: `Theme.primary.opacity(0.1)`
- Corner radius: 12pt

```swift
VStack {
    Text("\(quantity)")
        .font(.system(size: 20, weight: .black))
        .foregroundColor(Theme.primary)
    Text("QTY")
        .font(.system(size: 8, weight: .bold))
        .foregroundColor(Theme.Slate.s500)
}
.frame(width: 50, height: 50)
.background(Theme.primary.opacity(0.1))
.cornerRadius(12)
```

### Search Bar
Global search input in DashboardView:
- Appears when magnifying glass icon is tapped
- Magnifying glass icon (left) + TextField + Clear button (right)
- Background: `Theme.inputBackground`
- Corner radius: 12pt
- Padding: 14pt horizontal, 12pt vertical
- Placeholder: "Search customer, item, or notes..."

```swift
HStack(spacing: 8) {
    Image(systemName: "magnifyingglass")
        .font(.system(size: 14))
        .foregroundColor(Theme.Slate.s400)
    
    TextField("Search customer, item, or notes...", text: $searchText)
        .font(.system(size: 14))
        .autocapitalization(.none)
        .disableAutocorrection(true)
    
    if !searchText.isEmpty {
        Button(action: { searchText = "" }) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(Theme.Slate.s400)
        }
    }
}
.padding(.horizontal, 14)
.padding(.vertical, 12)
.background(Theme.inputBackground)
.cornerRadius(12)
```

### Category Picker
Segmented picker in MenuView for categorizing items:
- 3 options: Cake | Dessert | Other
- Uses native iOS `.segmented` picker style
- Label: "CATEGORY" (Theme.labelFont)
- Spacing: 8pt between label and picker

```swift
VStack(alignment: .leading, spacing: 8) {
    Text("CATEGORY")
        .font(Theme.labelFont)
        .foregroundColor(Theme.Slate.s500)
    
    Picker("Category", selection: $category) {
        Text("Cake").tag("Cake")
        Text("Dessert").tag("Dessert")
        Text("Other").tag("Other")
    }
    .pickerStyle(.segmented)
}
```

---

## Spacing & Layout

- **Default Padding**: 16pt
- **Card Spacing**: 6pt vertical (top/bottom) between cards = 12pt total gap
- **Form Fields**: 6-8pt spacing between label and input
- **Button Groups**: 12pt spacing between buttons
- **Safe Area**: Always respect `.safeAreaInset` for tab bars and navigation bars
