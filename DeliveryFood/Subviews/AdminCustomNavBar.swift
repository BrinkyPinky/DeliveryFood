//
//  AdminCustomNavBar.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 18.03.2025.
//

import SwiftUI

struct AdminCustomNavBar: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
            LogotypeView(size: 32, isLeafNeeded: true)
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    AdminCustomNavBar()
}
