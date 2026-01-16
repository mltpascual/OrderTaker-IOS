import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var store: StoreService
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var csvDataToExport: String = ""
    @State private var importType: ImportType = .orders
    
    enum ImportType {
        case orders
        case menu
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Settings")
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
                    VStack(spacing: 20) {
                        // Appearance Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("APPEARANCE")
                                .fieldLabelStyle()
                                .padding(.horizontal, 24)
                            
                            HStack {
                                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .foregroundColor(Theme.primary)
                                    .font(.system(size: 20))
                                
                                Text("Dark Mode")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Theme.Slate.s900)
                                
                                Spacer()
                                
                                Toggle("", isOn: $isDarkMode)
                                    .labelsHidden()
                            }
                            .padding(16)
                            .background(Theme.cardBackground)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                            .padding(.horizontal, 24)
                        }
                        
                        // Data Management Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DATA MANAGEMENT")
                                .fieldLabelStyle()
                                .padding(.horizontal, 24)
                            
                            Button(action: {
                                csvDataToExport = store.exportOrdersToCSV()
                                showingExportSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.up.doc.fill")
                                        .foregroundColor(store.orders.isEmpty ? Theme.Slate.s400 : Theme.primary)
                                        .font(.system(size: 20))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Export Orders to CSV")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Theme.Slate.s900)
                                        
                                        Text("\(store.orders.count) orders")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(Theme.Slate.s500)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Theme.Slate.s400)
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .padding(16)
                                .background(Theme.cardBackground)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                            }
                            .disabled(store.orders.isEmpty)
                            .opacity(store.orders.isEmpty ? 0.5 : 1.0)
                            .padding(.horizontal, 24)
                            
                            Button(action: {
                                importType = .orders
                                showingImportPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.down.doc.fill")
                                        .foregroundColor(Theme.primary)
                                        .font(.system(size: 20))
                                    
                                    Text("Import Orders from CSV")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Theme.Slate.s900)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Theme.Slate.s400)
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .padding(16)
                                .background(Theme.cardBackground)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                            }
                            .padding(.horizontal, 24)
                            
                            Divider()
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                            
                            Button(action: {
                                csvDataToExport = store.exportMenuToCSV()
                                showingExportSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.up.doc.fill")
                                        .foregroundColor(store.menuItems.isEmpty ? Theme.Slate.s400 : Theme.success)
                                        .font(.system(size: 20))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Export Menu to CSV")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Theme.Slate.s900)
                                        
                                        Text("\(store.menuItems.count) items")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(Theme.Slate.s500)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Theme.Slate.s400)
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .padding(16)
                                .background(Theme.cardBackground)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                            }
                            .disabled(store.menuItems.isEmpty)
                            .opacity(store.menuItems.isEmpty ? 0.5 : 1.0)
                            .padding(.horizontal, 24)
                            
                            Button(action: {
                                importType = .menu
                                showingImportPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.down.doc.fill")
                                        .foregroundColor(Theme.success)
                                        .font(.system(size: 20))
                                    
                                    Text("Import Menu from CSV")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Theme.Slate.s900)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Theme.Slate.s400)
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .padding(16)
                                .background(Theme.cardBackground)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Account Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ACCOUNT")
                                .fieldLabelStyle()
                                .padding(.horizontal, 24)
                            
                            Button(action: {
                                store.signOut()
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(Theme.danger)
                                        .font(.system(size: 20))
                                    
                                    Text("Sign Out")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Theme.danger)
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(Theme.cardBackground)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .preferredColorScheme(isDarkMode ? .dark : .light) // Apply dark mode immediately
            .sheet(isPresented: $showingExportSheet) {
                ShareSheet(items: [csvDataToExport])
            }
            .sheet(isPresented: $showingImportPicker) {
                DocumentPicker { url in
                    if let csvString = try? String(contentsOf: url, encoding: .utf8) {
                        if importType == .orders {
                            store.importOrdersFromCSV(csvString)
                        } else {
                            store.importMenuFromCSV(csvString)
                        }
                    }
                }
            }
        }
    }
}

// Document Picker for CSV Import
struct DocumentPicker: UIViewControllerRepresentable {
    let onPick: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.commaSeparatedText, .plainText])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        
        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}

// Share Sheet for CSV Export
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        guard let csvString = items.first as? String else {
            print("❌ CSV Export Error: No CSV string provided")
            let errorText = "Export failed. Please try again."
            return UIActivityViewController(activityItems: [errorText], applicationActivities: nil)
        }
        
        // Check if there's actual data (more than just header row)
        let lines = csvString.components(separatedBy: "\n").filter { !$0.isEmpty }
        if lines.count <= 1 {
            print("❌ CSV Export Error: Only header row, no data. Lines: \(lines.count)")
            let errorText = "No data to export. Add some orders or menu items first."
            return UIActivityViewController(activityItems: [errorText], applicationActivities: nil)
        }
        
        // Use .tsv extension for tab-separated values
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let fileName = "ordertaker_export_\(timestamp).tsv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        print("📄 Exporting CSV to: \(tempURL.path)")
        print("📊 CSV Length: \(csvString.count) characters")
        
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            print("✅ CSV file created successfully")
            
            // Verify file was written
            if let fileSize = try? FileManager.default.attributesOfItem(atPath: tempURL.path)[.size] as? Int {
                print("📦 File size: \(fileSize) bytes")
            }
        } catch {
            print("❌ Error writing CSV: \(error)")
        }
        
        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { activity, completed, returnedItems, error in
            if let error = error {
                print("❌ Share error: \(error)")
            } else if completed {
                print("✅ Share completed with activity: \(activity?.rawValue ?? "unknown")")
            }
        }
        
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .environmentObject(StoreService())
}
