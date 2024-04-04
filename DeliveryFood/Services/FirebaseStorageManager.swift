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
    
    private let storage = Storage.storage()
    var smth = 1
    func downloadImage(withURL url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard (URL(string: url) != nil) else {
            completion(.failure(FirebaseStorageError.getDataError))
            return
        }
        
        let ref = storage.reference(forURL: url)

        ref.getData(maxSize: 1024*1024) { data, error in
            guard let data = data else { completion(.failure(error!)); return }
            completion(.success(data))
        }
        smth += 1
    }
}
