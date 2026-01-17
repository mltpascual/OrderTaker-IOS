import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import UIKit

class StoreService: ObservableObject {
    @Published var orders: [CakeOrder] = []
    @Published var menuItems: [CakeItem] = []
    @Published var currentUser: UserProfile?
    
    private var db = Firestore.firestore()
    internal var auth = Auth.auth()
    
    private var ordersListener: ListenerRegistration?
    private var menuListener: ListenerRegistration?
    private var userListener: ListenerRegistration?
    
    var isUserLoggedIn: Bool {
        auth.currentUser != nil
    }
    
    init() {
        // We handle fetching in signIn() which is triggered by onAppear in ContentView
    }
    
    // MARK: - Auth
    func signIn() {
        print("DEBUG: Starting auth listener...")
        
        // Clear existing listeners if any (e.g. if re-signing in)
        ordersListener?.remove()
        menuListener?.remove()
        userListener?.remove()
        
        // If user is already logged in, fetch immediately
        if let user = auth.currentUser {
            print("DEBUG: User already logged in: \(user.uid)")
            self.fetchUserProfile(uid: user.uid)
            self.fetchOrders()
            self.fetchMenu()
        }
        
        auth.addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                print("DEBUG: Auth State Changed -> Logged In: \(user.uid)")
                self?.fetchUserProfile(uid: user.uid)
                self?.fetchOrders()
                self?.fetchMenu()
            } else {
                print("DEBUG: Auth State Changed -> Logged Out")
                self?.ordersListener?.remove()
                self?.menuListener?.remove()
                self?.userListener?.remove()
                self?.currentUser = nil
                self?.orders = []
                self?.menuItems = []
            }
        }
    }
    
    func emailSignIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error)
                return
            }
            
            // Check if email is verified
            guard let user = authResult?.user else {
                completion(error)
                return
            }
            
            if !user.isEmailVerified {
                // Don't sign out - keep them logged in but show verification screen
                let verificationError = NSError(
                    domain: "EmailVerificationError",
                    code: 1001,
                    userInfo: [NSLocalizedDescriptionKey: "Please verify your email address before continuing."]
                )
                completion(verificationError)
            } else {
                completion(nil)
            }
        }
    }
    
    func emailSignUp(email: String, password: String, fullName: String, completion: @escaping (Error?) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let user = result?.user else {
                completion(error)
                return
            }
            
            // Create user profile in Firestore
            let uid = user.uid
            let profile = UserProfile(id: uid, fullName: fullName, email: email, createdAt: ISO8601DateFormatter().string(from: Date()), role: "user")
            try? self.db.collection("users").document(uid).setData(from: profile)
            
            // Send email verification
            user.sendEmailVerification { verificationError in
                if let verificationError = verificationError {
                    completion(verificationError)
                } else {
                    // Don't sign out - keep user logged in but show verification screen
                    // Return custom error to indicate verification needed
                    let verificationNeeded = NSError(
                        domain: "EmailVerificationNeeded",
                        code: 2001,
                        userInfo: [NSLocalizedDescriptionKey: "Verification email sent! Please check your inbox."]
                    )
                    completion(verificationNeeded)
                }
            }
        }
    }
    
    func sendPasswordReset(email: String, completion: @escaping (Error?) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    
    // MARK: - Google Sign-In
    func googleSignIn(completion: @escaping (Error?) -> Void) {
        // Get the root view controller to present Google Sign-In
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            let error = NSError(
                domain: "GoogleSignInError",
                code: 5001,
                userInfo: [NSLocalizedDescriptionKey: "Unable to present sign-in screen."]
            )
            completion(error)
            return
        }
        
        // Configure Google Sign-In
        guard let clientID = auth.app?.options.clientID else {
            let error = NSError(
                domain: "GoogleSignInError",
                code: 5002,
                userInfo: [NSLocalizedDescriptionKey: "Google Sign-In configuration error."]
            )
            completion(error)
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start Google Sign-In flow
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                let error = NSError(
                    domain: "GoogleSignInError",
                    code: 5003,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to get user credentials."]
                )
                completion(error)
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            // Sign in to Firebase with Google credential
            self.auth.signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                // Check if this is a new user and create profile
                if let firebaseUser = authResult?.user, authResult?.additionalUserInfo?.isNewUser == true {
                    let profile = UserProfile(
                        id: firebaseUser.uid,
                        fullName: firebaseUser.displayName ?? "User",
                        email: firebaseUser.email ?? "",
                        createdAt: ISO8601DateFormatter().string(from: Date()),
                        role: "user"
                    )
                    try? self.db.collection("users").document(firebaseUser.uid).setData(from: profile)
                }
                
                completion(nil)
            }
        }
    }


    
    func signOut() {
        ordersListener?.remove()
        menuListener?.remove()
        userListener?.remove()
        try? auth.signOut()
    }
    
    private func fetchUserProfile(uid: String) {
        userListener?.remove()
        userListener = db.collection("users").document(uid).addSnapshotListener { snapshot, _ in
            guard let snapshot = snapshot else { return }
            self.currentUser = try? snapshot.data(as: UserProfile.self)
        }
    }
    
    // MARK: - Orders
    func fetchOrders() {
        guard let uid = auth.currentUser?.uid else { return }
        
        ordersListener?.remove()
        print("DEBUG: Starting orders listener for \(uid)")
        
        // Remove ordering from Firestore query to avoid composite index requirement
        // Orders will be sorted in the UI layer instead
        ordersListener = db.collection("users").document(uid).collection("orders")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                guard let documents = querySnapshot?.documents else {
                    print("DEBUG: Error fetching orders: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                print("DEBUG: Real-time update: \(documents.count) orders synced.")
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                    // Sort orders by pickup date and time in-memory
                    self.orders = documents.compactMap { try? $0.data(as: CakeOrder.self) }
                        .sorted { order1, order2 in
                            if order1.pickupDate == order2.pickupDate {
                                return order1.pickupTime < order2.pickupTime
                            }
                            return order1.pickupDate < order2.pickupDate
                        }
                }
            }
    }
    
    func addOrder(_ order: CakeOrder) {
        guard let uid = auth.currentUser?.uid else { return }
        print("DEBUG: Adding order...")
        do {
            // Optimistic Update: Append locally immediately
            // Note: The real ID is generated by Firestore, so we might have a temporary mismatch until sync,
            // but for UI responsiveness this helps. The listener will correct it shortly.
            self.orders.append(order)
            
            _ = try db.collection("users").document(uid).collection("orders").addDocument(from: order)
        } catch {
            print("Error adding order: \(error.localizedDescription)")
            // Revert on error if needed, but listener will usually fix sync
            self.fetchOrders() 
        }
    }
    
    func updateOrderStatus(orderId: String, status: String) {
        guard let uid = auth.currentUser?.uid else { return }
        print("DEBUG: Updating status to \(status) for \(orderId)")
        
        // Optimistic Update
        if let index = self.orders.firstIndex(where: { $0.id == orderId }) {
            DispatchQueue.main.async {
                self.orders[index].status = status
            }
        }
        
        db.collection("users").document(uid).collection("orders").document(orderId).updateData(["status": status])
    }
    
    func updateOrder(_ order: CakeOrder) {
        guard let uid = auth.currentUser?.uid, let orderId = order.id else { return }
        print("DEBUG: Updating order \(orderId)")
        
        // Optimistic Update
        if let index = self.orders.firstIndex(where: { $0.id == orderId }) {
            DispatchQueue.main.async {
                self.orders[index] = order
            }
        }
        
        do {
            try db.collection("users").document(uid).collection("orders").document(orderId).setData(from: order)
        } catch {
            print("DEBUG: Error updating order: \(error.localizedDescription)")
        }
    }
    
    func deleteOrder(orderId: String) {
        guard let uid = auth.currentUser?.uid else { return }
        print("DEBUG: Deleting order \(orderId)")
        
        // Optimistic Update
        DispatchQueue.main.async {
            self.orders.removeAll { $0.id == orderId }
        }
        
        db.collection("users").document(uid).collection("orders").document(orderId).delete()
    }
    
    // MARK: - Menu
    // MARK: - Menu
    func fetchMenu() {
        guard let uid = auth.currentUser?.uid else { return }
        
        menuListener?.remove()
        print("DEBUG: Starting menu listener for \(uid)")
        menuListener = db.collection("users").document(uid).collection("menu").addSnapshotListener { [weak self] querySnapshot, _ in
            guard let self = self else { return }
            guard let documents = querySnapshot?.documents else { return }
            print("DEBUG: Real-time update: \(documents.count) menu items synced.")
            DispatchQueue.main.async {
                self.objectWillChange.send()
                self.menuItems = documents.compactMap { try? $0.data(as: CakeItem.self) }
            }
        }
    }
    
    func addMenuItem(_ item: CakeItem) {
        guard let uid = auth.currentUser?.uid else { return }
        print("DEBUG: Adding menu item locally...")
        
        // Optimistic Update
        self.menuItems.append(item)
        
        do {
            _ = try db.collection("users").document(uid).collection("menu").addDocument(from: item)
        } catch {
            print("Error adding menu item: \(error.localizedDescription)")
            self.fetchMenu()
        }
    }
    
    func deleteMenuItem(itemId: String) {
        guard let uid = auth.currentUser?.uid else { return }
        print("DEBUG: Deleting menu item \(itemId)")
        
        // Optimistic Update
        DispatchQueue.main.async {
            self.menuItems.removeAll { $0.id == itemId }
        }
        
        db.collection("users").document(uid).collection("menu").document(itemId).delete()
    }
    
    func updateMenuItem(_ item: CakeItem) {
        guard let uid = auth.currentUser?.uid, let itemId = item.id else { return }
        print("DEBUG: Updating menu item \(itemId)")
        
        // Optimistic Update
        if let index = self.menuItems.firstIndex(where: { $0.id == itemId }) {
            DispatchQueue.main.async {
                self.menuItems[index] = item
            }
        }
        
        do {
            try db.collection("users").document(uid).collection("menu").document(itemId).setData(from: item)
        } catch {
            print("Error updating menu item: \(error.localizedDescription)")
            self.fetchMenu()
        }
    }
    
    // MARK: - CSV Export/Import
    func exportOrdersToCSV() -> String {
        print("📊 Exporting \(orders.count) orders to CSV")
        var csvString = "Date\tTime\tOrder\tQuantity\tCost\tName\tStatus\tNotes\tSource\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let displayDateFormatter = DateFormatter()
        displayDateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        displayDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let displayTimeFormatter = DateFormatter()
        displayTimeFormatter.dateFormat = "h:mm a"
        displayTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for order in orders.sorted(by: { $0.pickupDate < $1.pickupDate }) {
            // Convert pickup date to display format
            let displayDate: String
            if let date = dateFormatter.date(from: order.pickupDate) {
                displayDate = displayDateFormatter.string(from: date)
            } else {
                displayDate = order.pickupDate
            }
            
            // Convert pickup time to display format
            let displayTime: String
            if let time = timeFormatter.date(from: order.pickupTime) {
                displayTime = displayTimeFormatter.string(from: time)
            } else {
                displayTime = order.pickupTime
            }
            
            let row = [
                displayDate,
                displayTime,
                order.itemName,
                "\(order.quantity)",
                String(format: "$%.2f", order.total),
                order.customerName,
                order.status.capitalized,
                order.notes,
                order.source
            ].joined(separator: "\t")
            
            csvString += row + "\n"
        }
        
        return csvString
    }
    

    
    func exportMenuToCSV() -> String {
        print("🍰 Exporting \(menuItems.count) menu items to CSV")
        var csvString = "Item Name\tBase Price\n"
        
        for item in menuItems.sorted(by: { $0.name < $1.name }) {
            let row = [
                item.name,
                String(format: "$%.2f", item.basePrice)
            ].joined(separator: "\t")
            
            csvString += row + "\n"
        }
        
        return csvString
    }
    
    func importOrdersFromCSV(_ csvString: String) -> (imported: Int, errors: Int) {
        guard let uid = auth.currentUser?.uid else { return (0, 0) }
        
        let lines = csvString.components(separatedBy: "\n")
        guard lines.count > 1 else { return (0, 0) }
        
        // ... formatters ...
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Fix: Ensure consistent date parsing
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let timeFormatter24 = DateFormatter()
        timeFormatter24.dateFormat = "HH:mm"
        timeFormatter24.locale = Locale(identifier: "en_US_POSIX")
        
        let storageDateFormatter = DateFormatter()
        storageDateFormatter.dateFormat = "yyyy-MM-dd"
        storageDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let storageTimeFormatter = DateFormatter()
        storageTimeFormatter.dateFormat = "HH:mm"
        storageTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var importCount = 0
        var errorCount = 0
        
        // Skip header row
        for i in 1..<lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }
            
            // Fix: Handle tabs that might have been converted to spaces or invisible chars
            // Check if line uses commas instead of tabs (Excel CSV export issue)
            let fields: [String]
            if line.contains("\t") {
                 fields = line.components(separatedBy: "\t").map { $0.trimmingCharacters(in: .whitespaces) }
            } else {
                // Fallback: Try comma separation (simple split, doesn't handle quoted commas)
                fields = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            }

            // Fix: Allow 8 fields if 'Source' is missing/empty at end
            guard fields.count >= 8 else { 
                print("⚠️ Skipping invalid row \(i): expected 9 fields, got \(fields.count). Line: \(line)")
                errorCount += 1
                continue 
            }
            
            // ... parsing logic ...
            
            // Parse date
            let pickupDate: String
            if let date = dateFormatter.date(from: fields[0]) {
                pickupDate = storageDateFormatter.string(from: date)
            } else {
                // Fallback: Try parsing yyyy-MM-dd directly
                if let date = storageDateFormatter.date(from: fields[0]) {
                     pickupDate = storageDateFormatter.string(from: date)
                } else {
                     pickupDate = fields[0] // Store raw string if all else fails
                }
            }
          
            // Parse time...
            let pickupTime: String
             if fields.count > 1 {
                if let time = timeFormatter.date(from: fields[1]) {
                    pickupTime = storageTimeFormatter.string(from: time)
                } else if let time = timeFormatter24.date(from: fields[1]) {
                    pickupTime = storageTimeFormatter.string(from: time)
                } else {
                    pickupTime = fields[1]
                }
            } else {
                pickupTime = ""
            }

            // Check bounds for other fields
            let orderName = fields.count > 2 ? fields[2] : "Unknown"
            let customerName = fields.count > 5 ? fields[5] : "Unknown"
            let quantity = fields.count > 3 ? (Int(fields[3]) ?? 1) : 1
            
            // Cost
            var cost = 0.0
            if fields.count > 4 {
                let costString = fields[4].replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)
                 cost = Double(costString) ?? 0.0
            }
            
            let status = fields.count > 6 ? fields[6].lowercased() : "pending"
            let notes = fields.count > 7 ? fields[7] : ""
            let source = fields.count > 8 ? fields[8] : ""
            
            let order = CakeOrder(
                itemName: orderName,
                customerName: customerName,
                quantity: quantity,
                total: cost,
                notes: notes,
                source: source,
                timestamp: ISO8601DateFormatter().string(from: Date()),
                pickupDate: pickupDate,
                pickupTime: pickupTime,
                status: status
            )
            
            do {
                _ = try db.collection("users").document(uid).collection("orders").addDocument(from: order)
                importCount += 1
            } catch {
                print("❌ Error importing order row \(i): \(error.localizedDescription)")
                errorCount += 1
            }
        }
        
        print("✅ Import complete: \(importCount) orders imported, \(errorCount) errors")
        fetchOrders()
        return (importCount, errorCount)
    }
    

    
    func importMenuFromCSV(_ csvString: String) -> (imported: Int, errors: Int) {
        guard let uid = auth.currentUser?.uid else { return (0, 0) }
        
        let lines = csvString.components(separatedBy: "\n")
        guard lines.count > 1 else { return (0, 0) }
        
        var importCount = 0
        var errorCount = 0
        
        // Skip header row
        for i in 1..<lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }
            
            let fields: [String]
            if line.contains("\t") {
                 fields = line.components(separatedBy: "\t").map { $0.trimmingCharacters(in: .whitespaces) }
            } else {
                fields = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            }
            
            guard fields.count >= 2 else { 
                print("⚠️ Skipping invalid menu row \(i): expected 2 fields, got \(fields.count)")
                errorCount += 1
                continue 
            }
            
            // Parse price (remove $ sign)
            let priceString = fields[1].replacingOccurrences(of: "$", with: "")
            
            let menuItem = CakeItem(
                name: fields[0],
                basePrice: Double(priceString) ?? 0.0
            )
            
            // Add to Firestore
            do {
                _ = try db.collection("users").document(uid).collection("menu").addDocument(from: menuItem)
                importCount += 1
            } catch {
                print("Error importing menu item: \(error.localizedDescription)")
                errorCount += 1
            }
        }
        
        // Refresh menu after import
        fetchMenu()
        return (importCount, errorCount)
    }
}
