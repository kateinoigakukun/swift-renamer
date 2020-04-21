import Foundation

struct SwiftRename {

    let indexStore: IndexStore

    init(storePath: URL) throws {
        self.indexStore = try IndexStore.open(store: storePath, api: .make())
    }

    func getSymbolRef(_ usr: String) throws -> IndexStoreSymbol? {
        var symbolRef: IndexStoreSymbol?
        try self.indexStore.forEachUnits { unit -> Bool in
            try self.indexStore.forEachRecordDependencies(for: unit) { record -> Bool in
                try self.indexStore.forEachSymbols(for: record) { symbol -> Bool in
                    guard symbol.usr == usr else { return true }
                    symbolRef = symbol
                    return false
                }
                return symbolRef == nil
            }

            return symbolRef == nil
        }
        return symbolRef
    }

    func occrrences(for usr: String) throws -> [IndexStoreOccurrence] {
        var occs: [IndexStoreOccurrence] = []
        try self.indexStore.forEachUnits { unit -> Bool in
            try self.indexStore.forEachOccurrences(for: unit) { (occurrence) -> Bool in
                guard occurrence.symbol.usr == usr else { return true }
                occs.append(occurrence)
                return true
            }
            return true
        }
        return occs
    }

    func replacements(for usr: String, newSymbol: String) throws -> [String: [Replacement]] {
        let occs = try occrrences(for: usr)

        var results: [/* path */ String: [Replacement]] = [:]

        for occ in occs {
            let replacement = Replacement(
                location: (occ.location.line, occ.location.column),
                length: occ.symbol.name.count, newText: newSymbol
            )
            if results[occ.location.path] == nil {
                results[occ.location.path] = [replacement]
            } else {
                results[occ.location.path]?.append(replacement)
            }
        }
        return results
    }
}
