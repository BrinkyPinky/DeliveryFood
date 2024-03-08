//
//  CustomNavigationBarView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 22.01.2024.
//

import SwiftUI

struct CustomNavigationBarView: View {
    let isLeafNeeded: Bool
    let isBackButtonNeeded: Bool
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        HStack {
            if isBackButtonNeeded {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.background)
                        .shadow(radius: 1)
                        .overlay {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .padding(.trailing, 8)
                }
                .buttonStyle(.plain)
            }
            LogotypeView(size: 32, isLeafNeeded: isLeafNeeded)
            Spacer()
            Image(systemName: "bag")
                .resizable()
                .frame(width: 20, height: 20)
                .fontWeight(.thin)
        }
    }
}

#Preview {
    CustomNavigationBarView(isLeafNeeded: false, isBackButtonNeeded: true)
}
