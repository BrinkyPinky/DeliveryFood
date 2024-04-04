//
//  CategoryView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import SwiftUI

struct CategoryView: View {
    @State private var image = UIImage()
    let category: CategoryModel
    
    //Номер выбранной категории на данный момент
    let isPicked: Bool
    
    //Показать ошибку
    let showError: (String) -> ()
    
    //Пустышка или нет
    var isViewLayout: Bool
    
    //Подгружает картинку
    init(category: CategoryModel, isPicked: Bool, showError: @escaping (String) -> Void) {
        self.category = category
        self.isPicked = isPicked
        self.showError = showError
        self.isViewLayout = false
    }
    
    //Пустышка которая ждет пока загрузится информация о возможных категориях
    init() {
        self.category = CategoryModel(id: 0, url: "", name: "riwjqjirrw")
        self.isPicked = false
        self.showError = { _ in }
        self.isViewLayout = true
    }
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(isViewLayout ? 8 : 0)
                .frame(width: 125, height: 125)
                .background {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 125, height: 125)
                        .opacity(0.7)
                        .blur(radius: 20)
                        .offset(x: 10.0, y: 10.0)
                }
                
            HStack {
                Text(category.name)
                    .font(.system(size: 18))
                    .fontWeight(isPicked ? .bold : .regular)
                if isPicked {
                    Image(systemName: "arrow.right")
                        .bold()
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
            if !isViewLayout {
                FirebaseStorageManager.shared.downloadImage(withURL: category.url) { result in
                    switch result {
                    case .success(let data):
                        if let uiimage = UIImage(data: data) {
                            image = uiimage
                        } else {
                            self.showError("Failed to convert the image.\nPlease report the bug")
                        }
                    case .failure(let error):
                        if let error = error as? FirebaseDatabaseError {
                            self.showError(error.localizedDescription)
                        } else {
                            self.showError(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CategoryView(category: CategoryModel(id: 1, url: "gs://deliveryfood-db5c8.appspot.com/categories/pizza.png", name: "Pizza"), isPicked: true, showError: { _ in })
}
