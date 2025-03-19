//
//  GeocoderManager.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 07.04.2024.
//

import Foundation
import SwiftyJSON

final class GeocoderManager {
    static let shared = GeocoderManager()
    
    /// Получает адрес и координаты по введенным пользователем данным либо выранным на карте координатам
    /// - Parameters:
    ///   - isByCoordinates: Осуществлять поиск по координатам или по тексту которые ввел пользователь
    ///   - addressOrCoordinates: Координаты или адрес по котором будет осуществляться поиск
    ///   - completion: Возвращает результат
    func getAddresByAddresOrCoordinates(isByCoordinates: Bool, addressOrCoordinates: String, completion: @escaping (Result<[SearchAddressModel], Error>) -> ()) {
        
        var url: URL?
        
        //Если поиск по координатам то отбираем только адреса с номером дома
        if isByCoordinates {
            url = URL(
                string: "https://geocode-maps.yandex.ru/1.x/?apikey=909952b1-fb53-46e9-a2f6-5545d459f0ec" +
                "&geocode=\(addressOrCoordinates)&kind=house&format=json")
        } else {
            url = URL(
                string: "https://geocode-maps.yandex.ru/1.x/?apikey=909952b1-fb53-46e9-a2f6-5545d459f0ec" +
                "&geocode=\(addressOrCoordinates)&format=json")
        }
        
        guard let url = url else { 
            completion(.failure(AddNewAddressError.unknownError))
            return 
        }
        
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            if let data = data {
                do {
                    let json = try JSON(data: data)
                    
                    guard let geoObjects = json["response"]["GeoObjectCollection"]["featureMember"].array else {
                        completion(.failure(AddNewAddressError.JSONDataProcessingError))
                        return
                    }
                    
                    //Массив найденных адресов
                    var searchAddressModels = [SearchAddressModel]()
                    
                    //Пробегаем по всему массиву найденных адресов
                geoObjectsLoop: for geoObject in geoObjects {
                    //Получаем необходимые поля для модели
                    guard let name = geoObject["GeoObject"]["name"].string,
                          let description = geoObject["GeoObject"]["description"].string,
                          let pos = geoObject["GeoObject"]["Point"]["pos"].string,
                          let kind = geoObject["GeoObject"]["metaDataProperty"]["GeocoderMetaData"]["kind"].string
                    else {
                        completion(.failure(AddNewAddressError.JSONDataProcessingError))
                        return
                    }
                    
                    
                    //Получаем координаты локации
                    let coordinates = pos.split(separator: " ")
                    guard let longtitude = Double(coordinates[0]),
                          let latitude = Double(coordinates[1])
                    else {
                        completion(.failure(AddNewAddressError.JSONDataProcessingError))
                        return
                    }
                    
                    searchAddressModels.append(.init(
                        name: name,
                        description: description,
                        latitude: latitude,
                        longtitude: longtitude,
                        kind: kind
                    ))
                    
                    //Если по координатам то нам нужен только один адрес
                    if isByCoordinates {
                        break geoObjectsLoop
                    }
                }
                    
                    //Если ничего не нашлось, то тоже выдаем ошибку о том, что сюда не доставляем
                    if searchAddressModels.isEmpty {
                        completion(.failure(AddNewAddressError.undeliverable))
                    } else {
                        completion(.success(searchAddressModels))
                    }
                    
                } catch {
                    completion(.failure(AddNewAddressError.JSONDataProcessingError))
                }
            }
            
            if error != nil {
                completion(.failure(AddNewAddressError.gettingDataError))
            }
        }.resume()
    }
}
