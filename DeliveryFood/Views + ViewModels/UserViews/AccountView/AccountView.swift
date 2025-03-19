//
//  AccountView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 14.04.2024.
//

import SwiftUI

struct AccountView: View {
    @StateObject private var viewModel = AccountViewModel()
    // Нужно ли показать BillView
    let billViewShouldBePresented: () -> ()
    
    var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemGroupedBackground)
            
            VStack {
                Picker("", selection: $viewModel.currentPickedProfileData) {
                    Text("Orders").tag(1)
                    Text("Addresses").tag(2)
                    Text("Settings").tag(3)
                }
                .pickerStyle(.palette)
                
                Spacer()
                
                VStack {
                    if viewModel.currentPickedProfileData == 1 {
                        if !viewModel.previousOrderModels.isEmpty {
                            PreviousOrders(viewModel: viewModel, billViewShouldBePresented: billViewShouldBePresented)
                        } else {
                            Text("You haven't ordered anything yet")
                        }
                    } else if viewModel.currentPickedProfileData == 2 {
                        AddressSelectionView()
                    } else if viewModel.currentPickedProfileData == 3 {
                        UserSettings(viewModel: viewModel)
                    }
                }
                
                Spacer()
            }
            .onAppear(perform: {
                viewModel.onAppearAction()
            })
            .onDisappear(perform: {
                viewModel.onDisappearAction()
            })
            .padding([.leading, .trailing, .top], 16)
        }
        .errorMessageView(errorMessage: viewModel.errorMessage, isShowed: $viewModel.isErrorShowed)
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true), content: {
            AccountView(billViewShouldBePresented: {})
        })
}

fileprivate struct UserSettings: View {
    @ObservedObject var viewModel: AccountViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section("Personal Data") {
                TextField("Name", text: viewModel.isUserDataLoaded ? $viewModel.userName : .constant("Loading..."))
                    .foregroundStyle(viewModel.isUserDataLoaded ? .primary : .secondary)
                    .disabled(!viewModel.isUserDataLoaded)
                    .onChange(of: viewModel.userName) { oldValue, newValue in
                        guard oldValue != newValue else { return }
                        viewModel.userDataHasChangedAction()
                    }
                
                TextField("Phone number", text: viewModel.isUserDataLoaded ? $viewModel.userPhoneNumber : .constant("Loading..."))
                    .foregroundStyle(viewModel.isUserDataLoaded ? .primary : .secondary)
                    .disabled(!viewModel.isUserDataLoaded)
                    .onChange(of: viewModel.userPhoneNumber) { oldValue, newValue in
                        guard oldValue != newValue else { return }
                        viewModel.userDataHasChangedAction()
                        viewModel.userPhoneNumber = newValue.formatStringToPhoneNumber()
                        if newValue.count <= 2 {
                            viewModel.userPhoneNumber = "+7"
                        }
                    }
            }
            
            if viewModel.isSaveButtonShouldAppear {
                Section() {
                    Button("Save changes") {
                        viewModel.saveDataChangesAction()
                    }
                    .bold()
                    Button("Cancel changes") {
                        viewModel.loadUserData()
                    }
                    .bold()
                    .foregroundStyle(.red)
                }
            }
            
            Section("User ID") {
                Text(viewModel.userID)
            }
            
            Section() {
                Button("Log Out") {
                    viewModel.logOutAction {
                        dismiss()
                    }
                }
                .foregroundStyle(.red)
                .bold()
            }
        }
        .animation(.easeInOut, value: viewModel.isSaveButtonShouldAppear)
    }
}

// MARK: PreviousOrders
fileprivate struct PreviousOrders: View {
    @ObservedObject var viewModel: AccountViewModel
    let billViewShouldBePresented: () -> ()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(viewModel.previousOrderModels, id: \.date) { orderModel in
                    PreviousOrderRow(viewModel: viewModel, orderModel: orderModel, billViewShouldBePresented: billViewShouldBePresented)
                        .animation(.easeInOut, value: orderModel.orderStatus)
                }
            }
        }
        .lineLimit(1)
        .padding([.leading, .trailing])
    }
}

// MARK: PreviousOrderRow
fileprivate struct PreviousOrderRow: View {
    @ObservedObject var viewModel: AccountViewModel
    @State private var isAlertPresented = false
    @Environment(\.dismiss) private var dismiss
    let orderModel: PreviousOrderModel
    let billViewShouldBePresented: () -> ()
    
    var body: some View {
        VStack {
            HStack {
                Text("\(orderModel.date.formatted(date: .long, time: .omitted))")
                Spacer()
                Text(String(format: "%.2f", orderModel.totalPrice) + " $")
            }
            .bold()
            
            DashedLine()
                .padding([.leading, .trailing], -16)
            
            ForEach(orderModel.positions, id: \.foodID) { foodModel in
                HStack {
                    Text(foodModel.foodName)
                    Spacer()
                    Text("\(foodModel.amount)x")
                        .foregroundStyle(.gray)
                    Text(String(format: "%.2f", foodModel.price) + " $")
                }
                Divider()
                    .padding([.leading, .trailing], -16)
            }
            
            HStack {
                HStack {
                    ProgressView(orderModel.orderStatus.orderStatusDecode(), value: Double(orderModel.orderStatus), total: 4)
                        .progressViewStyle(LinearProgressViewStyle())
                }
                .foregroundStyle(.gray)
                .padding(.top, 8)
                
                Spacer()
                
                Divider()
                    .padding(.top, -8)
                    .padding(.bottom, -16)
                
                Button {
                    isAlertPresented = true
                } label: {
                    Text("Reorder")
                        .padding([.leading, .top], 8)
                }
            }
        }
        .colorInvert()
        .padding(16)
        .background(Color.primary)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.top)
        .alert("We'll have to empty the cart, don't you agree?", isPresented: $isAlertPresented) {
            Button("Do it") {
                viewModel.reorderButtonAction(orderModel: orderModel) {
                    billViewShouldBePresented()
                    dismiss()
                }
            }
            Button("Cancel") {}
        }
    }
}
