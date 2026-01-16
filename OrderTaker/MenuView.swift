import SwiftUI

struct MenuView: View {
    @EnvironmentObject var store: StoreService
    
    @State private var showingAddSheet = false
    @State private var editingItem: CakeItem?
    @State private var itemToDelete: CakeItem?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Menu Management")
                        .font(Theme.headerFont)
                        .foregroundColor(Theme.Slate.s900)
                    
                    Text("\(store.menuItems.count) ITEMS IN CATALOG")
                        .font(Theme.labelFont)
                        .foregroundColor(Theme.Slate.s500)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                List {
                    ForEach(store.menuItems.sorted { $0.name < $1.name }) { item in
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Theme.primary.opacity(0.1))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "birthday.cake.fill")
                                        .foregroundColor(Theme.primary)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.Slate.s900)
                                Text("$\(String(format: "%.2f", item.basePrice))")
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.Slate.s600)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, -5)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                itemToDelete = item
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                editingItem = item
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(Theme.Slate.s400)
                        }
                    }
                }
                .listStyle(.plain)
                .padding(.horizontal, 8)
                .refreshable {
                    store.fetchMenu()
                }
                
                Spacer()
                
                PrimaryButton(title: "ADD NEW ITEM", action: { showingAddSheet = true })
                    .padding(24)
                    .padding(.bottom, 80)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddSheet) {
                MenuFormView(store: store, itemToEdit: nil)
            }
            .sheet(item: $editingItem) { item in
                MenuFormView(store: store, itemToEdit: item)
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Item?"),
                    message: Text("Are you sure you want to delete \(itemToDelete?.name ?? "this item")?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let id = itemToDelete?.id {
                            store.deleteMenuItem(itemId: id)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct MenuFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var store: StoreService
    let itemToEdit: CakeItem?
    
    @State private var name: String = ""
    @State private var price: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    InputField(label: "Item Name", text: $name, placeholder: "e.g. Chocolate Cake")
                    InputField(label: "Base Price", text: $price, placeholder: "0.00")
                        .keyboardType(.decimalPad)
                }
                
                PrimaryButton(title: itemToEdit == nil ? "Save Item" : "Update Item", action: {
                    guard !name.isEmpty, let priceValue = Double(price) else { return }
                    
                    if let existingItem = itemToEdit {
                        // Update
                        var updatedItem = existingItem
                        // Create a new struct with updated values (since properties are let)
                        updatedItem = CakeItem(id: existingItem.id, name: name, basePrice: priceValue)
                        store.updateMenuItem(updatedItem)
                    } else {
                        // Create
                        let newItem = CakeItem(name: name, basePrice: priceValue)
                        store.addMenuItem(newItem)
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                })
                
                Spacer()
            }
            .padding(24)
            .navigationTitle(itemToEdit == nil ? "New Menu Item" : "Edit Item")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            if let item = itemToEdit {
                name = item.name
                price = String(format: "%.2f", item.basePrice)
            }
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(StoreService())
}
