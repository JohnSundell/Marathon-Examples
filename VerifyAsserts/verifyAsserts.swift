import Foundation
import Files

// MARK: - Utilities

private enum SourceType: String {
    case swift = "swift"
    case objectiveC = "m"
}

extension SourceType {
    var testPrefix: String {
        switch self {
        case .swift:
            return "func test"
        case .objectiveC:
            return "- (void)test"
        }
    }
}

private extension File {
    var sourceType: SourceType? {
        guard let `extension` = `extension` else {
            return nil
        }

        return SourceType(rawValue: `extension`)
    }
}

private extension String {
    func testName(forSourceType sourceType: SourceType) -> String {
        switch sourceType {
        case .swift:
            let rawName = substring(from: index(startIndex, offsetBy: 5))
            return rawName.components(separatedBy: "(")[0]
        case .objectiveC:
            let rawName = substring(from: index(startIndex, offsetBy: 8))
            return rawName.replacingOccurrences(of: "{", with: "")
        }
    }
}

// MARK: - Script

var testsMissingAsserts = [String]()

for file in FileSystem().currentFolder.makeFileSequence(recursive: true) {
    guard let sourceType = file.sourceType else {
        continue
    }

    guard file.name.contains("Tests") else {
        continue
    }

    var testName: String?
    var assertFound = false

    for line in try file.readAsString().components(separatedBy: .newlines) {
        let line = line.trimmingCharacters(in: .whitespaces)

        guard !line.hasPrefix(sourceType.testPrefix) else {
            if let testName = testName {
                if !assertFound {
                    testsMissingAsserts.append(testName)
                }
            }

            testName = line.testName(forSourceType: sourceType)
            assertFound = false

            continue
        }

        if !assertFound {
            assertFound = !line.hasPrefix("//") && line.contains("XCTAssert")
        }
    }

    if let testName = testName {
        if !assertFound {
            testsMissingAsserts.append(testName)
        }
    }
}

guard !testsMissingAsserts.isEmpty else {
    print("✅  All your tests have asserts!")
    exit(0)
}

print("⚠️  The following tests do not contain at least one assert:")

for test in testsMissingAsserts {
    print("- \(test)")
}

exit(1)
