//
//  CustomNavigationBarView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 22.01.2024.
//

import SwiftUI

struct CustomNavigationBarView: View {
    let isLeafNeeded: Bool
    let isBackButtonNeeded: Bool
    let isCartButtonNeeded: Bool
    let isUserProfileNeeded: Bool

    @State private var isAccountViewPresented = false
    @State private var isLoginViewPresented = false
    @State private var isBillViewPresented = false

    @Environment(\.presentationMode) private var presentationMode

    @StateObject private var coreDataManager = BillCoreDataManager.shared

    init(
        isLeafNeeded: Bool, isBackButtonNeeded: Bool, isCartButtonNeeded: Bool,
        isUserProfileNeeded: Bool
    ) {
        self.isLeafNeeded = isLeafNeeded
        self.isBackButtonNeeded = isBackButtonNeeded
        self.isCartButtonNeeded = isCartButtonNeeded
        self.isUserProfileNeeded = isUserProfileNeeded
    }

    var body: some View {
        HStack {
            if isBackButtonNeeded {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.background)
                        .shadow(color: .primary, radius: 1)
                        .overlay {
                            Image(systemName: "chevron.left")
                                .font(
                                    .system(
                                        size: 14, weight: .semibold,
                                        design: .rounded))
                        }
                        .padding(.trailing, 8)
                }
                .buttonStyle(.plain)
            }
            LogotypeView(size: 32, isLeafNeeded: isLeafNeeded)
            Spacer()
            if FirebaseFirestoreAdminManager.shared.isAdmin {
                NavigationLink {
                    AdminDashboardView()
                } label: {
                        Text("Admin")
                            .foregroundStyle(.white)
                            .bold()
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(Color(red: 106 / 255, green: 82 / 255, blue: 239 / 255))
                            }
                            .padding(.horizontal)
                }
            }
            if isUserProfileNeeded {
                Button {
                    if FirebaseAuthManager.shared.isUserLoggedIn() {
                        isAccountViewPresented = true
                    } else {
                        isLoginViewPresented = true
                    }

                } label: {
                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .fontWeight(.thin)
                }
                .sheet(
                    isPresented: $isAccountViewPresented,
                    content: {
                        AccountView(billViewShouldBePresented: {
                            isBillViewPresented = true
                        })
                    }
                )
                .sheet(
                    isPresented: $isLoginViewPresented,
                    content: {
                        AuthView()
                    })
            }
            if isCartButtonNeeded {
                Button {
                    isBillViewPresented = true
                } label: {
                    Image(systemName: "bag")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .fontWeight(.thin)
                        .overlay {
                            if coreDataManager.billPositions.count > 0 {
                                GeometryReader(content: { geometry in
                                    Circle()
                                        .foregroundStyle(Color.red)
                                        .frame(width: 25, height: 25)
                                        .overlay {
                                            Text(
                                                "\(coreDataManager.billPositions.count)"
                                            )
                                            .foregroundStyle(.white)
                                            .fontWidth(.compressed)
                                        }
                                        .offset(
                                            x: geometry.size.width / 2,
                                            y: -geometry.size.height / 4)
                                })
                            }
                        }
                }
                .padding(.leading, 16)
                .navigationDestination(isPresented: $isBillViewPresented) {
                    BillView()
                }
            }
        }
    }
}

#Preview {
    CustomNavigationBarView(
        isLeafNeeded: true, isBackButtonNeeded: true, isCartButtonNeeded: true,
        isUserProfileNeeded: true)
}
