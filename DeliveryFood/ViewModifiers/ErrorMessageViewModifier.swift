//
//  ErrorMessageViewModifier.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 02.04.2024.
//

import SwiftUI

struct ErrorMessageViewModifier: ViewModifier {
    let errorMessage: String
    @Binding var isShowed: Bool
    @State private var isKeyboardVisible = false
    
    func body(content: Content) -> some View {
        ZStack() {
            content
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 30)
                    .shadow(color: Color(uiColor: .label), radius: 10)
                    .frame(height: UIScreen.main.bounds.height/5)
                    .overlay {
                        ZStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: UIScreen.main.bounds.height/8)
                                .foregroundColor(.red)
                                .opacity(0.3)
                            VStack {
                                Text("What Da...")
                                    .font(.system(size: 24))
                                    .bold()
                                    .colorInvert()
                                Spacer()
                                Text(errorMessage)
                                    .multilineTextAlignment(.center)
                                    .colorInvert()
                                Spacer()
                            }
                        }
                        .padding()
                    }
                    .padding([.leading, .trailing])
            }
            .opacity(isShowed ? 1 : 0)
            .offset(x: 0, y: isShowed ? 0 : UIScreen.main.bounds.height/5)
            .animation(.easeInOut(duration: 0.3), value: isShowed)
            .offset(y: isKeyboardVisible ? -20 : 0)
            .onChange(of: isShowed) {
                if isShowed == true {
                    Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
                        isShowed = false
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification), perform: { _ in
                isKeyboardVisible = true
            })
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification), perform: { _ in
                isKeyboardVisible = false
            })
        }
    }
}

extension View {
    func errorMessageView(errorMessage: String, isShowed: Binding<Bool>) -> some View {
        modifier(ErrorMessageViewModifier(
            errorMessage: errorMessage,
            isShowed: isShowed
        ))
    }
}

struct ViewModifierExample: View {
    @State private var isErrorShowed = false
    
    var body: some View {
        Button(action: { isErrorShowed.toggle() }, label: {
            Text("Button")
        })
        .errorMessageView(
            errorMessage: "An error occurred while saving data\nPlease report the bug",
            isShowed: $isErrorShowed
        )
    }
}

#Preview {
    ViewModifierExample()
}
