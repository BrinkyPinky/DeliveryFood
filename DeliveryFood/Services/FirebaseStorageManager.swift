//
//  FirebaseStorageManager.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import Foundation
import FirebaseStorage

class FirebaseStorageManager {
    static var shared = FirebaseStorageManager()
    
    private let storage = Storage.storage()
    
    func downloadImage(withURL url: String, completion: @escaping (Data?) -> Void) {
        let ref = storage.reference(forURL: url)
        
        ref.getData(maxSize: 1024*1024) { data, _ in
            completion(data)
        }
    }
}
