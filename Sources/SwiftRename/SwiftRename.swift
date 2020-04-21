import Foundation

struct SwiftRename {
    
    let indexStore: IndexStore
    
    init(storePath: URL) throws {
        self.indexStore = try IndexStore.open(store: storePath, api: .make())
    }
    
    func rename(_ usr: String) throws {
        try self.indexStore.forEachUnits { unit -> Bool in
            try self.indexStore.forEachSymbols(for: unit) { symbol -> Bool in
                print(symbol.usr)
                return true
            }
            return true
        }
    }
}
