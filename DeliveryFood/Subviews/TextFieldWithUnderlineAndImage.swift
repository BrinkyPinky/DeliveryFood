//
//  TextFieldWithUnderlineAndImage.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 13.04.2024.
//

import SwiftUI

struct TextFieldWithUnderlineAndImage: View {
    let imageSystemName: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: imageSystemName)
            TextField("", text: $text)
                .overlay {
                    HStack {
                        Text(placeholder)
                            .foregroundStyle(.placeholder)
                            .offset(y: text == "" ? 0 : -18)
                            .font(text == "" ? .callout : .caption)
                        Spacer()
                    }
                    .allowsHitTesting(false)
                }
        }
        .padding(.bottom, 8)
        .background {
            VStack() {
                Spacer()
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.placeholder)
            }
        }
        .padding(.bottom, 32)
        .animation(.easeInOut(duration: 0.1), value: text)
    }
}

#Preview {
    TextFieldWithUnderlineAndImage(imageSystemName: "person", placeholder: "smth", text: .constant(""))
}
