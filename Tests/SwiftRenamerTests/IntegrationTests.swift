import XCTest
@testable import SwiftRenamer

class IntegrationTests: XCTestCase {

    static var indexStorePath: URL!
    static let projectPath = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("IntegrationTests")

    override class func setUp() {
        let derivedData = FileManager.default.temporaryDirectory
            .appendingPathComponent("DerivedData-\(UUID())")

        let process = Process()
        process.currentDirectoryPath = projectPath.path
        process.launchPath = "/usr/bin/xcodebuild"
        process.arguments = ["build", "-scheme", "IntegrationTests", "-derivedDataPath", derivedData.path]
        process.launch()
        process.waitUntilExit()

        indexStorePath = derivedData
            .appendingPathComponent("Index")
            .appendingPathComponent("DataStore")
    }

    func testGetOccurrences() throws {
        let system = try SwiftRenamer(storePath: Self.indexStorePath)
        let occs = try system.occurrences(where: { $0.symbol.usr == "s:16IntegrationTests9ViewModelC4nameSSSgvp" })
        XCTAssertEqual(occs.count, 2)
        let locations = occs.map(\.location)

        func projectSourcePath(_ name: String) -> String {
            Self.projectPath.appendingPathComponent("Sources").appendingPathComponent(name).path
        }
        XCTAssertEqual(
            locations.sorted(by: { $0.path < $1.path }),
            [
                .init(path: projectSourcePath("ViewModel.swift"), isSystem: false, line: 2, column: 9),
                .init(path: projectSourcePath("ViewController.swift"), isSystem: false, line: 9, column: 19)
            ]
                .sorted(by: { $0.path < $1.path })
        )
    }
    
    func rewrite(replacements: [String: [Replacement]]) throws -> [String: String] {
        return try replacements.reduce(into: [String: String]()) { (result, element) throws -> Void in
            let (path, replacements) = element
            let rewriter = try SourceRewriter(content: String(contentsOfFile: path))
            replacements.forEach(rewriter.replace)
            result[String(path.split(separator: "/").last!)] = rewriter.apply()
        }
    }

    func testRewrite() throws {
        let system = try SwiftRenamer(storePath: Self.indexStorePath)

        let replacements = try system.replacements(where: { (occ) -> String? in
            occ.symbol.usr == "s:16IntegrationTests9ViewModelC4nameSSSgvp" ? "nickname" : nil
        })

        let results = try rewrite(replacements: replacements)

        XCTAssertEqual(results["ViewModel.swift"], """
        class ViewModel {
            var nickname: String?
        }

        """)

        XCTAssertEqual(results["ViewController.swift"], """
        import UIKit

        class ViewController: UIViewController {

            let viewModel = ViewModel()
            override func viewDidLoad() {
                super.viewDidLoad()

                viewModel.nickname = "Initial Name"
            }
        }

        """)
    }
}
