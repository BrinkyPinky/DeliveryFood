//
//  AuthView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 10.04.2024.
//

import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            GeometryReader(content: { geometry in
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        VStack {
                            LogotypeView(size: geometry.size.width/4, isLeafNeeded: true)
                                .padding(.bottom, 1)
                            
                            Button {
                                withAnimation(.easeInOut(duration: 1)) {
                                    viewModel.animateShapes()
                                    viewModel.authState = .registration
                                } completion: {
                                    viewModel.isViewShouldDisplayingAuthStateViews = true
                                }
                            } label: {
                                HStack {
                                    Text("Get started")
                                        .bold()
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundStyle(.white)
                                .padding()
                                .background(.green)
                                .clipShape(RoundedRectangle(cornerRadius: 50))
                                .padding([.trailing, .leading], geometry.size.width/5)
                            }
                            
                            Button {
                                withAnimation(.easeInOut(duration: 1)) {
                                    viewModel.animateShapes()
                                    viewModel.authState = .authorization
                                } completion: {
                                    viewModel.isViewShouldDisplayingAuthStateViews = true
                                }
                            } label: {
                                Text("Login to Account")
                                    .font(.subheadline)
                                    .padding(.top)
                                    .foregroundStyle(.gray)
                            }
                        }
                        
                        Spacer()
                    }
                    Spacer()
                }
            })
            
            WavesView(viewModel: viewModel)
                .overlay {
                    if viewModel.authState == .notDeterminated {
                        VStack {
                            Spacer()
                            
                            Button {
                                withAnimation(.easeInOut(duration: 1)) {
                                    viewModel.animateShapes()
                                    viewModel.authState = .forgotThePassword
                                } completion: {
                                    viewModel.isViewShouldDisplayingAuthStateViews = true
                                }
                            } label: {
                                Text("Forgot the password")
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    if viewModel.isViewShouldDisplayingAuthStateViews {
                        VStack {
                            Button {
                                viewModel.authState = .notDeterminated
                                viewModel.resetShapes()
                            } label: {
                                VStack {
                                    Text("Back")
                                        .padding(.bottom, 8)
                                        .padding(.top)
                                    Image(systemName: "chevron.down")
                                }
                            }
                            .foregroundStyle(.primary)
                            
                            Spacer()
                            if viewModel.authState == .authorization {
                                AuthorizationStateView(viewModel: viewModel)
                            } else if viewModel.authState == .registration {
                                RegistrationStateView(viewModel: viewModel)
                            } else if viewModel.authState == .forgotThePassword {
                                ForgotPasswordStateView(viewModel: viewModel)
                                    .transition(.scale(scale: 0, anchor: .bottom))
                            }
                            Spacer()
                        }
                        .padding([.leading, .trailing], 32)
                        .transition(.scale(scale: 0, anchor: .bottom))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.isViewShouldDisplayingAuthStateViews)
        }
        .errorMessageView(errorMessage: viewModel.errorMessage, isShowed: $viewModel.isErrorShowed)
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true), content: {
            AuthView()
        })
}

// MARK: AuthorizationStateView

struct AuthorizationStateView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            LogotypeView(size: 75, isLeafNeeded: false)
            TextFieldWithUnderlineAndImage(imageSystemName: "envelope", placeholder: "E-Mail", text: $viewModel.emailText)
            TextFieldWithUnderlineAndImage(imageSystemName: "lock", placeholder: "Password", text: $viewModel.passwordText)
            RoundedButton(dismissAction: viewModel.loginAction, buttonText: "Login", maxWidth: .infinity, isLoading: $viewModel.isAuthActionLoading)
        }
    }
}

// MARK: RegistrationStateView

struct RegistrationStateView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            LogotypeView(size: 75, isLeafNeeded: false)
            TextFieldWithUnderlineAndImage(imageSystemName: "person", placeholder: "Name", text: $viewModel.nameText)
                .keyboardType(.namePhonePad)
            TextFieldWithUnderlineAndImage(imageSystemName: "envelope", placeholder: "E-Mail", text: $viewModel.emailText)
            TextFieldWithUnderlineAndImage(imageSystemName: "phone", placeholder: "Phone number", text: $viewModel.phoneNumberText)
                .keyboardType(.phonePad)
                .onChange(of: viewModel.phoneNumberText) { oldValue, newValue in
                    viewModel.phoneNumberText = newValue.formatStringToPhoneNumber()
                    if newValue.count <= 2 {
                        viewModel.phoneNumberText = "+7"
                    }
                }
            TextFieldWithUnderlineAndImage(imageSystemName: "lock", placeholder: "Password", text: $viewModel.passwordText)
            
            RoundedButton(dismissAction: viewModel.registerAction, buttonText: "Register", maxWidth: .infinity, isLoading: $viewModel.isAuthActionLoading)
        }
    }
}

// MARK: ForgotPasswordStateView

struct ForgotPasswordStateView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            LogotypeView(size: 75, isLeafNeeded: false)
            TextFieldWithUnderlineAndImage(imageSystemName: "envelope", placeholder: "E-Mail", text: $viewModel.emailText)
            RoundedButton(dismissAction: viewModel.forgotThePasswordAction, buttonText: "Send An E-Mail", maxWidth: .infinity, isLoading: $viewModel.isAuthActionLoading)
            Text("We will send you an E-Mail with link to reset your password")
                .padding(.top, 8)
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .font(.subheadline)
        }
        
    }
}

// MARK: WaveShape

fileprivate struct WaveShape: Shape {
    var leftY: Double
    var rightY: Double
    var controlY: Double
    
    var animatableData: AnimatablePair<Double, AnimatablePair<Double, Double>> {
        get { AnimatablePair(leftY, AnimatablePair(rightY, controlY)) }
        set {
            leftY = newValue.first
            rightY = newValue.second.first
            controlY = newValue.second.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let height = rect.height
        
        path.move(to: CGPoint(x: rect.minX, y: height))
        path.addLine(to: CGPoint(x: rect.minX, y: leftY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rightY),
            control: CGPoint(x: rect.midX, y: controlY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: WaveShapeBackground

fileprivate struct WaveShapeBackground: Shape {
    var leftY: Double
    var rightY: Double
    var controlY: Double
    
    var animatableData: AnimatablePair<Double, AnimatablePair<Double, Double>> {
        get { AnimatablePair(leftY, AnimatablePair(rightY, controlY)) }
        set {
            leftY = newValue.first
            rightY = newValue.second.first
            controlY = newValue.second.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let height = rect.height
        
        path.move(to: CGPoint(x: rect.minX, y: height))
        path.addLine(to: CGPoint(x: rect.minX, y: leftY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rightY),
            control: CGPoint(x: rect.midX, y: controlY))
        path.addLine(to: CGPoint(x: rect.maxX, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: WavesView

struct WavesView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            WaveShapeBackground(
                leftY: viewModel.waveShapeBackgroundLeftY,
                rightY: viewModel.waveShapeBackgroundRightY,
                controlY: viewModel.waveShapeBackgroundControlY
            )
            .foregroundStyle(Color(uiColor: UIColor(
                red: 50/255,
                green: 183/255,
                blue: 247/255,
                alpha: 1
            )))
            WaveShape(
                leftY: viewModel.waveShapeLeftY,
                rightY: viewModel.waveShapeRightY,
                controlY: viewModel.waveShapeControlY
            )
            .foregroundStyle(Color(uiColor: viewModel.isViewShouldDisplayingAuthStateViews ?
                .systemBackground :
                                    UIColor(
                                        red: 60/255,
                                        green: 104/255,
                                        blue: 195/255,
                                        alpha: 1))
            )
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isViewShouldDisplayingAuthStateViews)
        .onAppear(perform: {
            viewModel.viewHeight = UIScreen.main.bounds.height
            withAnimation(.easeOut(duration: 1)) {
                viewModel.resetShapes()
            }
        })
        .ignoresSafeArea()
    }
}
