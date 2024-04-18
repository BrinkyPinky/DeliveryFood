//
//  DeliveryFoodApp.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 18.01.2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

@main
struct DeliveryFoodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isLaunchScreenShowed = true
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .launchScreenViewModifier(isShowed: $isLaunchScreenShowed)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { _ in
                        withAnimation {
                            isLaunchScreenShowed = false
                            BackgroundManager.shared.askPermission()
                        }
                    }
                }
                .onChange(of: scenePhase) { _, newValue in
                    guard newValue == .background else { return }
                    BackgroundManager.shared.startListenForCurrentOrders()
                }
        }
    }
}
    
    #Preview {
        DeliveryFoodApp() as! any View
    }
