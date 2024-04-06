//
//  OrderConfirmView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 05.04.2024.
//

import SwiftUI

struct OrderConfirmView: View {
    @StateObject private var viewModel = OrderConfirmViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                LogotypeView(size: 32, isLeafNeeded: true)
                    .padding(.top, 16)
                DashedLine()
                    .padding([.leading, .trailing], -32)
                
                Form {
                    Section("Address") {
                        NavigationLink("Address") {
                            AddressSelectionView()
                        }
                    }
                    
                    Section("Delivery Details") {
                        Picker("Deliver", selection: $viewModel.deliveryTimeType.animation()) {
                            Button("ASAP") {
                                viewModel.deliveryTimeType = .ASAP
                            }.tag(DeliveryTimeType.ASAP)
                            Button("On Time") {
                                viewModel.deliveryTimeType = .onTime
                            }.tag(DeliveryTimeType.onTime)
                            
                        }
                        
                        if viewModel.deliveryTimeType == .onTime {
                            DatePicker(
                                "",
                                selection: $viewModel.selectedDate,
                                in: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
                                    ...
                                    Calendar.current.date(
                                        bySettingHour: 23,
                                        minute: 0,
                                        second: 0,
                                        of: Date()
                                    )!,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .animation(.easeInOut, value: viewModel.selectedDate)
                        }
                        
                        Picker("Payment type on receipt", selection: $viewModel.paymentType) {
                            Button("By Card") {
                                viewModel.paymentType = .card
                            }.tag(PaymentType.card)
                            Button("By Cash") {
                                viewModel.paymentType = .cash
                            }.tag(PaymentType.cash)
                        }
                    }
                }
                .padding([.leading, .trailing], -32)
                
                DashedLine()
                    .padding([.leading, .trailing], -32)
                
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
                    Text("20.00 $")
                }
                .font(.headline)
                .fontDesign(.monospaced)
            }
            .padding([.leading, .trailing], 32)
        }
    }
}


#Preview {
    VStack {
        
    }
    .sheet(isPresented: .constant(true), content: {
        OrderConfirmView()
    })
}
