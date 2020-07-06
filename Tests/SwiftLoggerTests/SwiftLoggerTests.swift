@testable import SwiftLogger
import XCTest

final class SwiftLoggerTests: XCTestCase, Loggable {
  func testExample() {
    Logger.sharedInstance.setupLogger(logger: osLogger())
    Self.log(level: .error, "ABCDE")
  }
}
