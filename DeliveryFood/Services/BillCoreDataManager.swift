//
//  CoreDataManager.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 31.03.2024.
//

import CoreData

final class BillCoreDataManager: ObservableObject {
    @Published var billPositions = [PositionForBillModel]()
    
    static let shared = BillCoreDataManager()
    
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
            try fetchData()
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
                newBillPosition.referenceForItself = "Food/\(foodModel.foodID)"
            }
        } catch {
            throw CoreDataError.addError
        }
        
        do {
            try saveContext()
            try fetchData()
        } catch {
            throw error
        }
    }
    
    /// Добавляет позиции в чек на основе предыдущего заказа
    func addBillPositionsFromPreviousOrder(orderModel: PreviousOrderModel) throws {
        orderModel.positions.forEach({
            let newBillPosition = PositionForBillModel(context: context)
            newBillPosition.foodID = $0.foodID
            newBillPosition.amount = Int16($0.amount)
            newBillPosition.foodName = $0.foodName
            newBillPosition.timestamp = Date()
            // Цену можно добавлять старую так как при заказе проверяется не изменились ли цены
            newBillPosition.price = $0.price
            newBillPosition.referenceForItself = $0.referenceForItself
        })
        
        do {
            try saveContext()
            try fetchData()
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
            try fetchData()
        } catch {
            throw error
        }
    }
    
    // Удаляет все позиции в чеке
    func removeAllBillPositions() {
        billPositions.forEach({ context.delete($0) })
        
        do {
            try saveContext()
            try fetchData()
        } catch {}
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
            try fetchData()
        } catch {
            throw error
        }
    }
    
    // Обновляет цены на товары
    func updatePrices(foodModels: [DetailFoodModel]) throws {
        foodModels.forEach { foodModel in
            let billPosition = billPositions.first(where: { $0.foodID == foodModel.foodID })
            billPosition?.price = foodModel.price
        }
        
        do {
            try saveContext()
            try fetchData()
        } catch {
            throw error
        }
    }
    
    /// Обновляет, загружает позиции в чеке
    private func fetchData() throws {
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
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw CoreDataError.saveError
            }
        }
    }
}
