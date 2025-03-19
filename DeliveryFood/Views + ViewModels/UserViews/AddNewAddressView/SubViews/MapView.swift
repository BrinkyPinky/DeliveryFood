//
//  MapView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 10.04.2024.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: AddNewAddressViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if viewModel.isShowedTextFields == true {
            uiView.isUserInteractionEnabled = false
        } else {
            uiView.isUserInteractionEnabled = true
        }
        
        guard viewModel.isNeedToUpdateMap else { return }
        uiView.setRegion(viewModel.userRegion, animated: true)
        viewModel.isNeedToUpdateMap = false
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        // Получение адреса исходя из координат карты
        // Включается через 2 секунды после того как с картой прекратили взаимодействие
        // Отменяется при условии что с картой начали взаимодействие
        var getAddressWorkItem: DispatchWorkItem?
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            guard mapView.isUserInteractionEnabled == true else { return }
            
            getAddressWorkItem?.cancel()
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.parent.viewModel.startPointOnTheMapAnimation()
                self.parent.viewModel.addressText = ""
            }
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            guard mapView.isUserInteractionEnabled == true else { return }

            getAddressWorkItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                
                self.parent.viewModel.getAddressFromCoordinate()
                self.parent.viewModel.stopPointOnTheMapAnimation()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: getAddressWorkItem!)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.parent.viewModel.userRegion = mapView.region
            }
        }
    }
}
