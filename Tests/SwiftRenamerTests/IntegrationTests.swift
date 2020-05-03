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
                if occ.symbol.usr == "s:16IntegrationTests9ViewModelC4nameSSSgvp" {
                    return "nickname"
            }
            if occ.symbol.name == "foo(input:)", occ.symbol.kind == .instanceMethod {
                return "bar"
            }
            return nil
        })

        let results = try rewrite(replacements: replacements)

        XCTAssertEqual(results["ViewModel.swift"], """
        class ViewModel {
            typealias Input = Int
            func bar(input: Input) {}
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
                viewModel.bar(input: 1)
            }
        }

        """)
    }
}
