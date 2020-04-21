import XCTest
@testable import SwiftRenamer

class SourceRewiterTests: XCTestCase {

    func testSingleReplacement() {
        let content = """
        foo bar fizz
        """

        let rewriter = SourceRewriter(content: content)
        let replacement = Replacement(
            location: .init(line: 1, column: 5), length: 3, newText: "buzz"
        )
        rewriter.replace(replacement)
        let result = rewriter.apply()

        XCTAssertEqual(result, """
        foo buzz fizz
        """)
    }

    func testMultipleReplacement() {
        let content = """
        foo bar fizz
        Hello, new world
        """

        let replacement1 = Replacement(
            location: .init(line: 1, column: 5), length: 3, newText: "buzz"
        )
        let replacement2 = Replacement(
            location: .init(line: 2, column: 8), length: 3, newText: "old"
        )
        let replacements = [replacement1, replacement2]

        let rewriter = SourceRewriter(content: content)
        replacements.forEach(rewriter.replace)
        let result = rewriter.apply()

        XCTAssertEqual(result, """
        foo buzz fizz
        Hello, old world
        """)
    }

    func testMultipleReplacementInSameLine() {
        let content = """
        Hello, new world
        """

        let replacement1 = Replacement(
            location: .init(line: 1, column: 8), length: 3, newText: "old"
        )
        let replacement2 = Replacement(
            location: .init(line: 1, column: 1), length: 5, newText: "Good bye"
        )
        let replacements = [replacement1, replacement2]

        let rewriter = SourceRewriter(content: content)
        replacements.forEach(rewriter.replace)
        let result = rewriter.apply()

        XCTAssertEqual(result, """
        Good bye, old world
        """)
    }
}
