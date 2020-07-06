@testable import SwiftLogger
import XCTest

final class SwiftLoggerTests: XCTestCase, Loggable {
  func testExample() {
    Logger.sharedInstance.setupLogger(logger: osLogger())
    log(level: .error, "ABCDE")
  }
}
