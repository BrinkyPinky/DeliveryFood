//
//  AddNewAddressView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 06.04.2024.
//

import SwiftUI
import MapKit
import CoreLocation

struct AddNewAddressView: View {
    @StateObject private var viewModel = AddNewAddressViewModel()
    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                ZStack {
                    VStack {
                        ZStack {
                            MapView(viewModel: viewModel)
                            
                            Circle()
                                .stroke(lineWidth: 5)
                                .foregroundStyle(.red)
                                .frame(width: viewModel.firstCircleWidth)
                                .opacity(viewModel.firstCircleOpacity)
                                .allowsHitTesting(false)
                            Circle()
                                .stroke(lineWidth: 4)
                                .foregroundStyle(.red)
                                .grayscale(0.4)
                                .frame(width: viewModel.secondCircleWidth)
                                .opacity(viewModel.secondCircleOpacity)
                                .allowsHitTesting(false)
                            Image(uiImage: UIImage(named: "pointOnTheMap.png")!)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                                .offset(y: -20)
                                .offset(y: viewModel.pointOnTheMapY)
                                .allowsHitTesting(false)
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        viewModel.startUpdate()
                                    }, label: {
                                        Circle()
                                            .frame(width: 60)
                                            .foregroundStyle(.black)
                                            .overlay {
                                                Image(systemName: "paperplane.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .padding()
                                                    .foregroundStyle(.white)
                                            }
                                    })
                                    .padding()
                                }
                            }
                        }
                        Spacer()
                    }
                    VStack {
                        Spacer()
                        VStack {
                            CustomTextFieldView(
                                textFieldString: $viewModel.addressText,
                                textFieldPlaceholder: "City, street, house number"
                            )
                            HStack {
                                CustomTextFieldView(
                                    textFieldString: $viewModel.entrancewayText,
                                    textFieldPlaceholder: "Entranceway"
                                )
                                CustomTextFieldView(
                                    textFieldString: $viewModel.intercomNumberText,
                                    textFieldPlaceholder: "Intercom number"
                                )
                            }
                            HStack {
                                CustomTextFieldView(
                                    textFieldString: $viewModel.floorText,
                                    textFieldPlaceholder: "Floor"
                                )
                                CustomTextFieldView(
                                    textFieldString: $viewModel.apartmentText,
                                    textFieldPlaceholder: "Apartment"
                                )
                            }
                            CustomTextFieldView(
                                textFieldString: $viewModel.orderCommentText,
                                textFieldPlaceholder: "Order comment"
                            )
                        }
                        .padding()
                        .background(
                            Rectangle()
                                .foregroundStyle(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        )
                        .padding(.top, -24)
                        .frame(height: geometry.size.height/3)
                    }
                }
            }
            .onAppear {
                viewModel.startUpdate()
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .errorMessageView(errorMessage: viewModel.errorMessage, isShowed: $viewModel.isErrorShowed)
        })
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: MapView

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: AddNewAddressViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(viewModel.userRegion, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        //Получение адреса исходя из координат карты
        //Включается через 2 секунды после того как с картой прекратили взаимодействие
        //Отменяется при условии что с картой начали взаимодействие
        var workItem: DispatchWorkItem?
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            workItem?.cancel()
            parent.viewModel.startPointOnTheMapAnimation()
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            workItem = DispatchWorkItem {
                self.parent.viewModel.getAddressFromRegion()
                self.parent.viewModel.stopPointOnTheMapAnimation()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem!)
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            self.parent.viewModel.userRegion = mapView.region
        }
    }
}

#Preview {
    AddNewAddressView()
}

// MARK: CustomTextFieldView
struct CustomTextFieldView: View {
    @Binding var textFieldString: String
    var textFieldPlaceholder: String
    @State private var isTextFieldEditing = false
    
    var body: some View {
        GeometryReader(content: { geometry in
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.quaternary)
                .frame(height: geometry.size.height)
                .overlay {
                    HStack {
                        Text(textFieldPlaceholder)
                            .offset(y: textFieldString == "" ? 0 : -17)
                            .font(textFieldString == "" ? .callout : .caption)
                            .foregroundStyle(.secondary)
                            .animation(.easeInOut(duration: 0.1), value: textFieldString)
                        Spacer()
                    }
                    .padding([.leading, .trailing], 16)
                    TextField("", text: $textFieldString, onEditingChanged: { editing in
                        isTextFieldEditing = editing
                    })
                    .padding([.leading, .trailing], 16)
                    .searchable(text: .constant("rwqrqw"))
                }
                .onTapGesture {
                    isTextFieldEditing = false
                }
        })
    }
}
