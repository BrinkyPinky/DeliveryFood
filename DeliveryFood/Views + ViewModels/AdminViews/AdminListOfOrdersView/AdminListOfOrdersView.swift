//
//  AdminListOfOrdersView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 14.03.2025.
//

import SwiftUI

struct AdminListOfOrdersView: View {
    @StateObject private var viewModel = AdminListOfOrdersViewModel()

    var body: some View {
        VStack {
            HStack {
                AdminCustomNavBar()
                    .padding(.horizontal)

                Spacer()

                Button {
                    viewModel.isDatePickerShowed.toggle()
                } label: {
                    Text(
                        "\(viewModel.currentPickedDate.formatted(date: .numeric, time: .omitted))"
                    )
                    .monospaced()
                    .bold()

                    Image(systemName: "chevron.right")
                        .rotationEffect(
                            Angle(
                                degrees: viewModel.isDatePickerShowed ? 90 : 0)
                        )
                        .bold()
                }
                .foregroundStyle(Color.primary)
            }
            .padding(.horizontal)

            if viewModel.isDatePickerShowed {
                DatePicker(
                    "", selection: $viewModel.currentPickedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .transition(
                    .opacity.combined(
                        with: .scale.combined(with: .move(edge: .top))))
            }

            List {
                if viewModel.areOrdersLoading {
                    ForEach(0..<6) { _ in
                        OrderInfoView(
                            adminOrderModel: nil, isRedacted: true)
                    }
                } else if !viewModel.areOrdersLoading
                    && viewModel.orders.isEmpty
                    && viewModel.completedOrders.isEmpty
                {
                    HStack {
                        Spacer()
                        Text("There are no orders for this date")
                            .bold()
                        Spacer()
                    }
                } else {
                    ForEach(viewModel.orders, id: \.orderID) {
                        orderModel in
                        NavigationLink {
                            AdminEditOrderView(adminOrderModel: orderModel)
                        } label: {
                            OrderInfoView(
                                adminOrderModel: orderModel,
                                isRedacted: false)
                        }
                    }

                    if !viewModel.completedOrders.isEmpty {
                        Section("Completed") {
                            ForEach(viewModel.completedOrders, id: \.orderID) {
                                orderModel in
                                NavigationLink {
                                    AdminEditOrderView(adminOrderModel: orderModel)
                                } label: {
                                    OrderInfoView(
                                        adminOrderModel: orderModel,
                                        isRedacted: false)
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .animation(
            .easeInOut(duration: 0.2), value: viewModel.orders.count
        )
        .errorMessageView(
            errorMessage: viewModel.errorText,
            isShowed: $viewModel.isErrorShowed
        )
        .animation(
            .easeInOut(duration: 0.2), value: viewModel.isDatePickerShowed
        )
        .onChange(of: viewModel.currentPickedDate) { _, newValue in
            viewModel.loadOrders()
        }
        .onAppear {
            viewModel.onAppearAction()
        }
        .toolbar(.hidden)
    }
}

#Preview {
    AdminListOfOrdersView()
}

struct OrderInfoView: View {
    let adminOrderModel: AdminOrderModel
    let isRedacted: Bool

    init(adminOrderModel: AdminOrderModel?, isRedacted: Bool) {
        guard let adminOrderModel = adminOrderModel else {
            self.adminOrderModel = .mock
            self.isRedacted = true
            return
        }
        self.adminOrderModel = adminOrderModel
        self.isRedacted = isRedacted
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Status")
                    .bold()

                HStack {
                    Text(adminOrderModel.orderStatus.orderStatusDecode())
                    Image(
                        systemName: adminOrderModel.orderStatus < 0
                            ? "xmark.circle.fill"
                            : adminOrderModel.orderStatus == 4
                                ? "checkmark.circle.fill"
                                : "circle.hexagongrid.circle.fill"
                    )
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .animation(
                        .easeInOut(duration: 0.2),
                        value: adminOrderModel.orderStatus
                    )
                    .frame(height: 25)
                    .foregroundStyle(
                        adminOrderModel.orderStatus < 0
                            ? Color.red : Color.green
                    )
                    .opacity(isRedacted ? 0 : 1)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(
                    "On Time: "
                        + adminOrderModel.date.formatted(
                            date: .omitted, time: .shortened)
                )

                Text(adminOrderModel.orderID)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
        }
        .redacted(reason: isRedacted ? .placeholder : .invalidated)
    }
}
