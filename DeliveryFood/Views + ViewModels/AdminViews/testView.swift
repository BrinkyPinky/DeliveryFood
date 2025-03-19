import SwiftUI

struct Item: Identifiable {
    let id = UUID()
    var name: String
    var order: Int
    var section: Int // 0 - первая секция, 1 - вторая
}

class ItemViewModel: ObservableObject {
    @Published var items: [Item] = [
        Item(name: "Item 1", order: 0, section: 0),
        Item(name: "Item 2", order: 1, section: 0),
        Item(name: "Item 3", order: 2, section: 1),
        Item(name: "Item 4", order: 3, section: 1)
    ]
    
    func move(from source: IndexSet, to destination: Int, in section: Int) {
        var filteredItems = items.filter { $0.section == section }
        filteredItems.move(fromOffsets: source, toOffset: destination)
        
        for index in filteredItems.indices {
            filteredItems[index].order = index
        }
        
        items.removeAll { $0.section == section }
        items.append(contentsOf: filteredItems)
        items.sort { $0.order < $1.order }
    }
    
    func moveBetweenSections(item: Item, toSection: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].section = toSection
            updateOrder()
        }
    }
    
    private func updateOrder() {
        for section in [0, 1] {
            let filteredItems = items.filter { $0.section == section }
            for (index, item) in filteredItems.enumerated() {
                if let originalIndex = items.firstIndex(where: { $0.id == item.id }) {
                    items[originalIndex].order = index
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ItemViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Section 1")) {
                    ForEach(viewModel.items.filter { $0.section == 0 }) { item in
                        Text("\(item.name)")
                            .onDrag {
                                NSItemProvider(object: "\(item.id)" as NSString)
                            }
                            .onDrop(of: [.text], isTargeted: nil) { providers in
                                handleDrop(providers: providers, toSection: 0)
                            }
                    }
                    .onMove { indices, newOffset in
                        viewModel.move(from: indices, to: newOffset, in: 0)
                    }
                }
                
                Section(header: Text("Section 2")) {
                    ForEach(viewModel.items.filter { $0.section == 1 }) { item in
                        Text("\(item.name)")
                            .onDrag {
                                NSItemProvider(object: "\(item.id)" as NSString)
                            }
                            .onDrop(of: [.text], isTargeted: nil) { providers in
                                handleDrop(providers: providers, toSection: 1)
                            }
                    }
                    .onMove { indices, newOffset in
                        viewModel.move(from: indices, to: newOffset, in: 1)
                    }
                }
            }
            .navigationTitle("Move Items")
            .toolbar { EditButton() }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider], toSection: Int) -> Bool {
        providers.first?.loadObject(ofClass: NSString.self) { (idString, _) in
            if let idString = idString as? String,
               let id = UUID(uuidString: idString),
               let item = viewModel.items.first(where: { $0.id == id }) {
                DispatchQueue.main.async {
                    viewModel.moveBetweenSections(item: item, toSection: toSection)
                }
            }
        }
        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
