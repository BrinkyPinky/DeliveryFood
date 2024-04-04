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
    
    func body(content: Content) -> some View {
        ZStack() {
            GeometryReader(content: { geometry in
                content
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 30)
                        .shadow(color: Color(uiColor: .label), radius: 10)
                        .frame(height: geometry.size.height/5)
                        .overlay {
                            ZStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: geometry.size.height/8)
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
                .offset(x: 0, y: isShowed ? 0 : geometry.size.height/5)
                .animation(.easeInOut(duration: 0.3), value: isShowed)
                .onChange(of: isShowed) {
                    if isShowed == true {
                        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
                            isShowed = false
                        }
                    }
                }
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
