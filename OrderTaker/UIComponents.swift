import SwiftUI

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
                .shadow(color: (isDisabled ? Color.clear : Theme.primary.opacity(0.3)), radius: 8, x: 0, y: 4)
        }
        .disabled(isDisabled)
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct OrderCard: View {
    let order: CakeOrder
    var onDuplicate: () -> Void = {}
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}
    var onStatusChange: (String) -> Void = { _ in }
    
    // Formatting helpers
    private var formattedDate: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = inputFormatter.date(from: order.pickupDate) else { return order.pickupDate }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEE, MMM d"
        return outputFormatter.string(from: date)
    }
    
    private var formattedTime: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm"
        guard let date = inputFormatter.date(from: order.pickupTime) else { return order.pickupTime }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        return outputFormatter.string(from: date)
    }
    
    // Source color mapping
    private func sourceColor(for source: String) -> Color {
        let lowercased = source.lowercased()
        if lowercased.contains("marketplace") {
            return Color(red: 139/255, green: 92/255, blue: 246/255) // Purple
        } else if lowercased.contains("instagram") || lowercased.contains("ig") {
            return Color(red: 236/255, green: 72/255, blue: 153/255) // Pink
        } else if lowercased.contains("facebook") || lowercased.contains("fb") {
            return Color(red: 59/255, green: 130/255, blue: 246/255) // Blue
        } else if lowercased.contains("paula") {
            return Color(red: 251/255, green: 146/255, blue: 60/255) // Orange
        } else if lowercased.contains("whatsapp") {
            return Color(red: 34/255, green: 197/255, blue: 94/255) // Green
        } else {
            return Theme.Slate.s500 // Default gray
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Visual Anchor: Quantity Badge
            VStack {
                Text("\(order.quantity)")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(Theme.primary)
                Text("QTY")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(Theme.Slate.s500)
            }
            .frame(width: 50, height: 50)
            .background(Theme.primary.opacity(0.1))
            .cornerRadius(12)
            
            // Middle Content: Info & Details
            VStack(alignment: .leading, spacing: 4) {
                // Customer Name + Source Badge
                HStack(spacing: 6) {
                    Text(order.customerName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.Slate.s900)
                    
                    // Source Badge
                    Text(order.source)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(sourceColor(for: order.source))
                        .cornerRadius(6)
                }
                
                Text(order.itemName)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Slate.s600)
                
                HStack(spacing: 4) {
                    Text("$\(String(format: "%.2f", order.total))")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(Theme.Slate.s900)
                    Text("•")
                        .foregroundColor(Theme.Slate.s400)
                    Text("\(formattedDate) at \(formattedTime)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.Slate.s500)
                }
                
                if !order.notes.isEmpty {
                    Text(order.notes)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Theme.Slate.s500)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            // Right Actions Column
            VStack(alignment: .center, spacing: 12) {
                if order.status == "pending" {
                    Button(action: { onStatusChange("completed") }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.primary)
                            .frame(width: 32, height: 32)
                    }
                    
                    Button(action: onDuplicate) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Theme.Slate.s400)
                            .frame(width: 32, height: 32)
                    }
                } else {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Theme.Slate.s400)
                        .frame(width: 32, height: 32)
                    
                    Button(action: { onStatusChange("pending") }) {
                        Image(systemName: "arrow.uturn.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Theme.Slate.s400)
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }
        .padding(12)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Theme.Slate.s400.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        .contextMenu {
            if order.status != "pending" {
                Button(action: { onStatusChange("pending") }) {
                    Label("Restore to Pending", systemImage: "arrow.uturn.left")
                }
            }
            
            Button(action: onEdit) {
                Label("Edit Order", systemImage: "pencil")
            }
        }
    }
}

struct InputField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .fieldLabelStyle()
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .padding(14)
            .background(Theme.inputBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.clear, lineWidth: 2)
            )
        }
    }
}
