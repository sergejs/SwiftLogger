//
//  File.swift
//
//
//  Created by Sergejs Smirnovs on 06/07/2020.
//

public enum LogLevel {
  case `default`
  case info
  case debug
  case error
  case fault
}

public protocol Loggable {
  func log(level: LogLevel, _ message: String, _ path: String, _ function: String, line: Int)
}

public extension Loggable {
  func log(
    level: LogLevel,
    _ message: String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) {
    let className = String(describing: self)
    Logger.sharedInstance.log(
      level: level,
      className: className,
      message: message,
      path, function,
      line: line
    )
  }
}

protocol LoggerType {
  func log(level: LogLevel, className: String, message: String, _ path: String, _ function: String, line: Int)
}

final class Logger: Loggable {
  internal var activeLogger: LoggerType?
  internal var disabledSymbols = Set<String>()
  private(set) static var sharedInstance = Logger()

  /// Overrides shared instance, useful for testing
  static func setSharedInstance(logger: Logger) {
    sharedInstance = logger
  }

  func setupLogger(logger: LoggerType) {
    assert(activeLogger == nil, "Changing logger is disallowed to maintain consistency")
    activeLogger = logger
  }

  func ignoreClass(type: AnyClass) {
    let className = String(describing: type)

    disabledSymbols.insert(className)
  }

  func log(
    level: LogLevel,
    className: String,
    message: String,
    _ path: String,
    _ function: String,
    line: Int
  ) {
    guard
      logAllowed(className: className),
      let activeLogger = activeLogger
    else { return }
    activeLogger.log(level: level, className: className, message: message, path, function, line: line)
  }

  private func logAllowed(className: String) -> Bool {
    !disabledSymbols.contains(className)
  }
}
