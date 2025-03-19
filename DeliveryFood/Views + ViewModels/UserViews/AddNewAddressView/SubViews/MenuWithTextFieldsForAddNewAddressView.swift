//
//  MenuWithTextFieldsForAddNewAddressView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 10.04.2024.
//

import SwiftUI

struct MenuWithTextFieldsForAddNewAddressView: View {
    @ObservedObject var viewModel: AddNewAddressViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                
                Button {
                    viewModel.isShowedTextFields.toggle()
                    guard !viewModel.isShowedTextFields else { return }
                    viewModel.isShowedSearchView = false
                } label: {
                    HStack {
                        if !viewModel.isShowedTextFields {
                            Text(viewModel.addressText == "" ? "Loading location..." : viewModel.addressText)
                                .lineLimit(1)
                                .transition(.slide.combined(with: .opacity).combined(with: .scale))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(viewModel.isShowedTextFields ? .degrees(-90) : .degrees(0))
                    }
                }
                .foregroundStyle(.background)
                .bold()
                
                Spacer()
            }
            VStack {
                if viewModel.isShowedTextFields {
                    
                    VStack {
                        CustomTextFieldForAddressInputView(
                            textFieldString: $viewModel.addressText,
                            textFieldPlaceholder: viewModel.addressText.isEmpty ? "" :
                                viewModel.selectedAddress?.description ?? viewModel.plugSelectedAddress.description,
                            isEditing: $viewModel.isShowedSearchView
                        )
                        
                        if !viewModel.isShowedSearchView {
                            HStack {
                                CustomTextFieldForAddressInputView(textFieldString: $viewModel.entrancewayText, textFieldPlaceholder: "Entranceway")
                                CustomTextFieldForAddressInputView(textFieldString: $viewModel.intercomNumberText, textFieldPlaceholder: "Intercom")
                            }
                            HStack {
                                CustomTextFieldForAddressInputView(textFieldString: $viewModel.floorText, textFieldPlaceholder: "Floor")
                                CustomTextFieldForAddressInputView(textFieldString: $viewModel.apartmentText, textFieldPlaceholder: "Apartment")
                            }
                            CustomTextFieldForAddressInputView(textFieldString: $viewModel.orderCommentText, textFieldPlaceholder: "Order comment")
                            Button {
                                viewModel.saveAddress {
                                    dismiss()
                                }
                            } label: {
                                Text("Save")
                                    .bold()
                                    .foregroundStyle(Color(uiColor: .label))
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.background)
                            )
                            
                        } else {
                            SearchAddressListView(viewModel: viewModel)
                        }
                    }
                    .transition(.scale(0, anchor: .top).combined(with: .opacity))
                }
            }
        }
        .padding(16)
        .background(Color.primary.clipShape(RoundedRectangle(cornerRadius: 20)))
        .padding(32)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isShowedSearchView)
    }
}
