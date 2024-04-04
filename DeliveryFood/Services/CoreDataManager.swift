//
//  CoreDataManager.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 31.03.2024.
//

import CoreData

final class CoreDataManager: ObservableObject {
    @Published var billPositions = [PositionForBillModel]()
    
    static let shared = CoreDataManager()
    
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                print("Unresolved error \(error.localizedDescription)")
            }
        })
        context = persistentContainer.viewContext
        
        do {
            try fetchBillPositions()
        } catch {
            print("Unresolved error \(error.localizedDescription)")
        }
    }
    
    /// Добавляет/изменяет позиции в чеке
    /// Если foodID из foodModel совпадают тогда заменяется старый элемент, если же нет тогда создается новый
    /// - Parameter foodModel: DetailFoodModel детальное описание из которого будет происходить выборка нужных параметров для сохранения в чеке
    func addBillPosition(foodModel: DetailFoodModel) throws {
        //Поиск уже имеющейся позиции в чеке
        let request = PositionForBillModel.fetchRequest()
        request.predicate = NSPredicate(format: "foodID == %@", foodModel.foodID)
        
        do {
            let positions = try context.fetch(request)
            if let position = positions.first {
                position.amount += 1
            } else {
                //Добавление новой позиции в чек
                let newBillPosition = PositionForBillModel(context: context)
                newBillPosition.foodID = foodModel.foodID
                newBillPosition.amount = 1
                newBillPosition.foodName = foodModel.name
                newBillPosition.timestamp = Date()
                newBillPosition.price = foodModel.price
            }
        } catch {
            throw CoreDataError.addError
        }
        
        do {
            try saveContext()
            try fetchBillPositions()
        } catch {
            throw error
        }
    }
    
    /// Удаляет позиции в чеке
    /// - Parameter at: индекс элементов на удаление
    func removeBillPosition(at indexSet: IndexSet) throws {
        indexSet.forEach { index in
            let billPosition = billPositions[index]
            context.delete(billPosition)
        }
        
        do {
            try saveContext()
            try fetchBillPositions()
        } catch {
            throw error
        }
    }
    
    /// Изменяет количество на конкретной позиции в чеке. Если значение 0, то удаляет позицию
    /// - Parameters:
    ///   - positionModel: Сама модель базы данных
    ///   - newValue: Новое значение на которое нужно изменить количество
    func changeAmountOfBillPosition(positionModel: PositionForBillModel, toValue newValue: Int) throws {
        if newValue > 0 {
            positionModel.amount = Int16(newValue)
        } else {
            context.delete(positionModel)
        }
        
        do {
            try saveContext()
            try fetchBillPositions()
        } catch {
            throw error
        }
    }
    
    /// Обновляет, загружает позиции в чеке
    private func fetchBillPositions() throws {
        let request = PositionForBillModel.fetchRequest()
        let descriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        request.sortDescriptors = [descriptor]
        
        do {
            billPositions = try context.fetch(request)
        } catch {
            throw CoreDataError.fetchError
        }
    }
    
    /// Сохраняет данные
    private func saveContext() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw CoreDataError.saveError
            }
        }
    }
}
