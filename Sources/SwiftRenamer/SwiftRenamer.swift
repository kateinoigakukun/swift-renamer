import Foundation
import SwiftIndexStore

public struct SwiftRenamer {

    let indexStore: IndexStore
    public init(indexStore: IndexStore) {
        self.indexStore = indexStore
    }

    public init(storePath: URL) throws {
        self.indexStore = try IndexStore.open(store: storePath, lib: .open())
    }

    public func replacements(where condition: (IndexStoreOccurrence) -> String?) throws -> [String: [Replacement]] {

        var usrToOccurrence: [String: [IndexStoreOccurrence]] = [:]
        var entries: [(usr: String, newText: String)] = []

        try self.indexStore.forEachUnits { unit -> Bool in
            try self.indexStore.forEachRecordDependencies(for: unit) { dependency in
                guard case let .record(record) = dependency else { return true }
                try self.indexStore.forEachOccurrences(for: record) { (occurrence) -> Bool in
                    guard let usr = occurrence.symbol.usr,
                        !occurrence.location.isSystem else { return true }

                    if usrToOccurrence[usr] == nil {
                        usrToOccurrence[usr] = [occurrence]
                    } else {
                        usrToOccurrence[usr]?.append(occurrence)
                    }

                    guard let newSymbol = condition(occurrence) else { return true }
                    entries.append((usr, newSymbol))

                    return true
                }
                return true
            }
            return true
        }

        var results: [/* path */ String: [Replacement]] = [:]

        for entry in entries {
            let occs = usrToOccurrence[entry.usr]!
            for occ in occs {
                guard let symbolName = occ.symbol.name,
                    let occPath = occ.location.path else { continue }
                let symbolLength: Int

                if occ.symbol.kind == .instanceMethod {
                    guard let indexOfLastOfName = symbolName.firstIndex(of: "(") else { continue }
                    symbolLength = symbolName.distance(from: symbolName.startIndex, to: indexOfLastOfName)
                } else {
                    symbolLength = symbolName.count
                }

                let replacement = Replacement(
                    location: .init(line: occ.location.line, column: occ.location.column),
                    length: symbolLength, newText: entry.newText
                )

                if results[occPath] == nil {
                    results[occPath] = [replacement]
                } else {
                    results[occPath]?.append(replacement)
                }
            }
        }
        return results
    }
}
