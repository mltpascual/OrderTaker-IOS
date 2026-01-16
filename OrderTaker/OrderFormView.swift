import SwiftUI

struct OrderFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: StoreService
    
    // Existing order for editing
    var editingOrder: CakeOrder?
    
    @State private var customerName: String = ""
    @State private var itemName: String = ""
    @State private var quantity: String = "1"
    @State private var total: String = ""
    @State private var source: String = "Marketplace"
    @State private var notes: String = ""
    @State private var pickupDate: Date = Date()
    @State private var pickupTime: Date = Date()
    
    @State private var isSubmitting = false
    
    let sources = ["Marketplace", "Paula", "Instagram", "FB Page"]

    
    var isFormValid: Bool {
        !customerName.isEmpty && !itemName.isEmpty && !total.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(editingOrder == nil ? "New Order" : "Edit Order")
                    .font(Theme.headerFont)
                    .foregroundColor(Theme.Slate.s900)
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Theme.Slate.s400)
                }
            }
            .padding(24)
            
            ScrollView {
                VStack(spacing: 24) {
                    InputField(label: "CUSTOMER NAME", text: $customerName, placeholder: "e.g. John Doe")
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("SELECT ITEM")
                            .fieldLabelStyle()
                        
                        TextField("e.g. Chocolate Cake", text: $itemName)
                            .padding(14)
                            .background(Theme.background)
                            .cornerRadius(12)
                    }
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("QUANTITY")
                                .fieldLabelStyle()
                            TextField("1", text: $quantity)
                                .keyboardType(.numberPad)
                                .padding(14)
                                .background(Theme.background)
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("TOTAL PRICE")
                                .fieldLabelStyle()
                            TextField("0.00", text: $total)
                                .keyboardType(.decimalPad)
                                .padding(14)
                                .background(Theme.background)
                                .cornerRadius(12)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ORDER SOURCE")
                            .fieldLabelStyle()
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(sources, id: \.self) { s in
                                    Button(action: { source = s }) {
                                        Text(s)
                                            .font(.system(size: 12, weight: .bold))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(source == s ? Theme.primary : Color.white)
                                            .foregroundColor(source == s ? .white : Theme.Slate.s600)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Theme.Slate.s400.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PICKUP DATE")
                                .fieldLabelStyle()
                            DatePicker("", selection: $pickupDate, displayedComponents: .date)
                                .labelsHidden()
                                .padding(8)
                                .background(Theme.background)
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PICKUP TIME")
                                .fieldLabelStyle()
                            DatePicker("", selection: $pickupTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .padding(8)
                                .background(Theme.background)
                                .cornerRadius(12)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NOTES")
                            .fieldLabelStyle()
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .padding(8)
                            .background(Theme.background)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Theme.Slate.s400.opacity(0.1), lineWidth: 1)
                            )
                    }
                    
                    if !isFormValid && !isSubmitting {
                        Text("Please fill name, cake item, and price.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.danger.opacity(0.8))
                            .padding(.top, 4)
                    }
                    
                    PrimaryButton(
                        title: isSubmitting ? "SAVING..." : (editingOrder == nil ? "CONFIRM ORDER" : "UPDATE ORDER"),
                        action: {
                            isSubmitting = true
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd"
                            let dateStr = formatter.string(from: pickupDate)
                            
                            formatter.dateFormat = "HH:mm"
                            let timeStr = formatter.string(from: pickupTime)
                            
                            var updatedOrder = CakeOrder(
                                itemName: itemName,
                                customerName: customerName,
                                quantity: Int(quantity) ?? 1,
                                total: Double(total.replacingOccurrences(of: ",", with: ".")) ?? 0.0,
                                notes: notes,
                                source: source,
                                timestamp: editingOrder?.timestamp ?? ISO8601DateFormatter().string(from: Date()),
                                pickupDate: dateStr,
                                pickupTime: timeStr,
                                status: editingOrder?.status ?? "pending"
                            )
                            
                            if let original = editingOrder {
                                updatedOrder.id = original.id
                                store.updateOrder(updatedOrder)
                            } else {
                                store.addOrder(updatedOrder)
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        },
                        isDisabled: !isFormValid || isSubmitting
                    )
                    .padding(.top, 4)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .cornerRadius(Theme.modalCornerRadius, corners: [.topLeft, .topRight])
        .onAppear {
            if let order = editingOrder {
                customerName = order.customerName
                itemName = order.itemName
                quantity = "\(order.quantity)"
                total = String(format: "%.2f", order.total)
                source = order.source
                notes = order.notes
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                if let date = formatter.date(from: order.pickupDate) {
                    pickupDate = date
                }
                
                formatter.dateFormat = "HH:mm"
                if let time = formatter.date(from: order.pickupTime) {
                    pickupTime = time
                }
            }
        }
    }
}

// Helper for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    OrderFormView()
        .environmentObject(StoreService())
}
