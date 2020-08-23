import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    [
      testCase(SwiftLoggerTests.allTests),
    ]
  }
#endif
