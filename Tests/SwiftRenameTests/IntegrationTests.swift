import XCTest
@testable import SwiftRename

class IntegrationTests: XCTestCase {

    var indexStorePath: URL!
    
    override func setUpWithError() throws {
//        let projectPath = URL(fileURLWithPath: #file)
//            .deletingLastPathComponent()
//            .deletingLastPathComponent()
//            .deletingLastPathComponent()
//            .appendingPathComponent("IntegrationTests")
//
//        let derivedData = FileManager.default.temporaryDirectory
//            .appendingPathComponent("DerivedData-\(UUID())")
//
//        let process = Process()
//        process.currentDirectoryPath = projectPath.path
//        process.launchPath = "/usr/bin/xcodebuild"
//        process.arguments = ["build", "-scheme", "IntegrationTests", "-derivedDataPath", derivedData.path]
//        process.launch()
//        process.waitUntilExit()
//
//        indexStorePath = derivedData
//            .appendingPathComponent("Index")
//            .appendingPathComponent("DataStore")
        indexStorePath = URL(fileURLWithPath: "/var/folders/br/7sr_p7cj7v549x_gtkb33df00000gp/T/DerivedData-5B78FBA0-1300-425B-AFC5-88F32C3B2B82/Index/DataStore")
    }
    
    func testRename() throws {
        let system = try SwiftRename(storePath: indexStorePath)
        try system.rename("s:16IntegrationTests9ViewModelC4nameSSSgvp")
    }
}
