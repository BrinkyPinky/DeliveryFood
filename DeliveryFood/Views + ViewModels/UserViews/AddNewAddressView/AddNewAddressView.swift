//
//  AddNewAddressView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 06.04.2024.
//

import SwiftUI

struct AddNewAddressView: View {
    @StateObject private var viewModel = AddNewAddressViewModel()
    
    var body: some View {
        ZStack {
            MapView(viewModel: viewModel)
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            ZStack {
                if !viewModel.isShowedTextFields {
                    Circle()
                        .stroke(lineWidth: 5)
                        .foregroundStyle(.red)
                        .frame(width: viewModel.firstCircleWidth)
                        .opacity(viewModel.firstCircleOpacity)
                    Circle()
                        .stroke(lineWidth: 4)
                        .foregroundStyle(.red)
                        .grayscale(0.4)
                        .frame(width: viewModel.secondCircleWidth)
                        .opacity(viewModel.secondCircleOpacity)
                    Image(uiImage: UIImage(named: "pointOnTheMap.png")!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .offset(y: -20)
                        .offset(y: viewModel.pointOnTheMapY)
                        .transition(.scale)
                }
            }
            .allowsHitTesting(false)
            VStack {
                
                MenuWithTextFieldsForAddNewAddressView(viewModel: viewModel)
                    .onChange(of: viewModel.addressText) { _, newValue in
                        viewModel.getCoordinateFromString(newValue)
                    }
                
                Spacer()
                HStack {
                    Spacer()
                    if !viewModel.isShowedTextFields {
                        Button(action: {
                            viewModel.startUpdate()
                        }, label: {
                            Circle()
                                .frame(width: 60)
                                .foregroundStyle(.black)
                                .overlay {
                                    Image(systemName: "paperplane.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                        .foregroundStyle(.white)
                                }
                        })
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            viewModel.startUpdate()
        }
        .errorMessageView(errorMessage: viewModel.errorMessage, isShowed: $viewModel.isErrorShowed)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isShowedTextFields)
    }
}

#Preview {
    AddNewAddressView()
}
