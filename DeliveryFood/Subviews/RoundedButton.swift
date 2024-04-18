//
//  RoundedButton.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 13.04.2024.
//

import SwiftUI

struct RoundedButton: View {
    @Environment(\.dismiss) private var dismiss
    let dismissAction: (@escaping () -> ()) -> ()
    let buttonText: String
    let maxWidth: CGFloat
    @Binding var isLoading: Bool
    
    var body: some View {
        Button {
            dismissAction({
                dismiss()
            })
        } label: {
            VStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .colorInvert()
                } else {
                    Text(buttonText)
                }
            }
            .padding()
            .frame(maxWidth: maxWidth)
            .background(Color(uiColor: .label))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .foregroundStyle(Color(uiColor: .systemBackground))
        .animation(.easeInOut(duration: 0.01), value: isLoading)
        .disabled(isLoading ? true : false)
    }
}

#Preview {
    RoundedButton(dismissAction: { _ in }, buttonText: "Smth", maxWidth: .infinity, isLoading: .constant(true))
}
