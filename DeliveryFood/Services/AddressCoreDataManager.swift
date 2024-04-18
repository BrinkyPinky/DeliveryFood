//
//  AddressCoreDataManager.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 10.04.2024.
//

import CoreData

final class AddressCoreDataManager: ObservableObject {
    static let shared = AddressCoreDataManager()
    
    @Published var addresses = [AddressModel]()
    
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init() {
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                print("Unresolved error \(error.localizedDescription)")
            }
        })
        context = persistentContainer.viewContext
        
        do {
            try fetchData()
        } catch {
            print("Unresolved error \(error.localizedDescription)")
        }
    }
    
    // Добавить новый адрес
    func addNewAddress(
        searchAddressModel: SearchAddressModel,
        entranceway: String,
        intercom: String,
        floor: String,
        apartment: String,
        orderComment: String
    ) throws {
        let newAddress = AddressModel(context: context)
        newAddress.addressName = searchAddressModel.name
        newAddress.addressDescription = searchAddressModel.description
        newAddress.latitude = searchAddressModel.latitude
        newAddress.longtitude = searchAddressModel.longtitude
        newAddress.entranceway = entranceway
        newAddress.intercomNumber = intercom
        newAddress.floor = floor
        newAddress.apartment = apartment
        newAddress.orderComment = orderComment
        newAddress.lastUsed = Date()
        
        do {
            try saveData()
            try fetchData()
        } catch {
            throw error
        }
    }
    
    // Удаляет адрес
    func removeAddressByIndexSet(_ indexSet: IndexSet) throws {
        indexSet.forEach({ context.delete(addresses[$0]) })
        
        do {
            try saveData()
            try fetchData()
        } catch {
            throw error
        }
    }
    
    // Изменить последний используемый адрес
    func changeLastUsedAddress(addressModel: AddressModel) throws {
        addressModel.lastUsed = Date()
        
        do {
            try saveData()
        } catch {
            throw error
        }
    }
    
    // Получить последний используемый адрес
    func getLastUsedAddress() throws -> AddressModel? {
        let request = AddressModel.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "lastUsed", ascending: false)]
        
        do {
            return try context.fetch(request).first
        } catch {
            throw CoreDataError.fetchError
        }
    }
    
    private func fetchData() throws {
        let request = AddressModel.fetchRequest()
        do {
            addresses = try context.fetch(request)
        } catch {
            throw CoreDataError.fetchError
        }
    }
    
    private func saveData() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw CoreDataError.saveError
            }
        }
    }
}
