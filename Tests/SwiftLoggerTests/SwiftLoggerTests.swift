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
  var asyncMessageStub: LogMessageStub?

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

  @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
  func logAsync(
    level: LogLevel,
    className: String,
    message: @autoclosure () -> String,
    _ path: String,
    _ function: String,
    line: Int
  ) async {
    asyncMessageStub = LogMessageStub(
      level: level,
      className: className,
      message: "\(message())",
      path: path,
      function: function,
      line: line
    )
  }
}

// Test class for instance logging
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
      className: String(describing: type(of: self)),
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
      // Give time for async operations
      Thread.sleep(forTimeInterval: 0.1)
      return stub.messageStub
    }()

    XCTAssertEqual(expected, actual)
  }

  func testLoggerIgnoreBehaviour() {
    let (sut, stub) = setup()

    sut.ignoreClass(className: String(describing: type(of: self)))
    Thread.sleep(forTimeInterval: 0.1) // Give time for async operations

    let expected: LogMessageStub? = nil
    let actual: LogMessageStub? = {
      log(
        level: .debug,
        "message",
        "/path",
        "func",
        line: 0
      )
      Thread.sleep(forTimeInterval: 0.1)
      return stub.messageStub
    }()

    XCTAssertEqual(expected, actual)
  }

  func testAllowClassAfterIgnore() {
    let (sut, stub) = setup()
    let className = String(describing: type(of: self))

    sut.ignoreClass(className: className)
    Thread.sleep(forTimeInterval: 0.1)

    sut.allowClass(className: className)
    Thread.sleep(forTimeInterval: 0.1)

    log(level: .info, "Test message", "/path", "func", line: 1)
    Thread.sleep(forTimeInterval: 0.1)

    XCTAssertNotNil(stub.messageStub)
    XCTAssertEqual(stub.messageStub?.message, "Test message")
  }

  func testLogLevelFiltering() {
    let (sut, stub) = setup()

    // Set minimum level to error
    sut.setMinimumLogLevel(.error)
    Thread.sleep(forTimeInterval: 0.1)

    // Debug message should not be logged
    logDebug("Debug message")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssertNil(stub.messageStub)

    // Error message should be logged
    logError("Error message")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssertEqual(stub.messageStub?.message, "Error message")

    // Fault message should be logged (fault < error)
    stub.messageStub = nil
    logFault("Fault message")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssertEqual(stub.messageStub?.message, "Fault message")
  }

  func testAllLogLevels() {
    let (_, stub) = setup()

    logDefault("Default message")
    Thread.sleep(forTimeInterval: 0.05)
    XCTAssertEqual(stub.messageStub?.level, .default)
    XCTAssertEqual(stub.messageStub?.message, "Default message")

    logInfo("Info message")
    Thread.sleep(forTimeInterval: 0.05)
    XCTAssertEqual(stub.messageStub?.level, .info)
    XCTAssertEqual(stub.messageStub?.message, "Info message")

    logDebug("Debug message")
    Thread.sleep(forTimeInterval: 0.05)
    XCTAssertEqual(stub.messageStub?.level, .debug)
    XCTAssertEqual(stub.messageStub?.message, "Debug message")

    logError("Error message")
    Thread.sleep(forTimeInterval: 0.05)
    XCTAssertEqual(stub.messageStub?.level, .error)
    XCTAssertEqual(stub.messageStub?.message, "Error message")

    logFault("Fault message")
    Thread.sleep(forTimeInterval: 0.05)
    XCTAssertEqual(stub.messageStub?.level, .fault)
    XCTAssertEqual(stub.messageStub?.message, "Fault message")
  }

  @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
  func testAsyncLogging() async {
    let (_, stub) = setup()

    await logDefaultAsync("Async default")
    XCTAssertEqual(stub.asyncMessageStub?.level, .default)
    XCTAssertEqual(stub.asyncMessageStub?.message, "Async default")

    await logInfoAsync("Async info")
    XCTAssertEqual(stub.asyncMessageStub?.level, .info)

    await logDebugAsync("Async debug")
    XCTAssertEqual(stub.asyncMessageStub?.level, .debug)

    await logErrorAsync("Async error")
    XCTAssertEqual(stub.asyncMessageStub?.level, .error)

    await logFaultAsync("Async fault")
    XCTAssertEqual(stub.asyncMessageStub?.level, .fault)
  }
}

// Test class for static logging
final class StaticLoggerTests: XCTestCase, StaticLoggable {
  let setup: () -> (sut: Logger, stub: LoggerStub) = {
    let sut = Logger()
    let stub = LoggerStub()
    sut.setupLogger(logger: stub)
    Logger.setSharedInstance(logger: sut)
    return (sut, stub)
  }

  func testStaticLogging() {
    let (_, stub) = setup()

    Self.logDefault("Static default")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssertEqual(stub.messageStub?.level, .default)
    XCTAssertEqual(stub.messageStub?.message, "Static default")
    XCTAssertEqual(stub.messageStub?.className, String(describing: Self.self))

    Self.logInfo("Static info")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssertEqual(stub.messageStub?.level, .info)

    Self.logDebug("Static debug")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssertEqual(stub.messageStub?.level, .debug)

    Self.logError("Static error")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssertEqual(stub.messageStub?.level, .error)

    Self.logFault("Static fault")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssertEqual(stub.messageStub?.level, .fault)
  }

  func testStaticIgnoreAndAllow() {
    let (sut, stub) = setup()
    let className = String(describing: Self.self)

    Self.disableLogging()
    Thread.sleep(forTimeInterval: 0.1)

    Self.logInfo("Should not log")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssertNil(stub.messageStub)

    Self.allowLogging()
    Thread.sleep(forTimeInterval: 0.1)

    Self.logInfo("Should log")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssertEqual(stub.messageStub?.message, "Should log")
  }

  @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
  func testStaticAsyncLogging() async {
    let (_, stub) = setup()

    await Self.logDefaultAsync("Static async default")
    XCTAssertEqual(stub.asyncMessageStub?.level, .default)
    XCTAssertEqual(stub.asyncMessageStub?.message, "Static async default")
    XCTAssertEqual(stub.asyncMessageStub?.className, String(describing: Self.self))

    await Self.logInfoAsync("Static async info")
    XCTAssertEqual(stub.asyncMessageStub?.level, .info)

    await Self.logDebugAsync("Static async debug")
    XCTAssertEqual(stub.asyncMessageStub?.level, .debug)

    await Self.logErrorAsync("Static async error")
    XCTAssertEqual(stub.asyncMessageStub?.level, .error)

    await Self.logFaultAsync("Static async fault")
    XCTAssertEqual(stub.asyncMessageStub?.level, .fault)
  }
}

// Test thread safety
final class ThreadSafetyTests: XCTestCase {
  func testConcurrentLogging() {
    let sut = Logger()
    let stub = LoggerStub()
    sut.setupLogger(logger: stub)
    Logger.setSharedInstance(logger: sut)

    let expectation = self.expectation(description: "Concurrent logging")
    expectation.expectedFulfillmentCount = 100

    DispatchQueue.concurrentPerform(iterations: 100) { index in
      let testClass = TestLoggableClass()
      testClass.performLog(index: index)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5.0)
  }

  func testConcurrentClassToggling() {
    let sut = Logger()
    let stub = LoggerStub()
    sut.setupLogger(logger: stub)
    Logger.setSharedInstance(logger: sut)

    let expectation = self.expectation(description: "Concurrent toggling")
    expectation.expectedFulfillmentCount = 100

    DispatchQueue.concurrentPerform(iterations: 100) { index in
      if index % 2 == 0 {
        sut.ignoreClass(className: "TestClass\(index % 10)")
      } else {
        sut.allowClass(className: "TestClass\(index % 10)")
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5.0)
  }
}

// Helper class for testing
private class TestLoggableClass: Loggable {
  func performLog(index: Int) {
    logInfo("Log message \(index)")
  }
}

// Test log level comparison
final class LogLevelTests: XCTestCase {
  func testLogLevelComparison() {
    XCTAssertTrue(LogLevel.fault < LogLevel.error)
    XCTAssertTrue(LogLevel.error < LogLevel.debug)
    XCTAssertTrue(LogLevel.debug < LogLevel.info)
    XCTAssertTrue(LogLevel.info < LogLevel.default)

    XCTAssertFalse(LogLevel.default < LogLevel.info)
    XCTAssertFalse(LogLevel.info < LogLevel.debug)
  }

  func testLogLevelEquality() {
    XCTAssertEqual(LogLevel.fault, LogLevel.fault)
    XCTAssertEqual(LogLevel.error, LogLevel.error)
    XCTAssertNotEqual(LogLevel.fault, LogLevel.error)
  }
}