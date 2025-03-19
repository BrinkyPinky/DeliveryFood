//
//  OrderConfirmView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 05.04.2024.
//

import SwiftUI

struct OrderConfirmView: View {
    @StateObject private var viewModel: OrderConfirmViewModel
    @Binding var isOrderConfirmPresented: Bool

    init(totalPrice: Double, isOrderConfirmPresented: Binding<Bool>) {
        _viewModel = StateObject(
            wrappedValue: OrderConfirmViewModel(totalPrice: totalPrice))
        _isOrderConfirmPresented = isOrderConfirmPresented
    }

    var body: some View {
        NavigationView {
            VStack {
                LogotypeView(size: 32, isLeafNeeded: true)
                    .padding(.top, 16)
                DashedLine()
                    .padding([.leading, .trailing], -32)

                Form {
                    Section("Address") {
                        NavigationLink(
                            viewModel.currentPickedAddressModel?.addressName
                                ?? "Pick the address"
                        ) {
                            AddressSelectionView(
                                selectedAddressModel: $viewModel
                                    .currentPickedAddressModel)
                        }
                    }

                    DeliveryDetailsForOrderConfirmView(viewModel: viewModel)
                }
                .padding([.leading, .trailing], -32)

                DashedLine()
                    .padding([.leading, .trailing], -32)

                TabBarForOrderConfirmView(
                    viewModel: viewModel,
                    isOrderConfirmPresented: $isOrderConfirmPresented)
            }
            .padding([.leading, .trailing], 32)
        }
        .errorMessageView(
            errorMessage: viewModel.errorMessage,
            isShowed: $viewModel.isErrorShowed
        )
        .onAppear(perform: {
            viewModel.onAppearAction()
        })
    }
}

#Preview {
    VStack {

    }
    .sheet(
        isPresented: .constant(true),
        content: {
            OrderConfirmView(
                totalPrice: 8.50, isOrderConfirmPresented: .constant(true))
        })
}

// MARK: Tab Bar

struct TabBarForOrderConfirmView: View {
    @ObservedObject var viewModel: OrderConfirmViewModel
    @Binding var isOrderConfirmPresented: Bool

    var body: some View {
        VStack {
            HStack {
                Text("Delivery")
                Spacer()
                Text("Free")
            }
            .padding(.top)
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack {
                Text("Order price")
                Spacer()
                Text(String(format: "%.2f", viewModel.totalPrice) + " $")
            }
            .font(.headline)
            .fontDesign(.monospaced)

            Button {
                viewModel.makeOrderAction {
                    isOrderConfirmPresented = false
                }
            } label: {
                ZStack {
                    if !viewModel.isOrderButtonShowsLoadingIndicator {
                        Text("Order")
                            .bold()
                            .colorInvert()
                    } else {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .colorInvert()
                            .scaleEffect(1.3)
                    }
                }
                .animation(
                    .easeInOut(duration: 0.01),
                    value: viewModel.isOrderButtonShowsLoadingIndicator
                )
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 20))
            }
            .foregroundColor(.primary)
        }
    }
}

// MARK: DeliveryDetails

struct DeliveryDetailsForOrderConfirmView: View {
    @ObservedObject var viewModel: OrderConfirmViewModel

    var body: some View {
        Section("Delivery Details") {
            Picker(
                "Deliver", selection: $viewModel.deliveryTimeType.animation()
            ) {
                Button("ASAP") {
                    viewModel.deliveryTimeType = .ASAP
                }.tag(DeliveryTimeType.ASAP)
                Button("On Time") {
                    viewModel.deliveryTimeType = .onTime
                }.tag(DeliveryTimeType.onTime)

            }

            if viewModel.deliveryTimeType == .onTime {
                Text(
                    viewModel.dateRange.lowerBound.formatted(date: .complete, time: .omitted)
                )
                .animation(.easeInOut, value: viewModel.selectedDate)
                DatePicker(
                    "", selection: $viewModel.selectedDate,
                    in: viewModel.dateRange, displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .animation(.easeInOut, value: viewModel.selectedDate)
            }

            Picker("Payment type on receipt", selection: $viewModel.paymentType)
            {
                Button("By Card") {
                    viewModel.paymentType = .card
                }.tag(PaymentType.card)
                Button("By Cash") {
                    viewModel.paymentType = .cash
                }.tag(PaymentType.cash)
            }
        }
    }
}
