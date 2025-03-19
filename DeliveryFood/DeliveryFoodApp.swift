//
//  DeliveryFoodApp.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 18.01.2024.
//

import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

@main
struct DeliveryFoodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var viewModel = DeliveryFoodAppModel()

    var body: some Scene {

        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .launchScreenViewModifier(isShowed: $viewModel.isLaunchScreenShowed)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { _ in
                    withAnimation {
                        viewModel.isLaunchScreenShowed = false
                    }
                    BackgroundManager.shared.askPermission()
                }
            }
            .onChange(of: scenePhase) { _, newValue in
                guard newValue == .background else { return }
                BackgroundManager.shared.startListenForCurrentOrders()
            }
            .errorMessageView(errorMessage: viewModel.errorMessage, isShowed: $viewModel.isErrorShowed)
            .onAppear {
                viewModel.onAppearAction()
            }
        }
    }
}
