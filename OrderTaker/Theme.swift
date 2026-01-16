import SwiftUI

struct Theme {
    static let primary = Color(red: 79.0/255.0, green: 70.0/255.0, blue: 229.0/255.0) // Indigo 600
    static let success = Color(red: 16.0/255.0, green: 185.0/255.0, blue: 129.0/255.0) // Emerald 500
    static let danger = Color(red: 244.0/255.0, green: 63.0/255.0, blue: 94.0/255.0) // Rose 500
    static let background = Color(red: 253.0/255.0, green: 253.0/255.0, blue: 253.0/255.0) // Off-white
    
    struct Slate {
        static let s400 = Color(red: 148.0/255.0, green: 163.0/255.0, blue: 184.0/255.0)
        static let s500 = Color(red: 107.0/255.0, green: 114.0/255.0, blue: 128.0/255.0)
        static let s600 = Color(red: 75.0/255.0, green: 85.0/255.0, blue: 99.0/255.0)
        static let s900 = Color(red: 15.0/255.0, green: 23.0/255.0, blue: 42.0/255.0)
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
