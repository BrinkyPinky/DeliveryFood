//
//  FirebaseStorageManager.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import FirebaseStorage
import Foundation
import UIKit.UIImage

final class FirebaseStorageManager {
    static var shared = FirebaseStorageManager()

    //cache
    let cache = NSCache<NSString, NSData>()

    private let storage = Storage.storage()

    /// Скачивает изображение с сервера Firebase Storage или подгружает из Кэша
    /// - Parameters:
    ///   - url: Ссылка на изображение из сервера FireBase Storage
    ///   - completion: Возвращает либо Data либо Error
    func downloadImage(
        withPath path: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        let path = path + ".png"

        if let imageData = cache.object(forKey: NSString(string: path)) {
            completion(.success(imageData as Data))
            return
        }

        let ref = storage.reference(withPath: path)

        ref.getData(maxSize: 1024 * 1024) { data, error in
            guard let data = data else {
                completion(.failure(error!))
                return
            }

            self.cache.setObject(
                NSData(data: data), forKey: NSString(string: path))

            completion(.success(data))
        }
    }

    func uploadImage(
        withPath path: String, image: UIImage,
        completion: @escaping (Result<Any?, Error>) -> Void
    ) {

        image.compressPNGImage(targetSizeInBytes: 1024 * 1024) { [unowned self] imageData in
            guard let imageData = imageData else {
                completion(.failure(AdminError.imageCompressingError))
                return
            }

            let path = path + ".png"

            let metadata = StorageMetadata()
            metadata.contentType = "image/png"

            storage.reference(withPath: path).putData(
                imageData, metadata: metadata
            ) { _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(nil))
                }
            }
        }
    }

    func removeImage(
        withPath path: String,
        completion: @escaping (Result<Any?, Error>) -> Void
    ) {
        let path = path + ".png"

        storage.reference(withPath: path).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(nil))
            }
        }
    }
}
