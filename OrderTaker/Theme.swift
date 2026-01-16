import SwiftUI

struct Theme {
    static let primary = Color(red: 79.0/255.0, green: 70.0/255.0, blue: 229.0/255.0) // Indigo 600
    static let success = Color(red: 16.0/255.0, green: 185.0/255.0, blue: 129.0/255.0) // Emerald 500
    static let danger = Color(red: 244.0/255.0, green: 63.0/255.0, blue: 94.0/255.0) // Rose 500
    
    // Adaptive backgrounds for dark mode
    static let background = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let inputBackground = Color(uiColor: .tertiarySystemGroupedBackground)
    
    // Adaptive text colors
    static let primaryText = Color(uiColor: .label)
    static let secondaryText = Color(uiColor: .secondaryLabel)
    static let tertiaryText = Color(uiColor: .tertiaryLabel)
    
    struct Slate {
        static let s400 = Color(uiColor: .tertiaryLabel)
        static let s500 = Color(uiColor: .secondaryLabel)
        static let s600 = Color(uiColor: .secondaryLabel)
        static let s900 = Color(uiColor: .label)
    }
    
    static let cornerRadius: CGFloat = 16
    static let cardCornerRadius: CGFloat = 24
    static let modalCornerRadius: CGFloat = 32
    
    static let headerFont = Font.system(size: 30, weight: .black, design: .rounded)
    static let labelFont = Font.system(size: 10, weight: .black, design: .default)
    static let buttonFont = Font.system(size: 14, weight: .bold)
}

extension View {
    func fieldLabelStyle() -> some View {
        self.font(Theme.labelFont)
            .foregroundColor(Theme.Slate.s500)
    }
}
