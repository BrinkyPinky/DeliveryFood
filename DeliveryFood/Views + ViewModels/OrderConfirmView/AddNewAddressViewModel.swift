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
    
    //Анимация точки на карте
    @Published var pointOnTheMapY: CGFloat = 0
    @Published var firstCircleWidth: CGFloat = 0
    @Published var secondCircleWidth: CGFloat = 0
    @Published var firstCircleOpacity: CGFloat = 0
    @Published var secondCircleOpacity: CGFloat = 0.6
    var animationTimer: Timer?
    
    //Текущее местоположение карты
    @Published var userRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.75222, longitude: 37.61556),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    //TextFields
    @Published var addressText = ""
    @Published var entrancewayText = ""
    @Published var intercomNumberText = ""
    @Published var floorText = ""
    @Published var apartmentText = ""
    @Published var orderCommentText = ""
    
    //ErrorView
    @Published var isErrorShowed = false
    var errorMessage = "Some Error"
    
    // MARK: Start
    /// Получить местоположение пользователя
    func startUpdate() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    // MARK: Animation
    //Запустить анимацию точки на карте
    func startPointOnTheMapAnimation() {
        guard animationTimer == nil else { return }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.1, repeats: true) { _ in
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
        
        animationTimer?.fire()
    }
    
    //Остановить анимацию точки на карте
    func stopPointOnTheMapAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    // MARK: Address convertions
    /// Получить адресс из региона
    /// - Parameter region: центр карты
    func getAddressFromRegion() {
        let location = CLLocation(latitude: self.userRegion.center.latitude, longitude: self.userRegion.center.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { [self] placemarks, error in
            //Если имеется город, улица и номер дома
            if let placemark = placemarks?.first {
                if let city = placemark.locality,
                   let street = placemark.thoroughfare,
                   let houseNumber = placemark.subThoroughfare {
                    addressText = "\(city), \(street), \(houseNumber)"
                    //Если имеется округ и название района
                } else if let district = placemark.subAdministrativeArea,
                          let neighborhood = placemark.subLocality {
                    addressText = "\(district), \(neighborhood)"
                } else {
                    errorMessage = AddNewAddressError.undeliverable.localizedDescription
                    isErrorShowed = true
                }
            }
            
            if let error = error {
                errorMessage = error.localizedDescription
                isErrorShowed = true
            }
        }
    }
    
    
    
    // MARK: CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userRegion.center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            userRegion.span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            return
        case .restricted:
            errorMessage = AddNewAddressError.geopositionAccessError.localizedDescription
            isErrorShowed = true
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied:
            errorMessage = AddNewAddressError.geopositionAccessError.localizedDescription
            isErrorShowed = true
        default:
            errorMessage = AddNewAddressError.unknownError.localizedDescription
            isErrorShowed = true
        }
    }
}
