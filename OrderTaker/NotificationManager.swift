import UserNotifications
import UIKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Allow notifications to show even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    // Request permission for push notifications
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("DEBUG: Notification permission granted")
            } else if let error = error {
                print("DEBUG: Notification permission error: \(error.localizedDescription)")
            } else {
                print("DEBUG: Notification permission denied")
            }
        }
    }
    
    // Schedule notifications for a specific order
    func scheduleForOrder(_ order: CakeOrder) {
        // We need a valid ID to schedule
        guard let orderId = order.id else { return }
        
        // Convert pickup date/time strings to Date object
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Avoid user locale issues
        formatter.timeZone = TimeZone.current // Ensure we use device local time
        
        guard let pickupDate = formatter.date(from: "\(order.pickupDate) \(order.pickupTime)") else {
            print("DEBUG: Invalid date format for order \(orderId). Pickup: \(order.pickupDate) \(order.pickupTime)")
            return
        }
        
        // Calculate trigger times (15 mins before and 5 mins before)
        let fifteenMinsBefore = Calendar.current.date(byAdding: .minute, value: -15, to: pickupDate)
        let fiveMinsBefore = Calendar.current.date(byAdding: .minute, value: -5, to: pickupDate)
        
        let now = Date()
        
        // Helper to schedule a single notification
        func schedule(triggerDate: Date?, type: String, body: String) {
            guard let triggerDate = triggerDate, triggerDate > now else { return }
            
            let content = UNMutableNotificationContent()
            content.title = "Upcoming Pickup: \(order.customerName)"
            content.body = body
            content.sound = .default
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            // Unique identifier: OrderID + Type (e.g., "12345-15min")
            let request = UNNotificationRequest(identifier: "\(orderId)-\(type)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("DEBUG: Error scheduling \(type) notification: \(error.localizedDescription)")
                } else {
                    print("DEBUG: Scheduled \(type) notification for \(order.customerName) at \(triggerDate)")
                }
            }
        }
        
        schedule(
            triggerDate: fifteenMinsBefore,
            type: "15min",
            body: "The pickup for \(order.itemName) is in 15 minutes."
        )
        
        schedule(
            triggerDate: fiveMinsBefore,
            type: "5min",
            body: "Customer arriving in 5 minutes! Get the cake ready."
        )
    }
    
    // Cancel notifications for an order
    func cancelForOrder(_ order: CakeOrder) {
        guard let orderId = order.id else { return }
        let identifiers = ["\(orderId)-15min", "\(orderId)-5min"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("DEBUG: Cancelled notifications for order \(orderId)")
    }
}
