//
//  AddressSelectionView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 06.04.2024.
//

import SwiftUI

struct AddressSelectionView: View {
    @State private var isAddNewAddressViewPresented = false
    
    var body: some View {
        Form {
            Section("Select the address") {
                Picker("", selection: .constant(1)) {
                    Text("Address 1").tag(1)
                    Text("Address 2").tag(2)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            Section("") {
                Button(action: { isAddNewAddressViewPresented = true }, label: {
                    Text("Add a new address")
                        .bold()
                        .foregroundStyle(.red)
                })
            }
        }
        .fullScreenCover(isPresented: $isAddNewAddressViewPresented, onDismiss: {}, content: {
            AddNewAddressView()
        })
    }
}

#Preview {
    AddressSelectionView()
}
