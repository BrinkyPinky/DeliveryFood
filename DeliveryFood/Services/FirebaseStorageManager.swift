//
//  FirebaseStorageManager.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import Foundation
import FirebaseStorage

final class FirebaseStorageManager {
    static var shared = FirebaseStorageManager()
    
    //cache
    let cache = NSCache<NSString, NSData>()
    
    private let storage = Storage.storage()
    
    /// Скачивает изображение с сервера Firebase Storage или подгружает из Кэша
    /// - Parameters:
    ///   - url: Ссылка на изображение из сервера FireBase Storage
    ///   - completion: Возвращает либо Data либо Error
    func downloadImage(withURL url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard (URL(string: url) != nil) else {
            completion(.failure(FirebaseFirestoreError.getDataError))
            return
        }
        
        if let imageData = cache.object(forKey: NSString(string: url)) {
            completion(.success(imageData as Data))
            return
        }
        
        let ref = storage.reference(forURL: url)
        
        ref.getData(maxSize: 1024*1024) { data, error in
            guard let data = data else {
                completion(.failure(error!))
                return
            }
            
            self.cache.setObject(NSData(data: data), forKey: NSString(string: url))
            
            completion(.success(data))
        }
    }
}
