@testable import SwiftLogger
import XCTest

struct LogMessageStub: Equatable {
  let level: LogLevel
  let className: String
  let message: String
  let path: String
  let function: String
  let line: Int
}

final class LoggerStub: LoggerType {
  var messageStub: LogMessageStub?

  func log(
    level: LogLevel,
    className: String,
    message: @autoclosure () -> String,
    _ path: String,
    _ function: String,
    line: Int
  ) {
    messageStub = LogMessageStub(
      level: level,
      className: className,
      message: "\(message())",
      path: path,
      function: function,
      line: line
    )
  }
}

final class SwiftLoggerTests: XCTestCase, Loggable {
  let setup: () -> (sut: Logger, stub: LoggerStub) = {
    let sut = Logger()
    let stub = LoggerStub()
    sut.setupLogger(logger: stub)
    Logger.setSharedInstance(logger: sut)
    return (sut, stub)
  }

  func testLoggerDefaultBehaviour() {
    let (_, stub) = setup()

    let expected = LogMessageStub(
      level: .debug,
      className: String(describing: self),
      message: "Test",
      path: "path",
      function: "function",
      line: 66
    )

    let actual: LogMessageStub? = {
      log(
        level: expected.level,
        expected.message,
        expected.path,
        expected.function,
        line: expected.line
      )
      return stub.messageStub
    }()

    XCTAssertEqual(expected, actual)
  }

  func testLoggerIgnoreBehaviour() {
    let (sut, stub) = setup()

    sut.ignoreClass(className: String(describing: self))

    let expected: LogMessageStub? = nil
    let actual: LogMessageStub? = {
      log(
        level: .debug,
        "message",
        "/path",
        "func",
        line: 0
      )
      return stub.messageStub
    }()

    XCTAssertEqual(expected, actual)
  }
}
