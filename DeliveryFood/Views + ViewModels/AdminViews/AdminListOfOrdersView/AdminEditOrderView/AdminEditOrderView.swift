//
//  AdminEditOrderView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 13.03.2025.
//

import SwiftUI

struct AdminEditOrderView: View {
    @StateObject private var viewModel: AdminEditOrderViewModel

    init(adminOrderModel: AdminOrderModel) {
        self._viewModel = StateObject(
            wrappedValue: AdminEditOrderViewModel(orderModel: adminOrderModel))
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AdminCustomNavBar()
                    .padding(.horizontal)

                Spacer()

                Text(viewModel.isOnLiveStatus ? "Live" : "Not Live")
                    .bold()
                    .foregroundStyle(viewModel.isOnLiveStatus ? .green : .red)
                    .font(.title2)

            }
            .padding(.horizontal)

            ScrollView {
                HStack {
                    OrderStatusView(viewModel: viewModel)
                        .gesture(
                            LongPressGesture(minimumDuration: 0.2)
                                .onEnded { _ in
                                    viewModel.isDraggingOrderStatus = true
                                    HapticsManager.shared.impact(type: .medium)
                                }.sequenced(
                                    before: DragGesture(minimumDistance: 0)
                                        .onChanged({ value in
                                            guard
                                                viewModel.isDraggingOrderStatus
                                            else { return }
                                            viewModel.orderStatusDragged(
                                                location: value.location)
                                        }).onEnded({ _ in
                                            viewModel.onDragEnd()
                                        }))
                        )
                        .background {
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        viewModel.orderStatusItemHeight =
                                            proxy.size.height / 6
                                    }
                                    .onChange(of: proxy.size) { _, newValue in
                                        viewModel.orderStatusItemHeight =
                                            newValue.height / 6
                                    }
                            }
                        }

                    OrderDeliveryDetails(
                        order: viewModel.order,
                        clientDetails: $viewModel.clientsDetails)

                    Spacer()
                }

                OrderContents(order: viewModel.order)
            }

        }
        .errorMessageView(
            errorMessage: viewModel.errorMessage,
            isShowed: $viewModel.isErrorShowed
        )
        .onAppear {
            viewModel.onAppearAction()
        }
        .toolbar(.hidden)
        .onChange(of: viewModel.order.orderStatus) { _, newValue in
            viewModel.currentItemPickedID = newValue
        }
    }
}

#Preview {
    AdminEditOrderView(adminOrderModel: AdminOrderModel.mock)
}

struct StatusItem: View {
    let itemID: Int
    @Binding var currentID: Int
    @Binding var isDraggingOrderStatus: Bool

    @State private var isAnimating = false

    var body: some View {
        HStack {
            Image(
                systemName: currentID < 0 && itemID < 0
                    ? "xmark.circle.fill"
                    : itemID == currentID && currentID != 4
                        ? "circle.hexagongrid.circle.fill"
                        : (itemID < currentID && itemID >= 0)
                            || (currentID == 4 && itemID == 4)
                            ? "checkmark.circle.fill"
                            : "smallcircle.filled.circle.fill"
            )
            .resizable()
            .scaledToFit()
            .frame(height: 24)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(
                itemID <= -1 || (currentID == 4 && itemID == 4)
                    ? .default
                    : isAnimating
                        ? .linear(duration: 4).repeatForever(
                            autoreverses: false)
                        : .default,
                value: isAnimating
            )
            .onAppear {
                isAnimating = currentID == itemID
            }
            .onChange(
                of: currentID,
                { _, newValue in
                    isAnimating = newValue == itemID
                }
            )
            .scaleEffect(
                (itemID == currentID && isDraggingOrderStatus)
                    ? 1.4 : itemID <= currentID && itemID >= 0 ? 1.2 : 1
            )
            .animation(.easeInOut(duration: 0.2), value: isDraggingOrderStatus)
            .foregroundStyle(
                currentID < 0 && itemID <= 0
                    ? Color.red
                    : itemID <= currentID && itemID >= 0
                        ? Color.green : Color.secondary
            )

            Text(itemID.orderStatusDecode())
                .fontWeight(
                    currentID < 0 && itemID <= 0
                        ? .bold
                        : itemID <= currentID && itemID >= 0 ? .bold : .medium
                )
                .foregroundStyle(
                    currentID < 0 && itemID <= 0
                        ? Color.primary
                        : itemID <= currentID && itemID >= 0
                            ? Color.primary : Color.secondary)
        }
    }
}

struct StatusItemDivider: View {
    let itemID: Int
    let currentID: Int

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(width: 4)
            .padding(.leading, 10)
            .foregroundStyle(
                itemID < 1
                    ? currentID == -1
                        ? Color.red
                        : itemID == 0 ? Color.secondary : Color.green
                    : itemID <= currentID ? Color.green : Color.secondary
            )
            .padding(.top, -4)
            .padding(.vertical, 2)
    }
}

struct OrderStatusView: View {
    @ObservedObject var viewModel: AdminEditOrderViewModel

    var body: some View {
        VStack(alignment: .leading) {
            StatusItem(
                itemID: -1,
                currentID: $viewModel.currentItemPickedID,
                isDraggingOrderStatus: $viewModel.isDraggingOrderStatus)

            StatusItemDivider(
                itemID: 0, currentID: viewModel.currentItemPickedID)
            StatusItem(
                itemID: 0,
                currentID: $viewModel.currentItemPickedID,
                isDraggingOrderStatus: $viewModel.isDraggingOrderStatus)

            StatusItemDivider(
                itemID: 1, currentID: viewModel.currentItemPickedID)
            StatusItem(
                itemID: 1,
                currentID: $viewModel.currentItemPickedID,
                isDraggingOrderStatus: $viewModel.isDraggingOrderStatus)

            StatusItemDivider(
                itemID: 2, currentID: viewModel.currentItemPickedID)
            StatusItem(
                itemID: 2,
                currentID: $viewModel.currentItemPickedID,
                isDraggingOrderStatus: $viewModel.isDraggingOrderStatus)

            StatusItemDivider(
                itemID: 3, currentID: viewModel.currentItemPickedID)
            StatusItem(
                itemID: 3,
                currentID: $viewModel.currentItemPickedID,
                isDraggingOrderStatus: $viewModel.isDraggingOrderStatus)

            StatusItemDivider(
                itemID: 4, currentID: viewModel.currentItemPickedID)
            StatusItem(
                itemID: 4,
                currentID: $viewModel.currentItemPickedID,
                isDraggingOrderStatus: $viewModel.isDraggingOrderStatus)
        }
        .animation(
            .easeInOut(duration: 0.2),
            value: viewModel.currentItemPickedID
        )
        .padding()
    }
}

struct OrderDeliveryDetails: View {
    let order: AdminOrderModel
    @Binding var clientDetails: ClientDetailsModel

    var body: some View {
        VStack(alignment: .center) {
            Text("Client details")
                .bold()
            Text(clientDetails.name)
            Text(clientDetails.phoneNumber)
            Text(clientDetails.email)
                .foregroundStyle(.primary)

            Spacer()

            Text("Order details")
                .bold()
            Text(
                "On Time: \(order.date.formatted(date: .numeric, time: .shortened))"
            )
            Text("Payment type: \(order.paymentType)")

            Spacer()

            Text("Address details")
                .bold()

            Text(
                order.address
            )
            Text(
                "\nEntranceway: \(order.entranceway.isEmpty ? "-" : order.entranceway)"
            )
            Text(
                "Apartment: \(order.apartment.isEmpty ? "-" : order.apartment)")
            Text("Intercom: \(order.intercom.isEmpty ? "-" : order.intercom)")
            Text("Floor: \(order.floor.isEmpty ? "-" : order.floor)")
            Text(
                "Comment: \(order.orderComment.isEmpty ? "-" : order.orderComment)"
            )
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

struct OrderContents: View {
    let order: AdminOrderModel

    var body: some View {
        VStack(alignment: .leading) {
            DashedLine()
            ForEach(order.positions, id: \.foodID) { position in

                HStack {
                    Text(position.foodName)
                    Spacer()
                    Text(
                        "x\(position.amount) $\(String(format: "%.2f", position.price))"
                    )
                }
                .padding()

                DashedLine()
            }

            HStack {
                Spacer()
                Text("$\(String(format: "%.2f", order.totalPrice))")
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
        }
        .bold()
        .monospaced()
        .padding(.top)
    }
}
