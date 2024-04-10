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
        ZStack {
            MapView(viewModel: viewModel)
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            ZStack {
                if !viewModel.isShowedTextFields {
                    Circle()
                        .stroke(lineWidth: 5)
                        .foregroundStyle(.red)
                        .frame(width: viewModel.firstCircleWidth)
                        .opacity(viewModel.firstCircleOpacity)
                    Circle()
                        .stroke(lineWidth: 4)
                        .foregroundStyle(.red)
                        .grayscale(0.4)
                        .frame(width: viewModel.secondCircleWidth)
                        .opacity(viewModel.secondCircleOpacity)
                    Image(uiImage: UIImage(named: "pointOnTheMap.png")!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .offset(y: -20)
                        .offset(y: viewModel.pointOnTheMapY)
                        .transition(.scale)
                }
            }
            .allowsHitTesting(false)
            VStack {
                
                MenuWithTextFields(viewModel: viewModel)
                    .onChange(of: viewModel.addressText) { _, newValue in
                        viewModel.getCoordinateFromString(newValue)
                    }
                
                Spacer()
                HStack {
                    Spacer()
                    if !viewModel.isShowedTextFields {
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
        }
        .onAppear {
            viewModel.startUpdate()
        }
        .errorMessageView(errorMessage: viewModel.errorMessage, isShowed: $viewModel.isErrorShowed)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isShowedTextFields)
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
        
        //Получение адреса исходя из координат карты
        //Включается через 2 секунды после того как с картой прекратили взаимодействие
        //Отменяется при условии что с картой начали взаимодействие
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

#Preview {
    AddNewAddressView()
}

// MARK: CustomTextFieldView
struct CustomTextFieldForAddressInputView: View {
    @Binding var textFieldString: String
    var textFieldPlaceholder: String
    @Binding var isEditing: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    //Если нужно отслеживать когда textField редактируется
    init(textFieldString: Binding<String>, textFieldPlaceholder: String, isEditing: Binding<Bool>) {
        self._textFieldString = textFieldString
        self.textFieldPlaceholder = textFieldPlaceholder
        self._isEditing = isEditing
    }
    
    init(textFieldString: Binding<String>, textFieldPlaceholder: String) {
        self._textFieldString = textFieldString
        self.textFieldPlaceholder = textFieldPlaceholder
        self._isEditing = .constant(false)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundStyle(Color(uiColor: colorScheme == .dark ? .systemGray : .systemFill))
            .opacity(colorScheme == .dark ? 0.13 : 1)
            .frame(height: 50)
            .overlay {
                HStack {
                    Text(textFieldPlaceholder == "" ? "City, street, apartment number" : textFieldPlaceholder)
                        .lineLimit(1)
                        .offset(y: textFieldString == "" ? 0 : -15)
                        .font(textFieldString == "" ? .callout : .caption)
                        .foregroundStyle(.gray)
                        .animation(.easeInOut(duration: 0.1), value: textFieldString)
                    Spacer()
                }
                .padding([.leading, .trailing], 16)
                TextField("", text: $textFieldString, onEditingChanged: { isEditing in
                    self.isEditing = isEditing
                })
                .padding([.leading, .trailing], 16)
                .foregroundStyle(Color(uiColor: .systemBackground))
            }
    }
}

// MARK: MenuWithTextFields

struct MenuWithTextFields: View {
    @ObservedObject var viewModel: AddNewAddressViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    //dismiss
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                
                Button {
                    viewModel.isShowedTextFields.toggle()
                    guard !viewModel.isShowedTextFields else { return }
                    viewModel.isShowedSearchView = false
                } label: {
                    HStack {
                        if !viewModel.isShowedTextFields {
                            Text(viewModel.addressText == "" ? "Loading location..." : viewModel.addressText)
                                .lineLimit(1)
                                .transition(.slide.combined(with: .opacity).combined(with: .scale))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(viewModel.isShowedTextFields ? .degrees(-90) : .degrees(0))
                    }
                }
                .foregroundStyle(.background)
                .bold()
                
                Spacer()
            }
            VStack {
                if viewModel.isShowedTextFields {
                    
                    VStack {
                        CustomTextFieldForAddressInputView(
                            textFieldString: $viewModel.addressText,
                            textFieldPlaceholder: viewModel.addressText.isEmpty ? "" : viewModel.selectedAddress.description,
                            isEditing: $viewModel.isShowedSearchView
                        )
                        
                        if !viewModel.isShowedSearchView {
                            HStack {
                                CustomTextFieldForAddressInputView(textFieldString: $viewModel.entrancewayText, textFieldPlaceholder: "Entranceway")
                                CustomTextFieldForAddressInputView(textFieldString: $viewModel.intercomNumberText, textFieldPlaceholder: "Intercom")
                            }
                            HStack {
                                CustomTextFieldForAddressInputView(textFieldString: $viewModel.floorText, textFieldPlaceholder: "Floor")
                                CustomTextFieldForAddressInputView(textFieldString: $viewModel.apartmentText, textFieldPlaceholder: "Apartment")
                            }
                            CustomTextFieldForAddressInputView(textFieldString: $viewModel.orderCommentText, textFieldPlaceholder: "Order comment")
                            Button {
                                //action
                            } label: {
                                Text("Save")
                                    .bold()
                                    .foregroundStyle(Color(uiColor: .label))
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.background)
                            )
                            
                        } else {
                            SearchAddressListView(viewModel: viewModel)
                        }
                    }
                    .transition(.scale(0, anchor: .top).combined(with: .opacity))
                }
            }
        }
        .padding(16)
        .background(Color.primary.clipShape(RoundedRectangle(cornerRadius: 20)))
        .padding(32)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isShowedSearchView)
    }
}


struct SearchAddressListView: View {
    @ObservedObject var viewModel: AddNewAddressViewModel
    
    var body: some View {
        List {
            if !viewModel.searchAddressSuggestions.isEmpty {
                ForEach(viewModel.searchAddressSuggestions) { addressModel in
                    VStack(alignment: .leading) {
                        Text(addressModel.name)
                        Text(addressModel.description)
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                    .foregroundStyle(Color(uiColor: UIColor.systemBackground))
                    .onTapGesture {
                        viewModel.selectAddress(addressModel: addressModel)
                    }
                }
                .listRowBackground(Color.primary)
                //показывать что сейчас загружаются адреса
            } else {
                ForEach(0..<6) { _ in
                    VStack(alignment: .leading) {
                        Text("Lorem ipsum dolor sit")
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam lectus")
                            .font(.caption)
                    }
                    .lineLimit(1)
                    .redacted(reason: .placeholder)
                    .foregroundStyle(
                        LinearGradient(colors: [Color(uiColor: .systemGray), Color(uiColor: .systemGray6)],
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )
                }
                .listRowBackground(Color.primary)
            }
        }
        .listStyle(.plain)
        .transition(.scale.combined(with: .opacity))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(maxHeight: 300)
    }
}
