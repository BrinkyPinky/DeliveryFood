//
//  AddressSelectionView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 06.04.2024.
//

import SwiftUI

struct AddressSelectionView: View {
    // Показана ли вью для добавления нового адреса
    @State private var isAddNewAddressViewPresented = false
    
    // Ошибка
    @State private var isErrorShowed = false
    @State private var errorMessage = ""
    
    // Заголовок секции с адресами
    let sectionHeader: String
    
    // Выбранный адресс
    @Binding var selectedAddressModel: AddressModel?
    
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var coreDataManager = AddressCoreDataManager.shared
    
    // Initializer for OrderConfirmView
    init(selectedAddressModel: Binding<AddressModel?>) {
        self._selectedAddressModel = selectedAddressModel
        sectionHeader = "Select the address"
    }
    
    // Initializer for AccountView
    init() {
        self._selectedAddressModel = .constant(nil)
        sectionHeader = "Addresses"
    }
    
    var body: some View {
        Form {
            Section(sectionHeader) {
                ForEach(coreDataManager.addresses) { addressModel in
                    addressRow(addressModel: addressModel, currentSelectedAddressModel: $selectedAddressModel, selectAction: changeSelectedAddressModel)
                }
                .onDelete(perform: { indexSet in
                    do {
                        try coreDataManager.removeAddressByIndexSet(indexSet)
                        selectedAddressModel = nil
                    } catch {
                        errorMessage = error.localizedDescription
                        isErrorShowed = true
                    }
                })
            }
            
            Section("") {
                Button {
                    guard coreDataManager.addresses.count < 10 else {
                        errorMessage = "You cannot add more than 10 addresses. Delete addresses that are not in use"
                        isErrorShowed = true
                        return
                    }
                    isAddNewAddressViewPresented = true
                } label: {
                    Text("Add a new address")
                        .bold()
                        .foregroundStyle(.red)
                }
            }
        }
        .errorMessageView(errorMessage: errorMessage, isShowed: $isErrorShowed)
        .fullScreenCover(isPresented: $isAddNewAddressViewPresented, onDismiss: {}, content: {
            AddNewAddressView()
        })
    }
    
    func changeSelectedAddressModel(with addressModel: AddressModel) {
        do {
            try AddressCoreDataManager.shared.changeLastUsedAddress(addressModel: addressModel)
        } catch {}
        selectedAddressModel = addressModel
        dismiss()
    }
}

#Preview {
    AddressSelectionView(selectedAddressModel: .constant(nil))
}

struct addressRow: View {
    let addressModel: AddressModel
    @Binding var currentSelectedAddressModel: AddressModel?
    let selectAction: (AddressModel) -> ()
    
    var body: some View {
        HStack {
            Button {
                selectAction(addressModel)
            } label: {
                VStack(alignment: .leading) {
                    Text(addressModel.addressName)
                    Text(addressModel.addressDescription)
                        .foregroundStyle(.gray)
                        .font(.caption)
                }
            }
            
            Spacer()
            
            if currentSelectedAddressModel == addressModel {
                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
                    .bold()
            }
        }
        .lineLimit(1)
        .foregroundStyle(Color.primary)
        .animation(.easeInOut, value: currentSelectedAddressModel)
    }
}
