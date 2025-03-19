//
//  CustomTextFieldForAddressInputView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 10.04.2024.
//

import SwiftUI

struct CustomTextFieldForAddressInputView: View {
    @Binding var textFieldString: String
    var textFieldPlaceholder: String
    @Binding var isEditing: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    // Если нужно отслеживать когда textField редактируется
    init(textFieldString: Binding<String>, textFieldPlaceholder: String, isEditing: Binding<Bool>) {
        self._textFieldString = textFieldString
        self.textFieldPlaceholder = textFieldPlaceholder
        self._isEditing = isEditing
    }
    
    init(textFieldString: Binding<String>, textFieldPlaceholder: String) {
        self._textFieldString = textFieldString
        self.textFieldPlaceholder = textFieldPlaceholder
        self._isEditing = .constant(false)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundStyle(Color(uiColor: colorScheme == .dark ? .systemGray : .systemFill))
            .opacity(colorScheme == .dark ? 0.13 : 1)
            .frame(height: 50)
            .overlay {
                HStack {
                    Text(textFieldPlaceholder == "" ? "City, street, apartment number" : textFieldPlaceholder)
                        .lineLimit(1)
                        .offset(y: textFieldString == "" ? 0 : -15)
                        .font(textFieldString == "" ? .callout : .caption)
                        .foregroundStyle(.gray)
                        .animation(.easeInOut(duration: 0.1), value: textFieldString)
                    Spacer()
                }
                .padding([.leading, .trailing], 16)
                TextField("", text: $textFieldString, onEditingChanged: { isEditing in
                    self.isEditing = isEditing
                })
                .padding([.leading, .trailing], 16)
                .foregroundStyle(Color(uiColor: .systemBackground))
            }
    }
}
