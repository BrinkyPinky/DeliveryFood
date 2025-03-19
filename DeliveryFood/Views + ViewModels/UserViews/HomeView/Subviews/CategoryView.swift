//
//  CategoryView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import SwiftUI

struct CategoryView: View {
    @State private var image = UIImage()
    private let category: CategoryModel
    
    //Номер выбранной категории на данный момент
    private var isPicked: Bool
    
    //Показать ошибку
    private let showError: (String) -> ()
    
    //Статус загрузки изображения
    @State private var isImageLoaded = false
    //Пустышка или нет
    private var isViewLayout: Bool
    
    //Подгружает картинку
    init(category: CategoryModel, isPicked: Bool, showError: @escaping (String) -> Void) {
        self.category = category
        self.isPicked = isPicked
        self.showError = showError
        self.isViewLayout = false
    }
    
    //Пустышка которая ждет пока загрузится информация о возможных категориях
    init() {
        self.category = CategoryModel(id: "someID", name: "riwjqjirrw", order: 0)
        self.isPicked = false
        self.showError = { _ in }
        self.isViewLayout = true
    }
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(isImageLoaded ? 0 : 8)
                .frame(width: 125, height: 125)
                .background {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 125, height: 125)
                        .opacity(0.7)
                        .blur(radius: 20)
                        .offset(x: 10.0, y: 10.0)
                }
                .redacted(reason: isImageLoaded ? [] : .placeholder)
                
            HStack {
                Text(category.name)
                    .font(.system(size: 18))
                    .fontWeight(isPicked ? .bold : .regular)
                if isPicked {
                    Image(systemName: "arrow.right")
                        .fontWeight(.bold)
                        .opacity(isPicked ? 1 : 0)
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 125, height: 175)
                .foregroundStyle(isPicked ? Color.greenForSelecting : Color.init(uiColor: UIColor.systemBackground))
                .shadow(color: .primary.opacity(0.2), radius: 5, x: 2, y: 2)
        }
        .scaleEffect(CGSize(width: isPicked ? 1.05 : 1, height: isPicked ? 1.05 : 1))
        .animation(.easeInOut(duration: 0.15), value: isPicked)
        .onAppear {
            guard !isViewLayout else { return }
            onAppearAction()
        }
    }
    
    private func onAppearAction() {
        FirebaseStorageManager.shared.downloadImage(withPath: "categories/\(category.id)") { result in
            switch result {
            case .success(let data):
                if let uiimage = UIImage(data: data) {
                    image = uiimage
                    
                    isImageLoaded = true
                } else {
                    showError("Failed to convert the image.\nPlease report the bug")
                }
            case .failure(let error):
                if let error = error as? FirebaseDatabaseError {
                    showError(error.localizedDescription)
                } else {
                    showError(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    CategoryView(category: CategoryModel(id: "someID", name: "Pizza", order: 0), isPicked: true, showError: { _ in })
}
