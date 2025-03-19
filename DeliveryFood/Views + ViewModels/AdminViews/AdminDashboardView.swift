//
//  AdminDashboardView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 09.03.2025.
//

import SwiftUI

struct AdminDashboardView: View {
    
    var body: some View {
        ZStack {
            Color(red: 106 / 255, green: 82 / 255, blue: 239 / 255)
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                HStack {
                    AdminCustomNavBar()

                    Spacer()

                    Text("Daily statistics")
                        .bold()

                }
                .foregroundStyle(Color.white)
                .padding(.horizontal)

                HStack(spacing: 16) {
                    StatisticInformationView(
                        statisticValue: "0", statisticDescription: "Orders")
                    StatisticInformationView(
                        statisticValue: "$0", statisticDescription: "Profit")
                }
                .padding(.bottom, 8)
                .padding(.horizontal)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        NavigationLink {
                            AdminListOfOrdersView()
                        } label: {
                            AdminSettingsDashboardPartView(settingText: "Orders", settingImageName: "list.bullet.below.rectangle")
                        }
                        
                        NavigationLink {
                            ReorderCategoriesView()
                        } label: {
                            AdminSettingsDashboardPartView(settingText: "Edit Products", settingImageName: "rectangle.and.pencil.and.ellipsis")
                        }

                        AdminSettingsDashboardPartView(settingText: "Statistics", settingImageName: "chart.line.uptrend.xyaxis")
                            .opacity(0.5)
                    }
                    .foregroundStyle(Color.primary)
                    .padding(.top)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .background {
                    RoundedRectangle(cornerRadius: 40)
                        .foregroundStyle(.background)
                }
                .ignoresSafeArea()
            }
        }
        .toolbar(.hidden)
    }
}

struct AdminSettingsDashboardPartView: View {
    let settingText: String
    let settingImageName: String
    
    var body: some View {
        VStack {
            Image(systemName: settingImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundStyle(RadialGradient(colors: [.blue, .purple], center: UnitPoint.bottomLeading, startRadius: 5, endRadius: 100))

            Text(settingText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 1)
                .opacity(0.2)
        }
    }
}

struct StatisticInformationView: View {
    let statisticValue: String
    let statisticDescription: String

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(statisticValue)
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.white)
                        .monospaced()

                    Text(statisticDescription)
                        .font(.footnote)
                        .bold()
                        .foregroundStyle(
                            Color(
                                red: 152 / 255, green: 160 / 255,
                                blue: 248 / 255))
                }
                Spacer()
            }
        }
        .lineLimit(1)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(
                    Color(red: 125 / 255, green: 104 / 255, blue: 248 / 255))

        }
    }
}

#Preview {
    NavigationStack {
        AdminDashboardView()
    }
}
