//
//  BackgroundManager.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 16.04.2024.
//

import FirebaseFirestore
import UserNotifications

final class BackgroundManager {
    let db = Firestore.firestore()
    
    static let shared = BackgroundManager()
    
    var listener: ListenerRegistration? = nil
    
    func askPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
    
    func sendNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "DeliveryFood"
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func startListenForCurrentOrders() {
        guard let userID = FirebaseAuthManager.shared.getUserID() else { return }
        
        listener = db.collection("Orders").document(userID).collection("Orders").limit(toLast: 1).addSnapshotListener({ [weak self] snapshot, error in
            guard let self = self else { return }
            
            if error != nil {
                listener?.remove()
            }
            
            if let snapshot = snapshot {
                if let previousOrderModel = try? snapshot.documents.first?.data(as: PreviousOrderModel.self) {
                    guard previousOrderModel.orderStatus != 0 else { return }
                    
                    let message: String = {
                        switch previousOrderModel.orderStatus {
                        case 1: "We have taken your order and will start cooking soon."
                        case 2: "The order is already in the kitchen."
                        case 3: "The courier is on his way with your goodies."
                        case 4: "Your order has been delivered. Enjoy your meal."
                        case 9 : "Your order has been canceled due to technical reasons, we apologize."
                        default: "Unknown status"
                        }
                    }()
                    
                    sendNotification(message: message)
                    
                    if previousOrderModel.orderStatus == 4 || previousOrderModel.orderStatus == 9 {
                        listener?.remove()
                    }
                } else {
                    listener?.remove()
                }
            }
        })
    }
}
