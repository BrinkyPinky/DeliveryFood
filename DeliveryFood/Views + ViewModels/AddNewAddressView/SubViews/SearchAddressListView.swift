//
//  SearchAddressListView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 10.04.2024.
//

import SwiftUI

struct SearchAddressListView: View {
    @ObservedObject var viewModel: AddNewAddressViewModel
    
    var body: some View {
        List {
            if !viewModel.searchAddressSuggestions.isEmpty {
                ForEach(viewModel.searchAddressSuggestions) { addressModel in
                    Button {
                        viewModel.selectAddress(addressModel: addressModel)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(addressModel.name)
                                Text(addressModel.description)
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(SearchAddressListButtonStyle())

                }
                .listRowBackground(Color.primary)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                // Показывать что сейчас загружаются адреса
            } else if viewModel.isSearchingAddress {
                ForEach(0..<6) { _ in
                    VStack(alignment: .leading) {
                        Text("Lorem ipsum dolor sit")
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam lectus")
                            .font(.caption)
                    }
                    .lineLimit(1)
                    .redacted(reason: .placeholder)
                    .foregroundStyle(
                        LinearGradient(colors: [Color(uiColor: .systemGray), Color(uiColor: .systemGray6)],
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )
                }
                .listRowBackground(Color.primary)
                // Показывает что нужно начать вводить
            } else {
                HStack {
                    Spacer()
                    
                    Text("Start typing...")
                        .foregroundStyle(.gray)
                    
                    Spacer()
                }
                .listRowBackground(Color.primary)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .transition(.scale.combined(with: .opacity))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(maxHeight: 300)
    }
}

fileprivate struct SearchAddressListButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color(uiColor: .secondarySystemFill) : .primary)
            .foregroundColor(Color(uiColor: .systemBackground))
    }
}
