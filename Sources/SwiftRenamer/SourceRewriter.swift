public struct Replacement: Equatable {

    struct Location: Hashable {
        let line: Int64
        let column: Int64
    }

    let location: Location
    let length: Int
    let newText: String
}

public class SourceRewriter {
    let content: String

    var replacements: [Replacement] = []

    public init(content: String) {
        self.content = content
    }

    public func replace(_ replacement: Replacement) {
        replacements.append(replacement)
    }

    public func apply() -> String {
        let sorted = replacements.unique().sorted(by: {
                $0.location.line == $1.location.line ?
                    $0.location.column > $1.location.column :
                    $0.location.line > $1.location.line
        })
        var lines = content.components(separatedBy: "\n")
        var lineOffset = 0
        var lastLine: Int64 = 0

        for replacement in sorted {
            if lastLine != replacement.location.line {
                lineOffset = 0
            }
            let lineIndex = Int(replacement.location.line) - 1
            var line = lines[lineIndex]

            let startOffset = Int(replacement.location.column - 1) + lineOffset
            let startIndex = line.index(line.startIndex, offsetBy: startOffset)
            let endIndex = line.index(startIndex, offsetBy: Int(replacement.length))
            line.replaceSubrange(startIndex..<endIndex, with: replacement.newText)
            lineOffset = replacement.newText.count - Int(replacement.length)

            lastLine = replacement.location.line

            lines[lineIndex] = line
        }

        return lines.joined(separator: "\n")
    }
}

extension Array where Element: Equatable {
    fileprivate func unique() -> [Element] {
        reduce([Element]()) { $0.contains($1) ? $0 : $0 + [$1] }
    }
}
