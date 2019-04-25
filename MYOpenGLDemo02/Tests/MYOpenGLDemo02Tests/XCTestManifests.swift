import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MYOpenGLDemo02Tests.allTests),
    ]
}
#endif