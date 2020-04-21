import Foundation

public struct SwiftRenamer {

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

    public func replacements(where condition: (IndexStoreOccurrence) -> String?) throws -> [String: [Replacement]] {

        var usrToOccurrence: [String: [IndexStoreOccurrence]] = [:]
        var entries: [(usr: String, newText: String)] = []

        try self.indexStore.forEachUnits { unit -> Bool in
            try self.indexStore.forEachOccurrences(for: unit) { (occurrence) -> Bool in
                guard !occurrence.location.isSystem else { return true }

                if usrToOccurrence[occurrence.symbol.usr] == nil {
                    usrToOccurrence[occurrence.symbol.usr] = [occurrence]
                } else {
                    usrToOccurrence[occurrence.symbol.usr]?.append(occurrence)
                }

                guard let newSymbol = condition(occurrence) else { return true }
                entries.append((occurrence.symbol.usr, newSymbol))

                return true
            }
            return true
        }

        var results: [/* path */ String: [Replacement]] = [:]

        for entry in entries {
            let occs = usrToOccurrence[entry.usr]!
            for occ in occs {
                let replacement = Replacement(
                    location: .init(line: occ.location.line, column: occ.location.column),
                    length: occ.symbol.name.count, newText: entry.newText
                )
                if results[occ.location.path] == nil {
                    results[occ.location.path] = [replacement]
                } else {
                    results[occ.location.path]?.append(replacement)
                }
            }
        }
        return results
    }
}
