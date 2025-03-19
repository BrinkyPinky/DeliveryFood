//
//  BillView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 08.03.2024.
//

import SwiftUI

struct BillView: View {
    @StateObject private var viewModel = BillViewModel()
    @State private var editMode = EditMode.inactive
    @StateObject private var coreDataManager = BillCoreDataManager.shared

    var body: some View {
        VStack {
            //nav bar
            CustomNavigationBarView(
                isLeafNeeded: true,
                isBackButtonNeeded: true,
                isCartButtonNeeded: false,
                isUserProfileNeeded: true
            )
                .padding([.leading, .trailing], 32)
            List {
                //Review и кнопка для редактирования чека
                ReviewEditRow(editMode: $editMode)
                
                ForEach(coreDataManager.billPositions, id: \.foodID) { position in
                    //Позиция в чеке
                    BillElement(positionForBill: position, viewModel: viewModel)
                        .id(position.foodID)
                }
                .onDelete(perform: { indexSet in
                    viewModel.deleteItem(at: indexSet)
                })
                .listRowSeparator(.hidden)
                
                //сумма и кнопка для оплаты
                TotalPrice(viewModel: viewModel, isCartEmpty: coreDataManager.billPositions.isEmpty)
            }
            .listStyle(.plain)
            
        }
        .environment(\.editMode, $editMode)
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $viewModel.isOrderConfirmViewPresented, content: {
            OrderConfirmView(totalPrice: viewModel.totalPrice, isOrderConfirmPresented: $viewModel.isOrderConfirmViewPresented)
        })
        .errorMessageView(errorMessage: viewModel.errorMessage, isShowed: $viewModel.isErrorShowed)
        .onAppear(perform: {
            viewModel.updateTotalPrice()
        })
        .onChange(of: coreDataManager.billPositions, { _, _ in
            withAnimation {
                viewModel.updateTotalPrice()
            }
        })
    }
}

#Preview {
    BillView()
}

// MARK: Сумма и кнопка для оплаты

struct TotalPrice: View {
    @ObservedObject var viewModel: BillViewModel
    var isCartEmpty: Bool
    
    var body: some View {
        HStack {
            HStack(alignment: .bottom) {
                Text("$")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                Text(String(format: "%.2f", viewModel.totalPrice))
                    .font(.system(size: 50, weight: .bold, design: .rounded))
            }
            
            Spacer()
            
            Button(action: {
                viewModel.continueOrderButtonAction(isCartEmpty: isCartEmpty)
            }, label: {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.gray)
                    .overlay {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                    }
            })
        }
        .listRowInsets(EdgeInsets(top: 16, leading: 32, bottom: 0, trailing: 32))
        .listRowSeparator(.hidden)
    }
}

// MARK: Review и кнопка для редактирования чека

struct ReviewEditRow: View {
    @Binding var editMode: EditMode
    
    var body: some View {
        HStack {
            Text("Review")
                .font(.system(size: 24, weight: .regular, design: .default))
            Spacer()
            Button(action: {
                withAnimation {
                    editMode = editMode == .active ? .inactive : .active
                }
            }, label: {
                if editMode == .inactive {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                } else {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                }
            })
        }
        .listRowBackground(
            GeometryReader(content: { geometry in
                DashedLine()
                    .position(x: geometry.size.width/2, y: geometry.size.height)
            })
        )
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 32, bottom: 16, trailing: 32))
    }
}

// MARK: Позиция в чеке

struct BillElement: View {
    let positionForBill: PositionForBillModel
    let viewModel: BillViewModel
    @State private var amountOfCurrentPosition: Int
    
    init(positionForBill: PositionForBillModel, viewModel: BillViewModel) {
        self.positionForBill = positionForBill
        self.viewModel = viewModel
        self.amountOfCurrentPosition = Int(positionForBill.amount)
    }
    
    var body: some View {
        HStack {
            Text("\(positionForBill.foodName)")
            Spacer()
            VStack(alignment: .trailing) {
                HStack {
                    Text("x\(amountOfCurrentPosition)")
                    Text("\(String(format:"%.2f", positionForBill.price))$")
                }
                Stepper("", value: $amountOfCurrentPosition, in: 0...50) { isEditing in
                    guard !isEditing else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            viewModel.changeAmountOfBillPosition(positionModel: positionForBill, toValue: amountOfCurrentPosition)
                        }
                    }
                }
            }
        }
        .fontDesign(.monospaced)
        .listRowInsets(EdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 32))
        .padding([.top,.bottom], 24)
        .listRowBackground(
            GeometryReader(content: { geometry in
                DashedLine()
                    .position(x: geometry.size.width/2, y: geometry.size.height)
            })
        )
    }
}
