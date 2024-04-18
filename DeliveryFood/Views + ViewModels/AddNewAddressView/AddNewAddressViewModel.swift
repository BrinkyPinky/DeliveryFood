//
//  AddNewAddressViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 06.04.2024.
//

import CoreLocation
import MapKit
import SwiftUI

final class AddNewAddressViewModel: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let manager = CLLocationManager()
    
    // Анимация точки на карте
    @Published var pointOnTheMapY: CGFloat = 0
    @Published var firstCircleWidth: CGFloat = 0
    @Published var secondCircleWidth: CGFloat = 0
    @Published var firstCircleOpacity: CGFloat = 0
    @Published var secondCircleOpacity: CGFloat = 0.6
    var PointAnimationTimer: Timer?
    
    // Текущее местоположение карты
    @Published var userRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.75222, longitude: 37.61556),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Нужно ли обновить местоположение карты, допустим при запуске
    // Или когда пользователь нажимает на кнопку, которая показывает его текущую локацию
    var isNeedToUpdateMap = true
    
    // MenuWithTextFields
    @Published var addressText = ""
    @Published var entrancewayText = ""
    @Published var intercomNumberText = ""
    @Published var floorText = ""
    @Published var apartmentText = ""
    @Published var orderCommentText = ""
    @Published var isShowedTextFields = false
    @Published var isShowedSearchView = false {
        didSet {
            guard isShowedSearchView == true else { return }
            selectedAddress = nil
        }
    }
    
    // Выбранный адрес
    @Published var selectedAddress: SearchAddressModel?
    // Заглушка если выбранного адреса нет
    let plugSelectedAddress = SearchAddressModel(name: "", description: "", latitude: 0, longtitude: 0, kind: "other")
    
    // Состояние идет ли поиск адресов
    var isSearchingAddress = false
    // Массив адресов которые нашлись
    @Published var searchAddressSuggestions: [SearchAddressModel] = []
    
    var loadCoordinateFromStringWorkItem: DispatchWorkItem?
    
    // ErrorView
    @Published var isErrorShowed = false
    var errorMessage = "Some Error"
    
    // MARK: Start
    /// Получить местоположение пользователя
    func startUpdate() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    // MARK: Error
    private func showErrorWithString(_ string: String) {
        errorMessage = string
        isErrorShowed = true
    }
    
    // MARK: Animation
    // Запустить анимацию точки на карте
    func startPointOnTheMapAnimation() {
        guard PointAnimationTimer == nil else { return }
        
        PointAnimationTimer = Timer.scheduledTimer(withTimeInterval: 1.1, repeats: true) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                self.pointOnTheMapY = -10
            } completion: {
                withAnimation(.easeIn(duration: 0.2)) {
                    self.pointOnTheMapY = 0
                } completion: {
                    withAnimation(.easeIn(duration: 0.5)) {
                        self.firstCircleWidth = 25
                        self.secondCircleWidth = 22
                        self.firstCircleOpacity = 0
                        self.secondCircleOpacity = 0
                    } completion: {
                        self.firstCircleWidth = 0
                        self.secondCircleWidth = 0
                        self.firstCircleOpacity = 1
                        self.secondCircleOpacity = 0.6
                    }
                }
            }
        }
        
        PointAnimationTimer?.fire()
    }
    
    // Остановить анимацию точки на карте
    func stopPointOnTheMapAnimation() {
        PointAnimationTimer?.invalidate()
        PointAnimationTimer = nil
    }
    
    // MARK: Select Address From SearchAddressListView
    // Устанавливает адрес в качестве выбранного пользователем
    func selectAddress(addressModel: SearchAddressModel) {
        guard addressModel.kind == "house" else {
            showErrorWithString(AddNewAddressError.invalidAddress.localizedDescription)
            return
        }
        
        addressText = addressModel.name
        selectedAddress = addressModel
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        isShowedSearchView = false
        userRegion.center = .init(latitude: addressModel.latitude, longitude: addressModel.longtitude)
        isNeedToUpdateMap = true
    }
    
    // MARK: Save Address
    
    /// Сохраняет адрес
    /// - Parameter completionSuccess: Вызывается если сохранение прошло успешно
    func saveAddress(completionSuccess: () -> ()) {
        guard let selectedAddress = selectedAddress else {
            showErrorWithString(AddNewAddressError.saveIncorrectAdrressError.localizedDescription)
            return
        }
        
        do {
            try AddressCoreDataManager.shared.addNewAddress(
                searchAddressModel: selectedAddress,
                entranceway: entrancewayText,
                intercom: intercomNumberText,
                floor: floorText,
                apartment: apartmentText,
                orderComment: orderCommentText
            )
            completionSuccess()
        } catch {
            showErrorWithString(error.localizedDescription)
        }
    }
    
    // MARK: Address convertions
    // Получить адресс исходя из координат
    func getAddressFromCoordinate() {
        //Конвертируем координаты в строку
        let coordinates = "\(userRegion.center.longitude) \(userRegion.center.latitude)"
        
        GeocoderManager.shared.getAddresByAddresOrCoordinates(isByCoordinates: true, addressOrCoordinates: coordinates) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                
                switch result {
                case .success(let addressModel):
                    //Если он вернулся значит точно не пустой поэтому Force Unwrap
                    self.addressText = addressModel.first!.name
                    self.selectedAddress = addressModel.first
                case .failure(let error):
                    guard let error = error as? AddNewAddressError else { return }
                    self.showErrorWithString(error.localizedDescription)
                }
            }
        }
    }
    
    // Получить адрес и координаты локации введенные пользователем вручную
    func getCoordinateFromString(_ text: String) {
        searchAddressSuggestions = []
        loadCoordinateFromStringWorkItem?.cancel()
        isSearchingAddress = true
        
        guard isShowedSearchView, !addressText.isEmpty else {
            isSearchingAddress = false
            return
        }
        
        loadCoordinateFromStringWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            GeocoderManager.shared.getAddresByAddresOrCoordinates(isByCoordinates: false, addressOrCoordinates: text) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let searchModel):
                            self.searchAddressSuggestions = searchModel
                            self.isSearchingAddress = false
                        case .failure(let error):
                            self.isSearchingAddress = false
                            guard let error = error as? AddNewAddressError else { return }
                            self.showErrorWithString(error.localizedDescription)
                        }
                    }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: loadCoordinateFromStringWorkItem!)
    }
    
    // MARK: CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userRegion.center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            userRegion.span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
            manager.stopUpdatingLocation()
            isNeedToUpdateMap = true
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            return
        case .restricted:
            showErrorWithString(AddNewAddressError.geopositionAccessError.localizedDescription)
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied:
            showErrorWithString(AddNewAddressError.geopositionAccessError.localizedDescription)
        default:
            showErrorWithString(AddNewAddressError.unknownError.localizedDescription)
        }
    }
}
