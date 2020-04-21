import Foundation

public struct SwiftRename {

    let indexStore: IndexStore
    public init(indexStore: IndexStore) {
        self.indexStore = indexStore
    }

    public init(storePath: URL) throws {
        self.indexStore = try IndexStore.open(store: storePath, api: .init())
    }

    public func occurrences(
        where condition: (IndexStoreOccurrence) -> Bool
    ) throws -> [IndexStoreOccurrence] {
        var occs: [IndexStoreOccurrence] = []
        try self.indexStore.forEachUnits { unit -> Bool in
            try self.indexStore.forEachOccurrences(for: unit) { (occurrence) -> Bool in
                guard !occurrence.location.isSystem else { return true }
                guard condition(occurrence) else { return true }
                occs.append(occurrence)
                return true
            }
            return true
        }
        return occs
    }

    public func replacements(
                             where condition: (IndexStoreOccurrence) -> String?) throws -> [String: [Replacement]] {
        var entries: [(occ: IndexStoreOccurrence, newSymbol: String)] = []
        try self.indexStore.forEachUnits { unit -> Bool in
            try self.indexStore.forEachOccurrences(for: unit) { (occurrence) -> Bool in
                guard !occurrence.location.isSystem else { return true }
                guard let newSymbol = condition(occurrence) else { return true }
                entries.append((occurrence, newSymbol))
                return true
            }
            return true
        }

        var results: [/* path */ String: [Replacement]] = [:]

        for entry in entries {
            let replacement = Replacement(
                location: (entry.occ.location.line, entry.occ.location.column),
                length: entry.occ.symbol.name.count, newText: entry.newSymbol
            )
            if results[entry.occ.location.path] == nil {
                results[entry.occ.location.path] = [replacement]
            } else {
                results[entry.occ.location.path]?.append(replacement)
            }
        }
        return results
    }
}
