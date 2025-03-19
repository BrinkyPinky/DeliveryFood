//
//  DeliveryFoodAppModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 17.03.2025.
//

import Foundation

final class DeliveryFoodAppModel: ObservableObject {
    @Published var isLaunchScreenShowed = true

    // error View
    @Published var isErrorShowed = false
    var errorMessage = ""

    @Published var isUserAdmin = false

    func onAppearAction() {
        guard let userID = FirebaseAuthManager.shared.getUserID() else { return }
        FirebaseFirestoreAdminManager.shared.checkIfUserIsAdmin(userID: userID)
    }
}
