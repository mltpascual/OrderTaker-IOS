# Design System & UI/UX Blueprint

To maintain uniformity, every new component must adhere to these specific styling patterns based on the **SwiftUI Theme** system.

---

## Color Palette

Defined in `Theme.swift`:

- **Background**: `#FDFDFD` (Off-white) → `Theme.background`
- **Primary**: Indigo `#4F46E5` → `Theme.primary`
- **Success**: Emerald `#10B981` → `Theme.success`
- **Danger**: Rose `#F43F5E` → `Theme.danger`
- **Slate Shades**: 
  - `Theme.Slate.s400` → `#94A3B8`
  - `Theme.Slate.s500` → `#6B7280`
  - `Theme.Slate.s600` → `#4B5563`
  - `Theme.Slate.s900` → `#0F172A`

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

## Spacing & Layout

- **Default Padding**: 16pt
- **Card Spacing**: 8-12pt vertical spacing between cards
- **Form Fields**: 6-8pt spacing between label and input
- **Button Groups**: 12pt spacing between buttons
- **Safe Area**: Always respect `.safeAreaInset` for tab bars and navigation bars
