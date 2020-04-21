import Foundation

public struct SwiftRename {

    let indexStore: IndexStore

    public init(storePath: URL, indexStoreAPI: IndexStoreAPI) throws {
        self.indexStore = try IndexStore.open(store: storePath, api: indexStoreAPI)
    }

    public init(storePath: URL) throws {
        self.indexStore = try IndexStore.open(store: storePath, api: .make())
    }

    public func occrrences(for usr: String) throws -> [IndexStoreOccurrence] {
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

    public func replacements(for usr: String, newSymbol: String,
                      when condition: (IndexStoreOccurrence) -> Bool = { _ in true }) throws -> [String: [Replacement]] {
        let occs = try occrrences(for: usr)

        var results: [/* path */ String: [Replacement]] = [:]

        for occ in occs {
            guard condition(occ) else { continue }
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
