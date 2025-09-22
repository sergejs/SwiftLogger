//
//  SwiftLogger.swift
//
//
//  Created by Sergejs Smirnovs on 06/07/2020.
//
import Foundation

public enum LogLevel: Int, Comparable {
  case fault = 0
  case error = 1
  case debug = 2
  case info = 3
  case `default` = 4

  public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

// MARK: - Instance Logging

public protocol Loggable {
  func log(
    level: LogLevel,
    _ message: @autoclosure () -> String,
    _ path: String,
    _ function: String,
    line: Int
  )
  func allowLogging()
  func disableLogging()
}

public extension Loggable {
  func allowLogging() {
    let className = String(describing: type(of: self))
    Logger.sharedInstance.allowClass(className: className)
  }

  func disableLogging() {
    let className = String(describing: type(of: self))
    Logger.sharedInstance.ignoreClass(className: className)
  }

  func log(
    level: LogLevel,
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) {
    let className = String(describing: type(of: self))
    Logger.sharedInstance.log(
      level: level,
      className: className,
      message: message(),
      path, function,
      line: line
    )
  }

  func logDefault(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) {
    log(
      level: .default,
      message(),
      path,
      function,
      line: line
    )
  }

  func logInfo(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) {
    log(
      level: .info,
      message(),
      path,
      function,
      line: line
    )
  }

  func logDebug(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) {
    log(
      level: .debug,
      message(),
      path,
      function,
      line: line
    )
  }

  func logError(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) {
    log(
      level: .error,
      message(),
      path,
      function,
      line: line
    )
  }

  func logFault(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) {
    log(
      level: .fault,
      message(),
      path,
      function,
      line: line
    )
  }
}

// MARK: - Static Logging

public protocol StaticLoggable {
  static func log(
    level: LogLevel,
    _ message: @autoclosure () -> String,
    _ path: String,
    _ function: String,
    line: Int
  )
  static func allowLogging()
  static func disableLogging()
}

public extension StaticLoggable {
  static func allowLogging() {
    let className = String(describing: Self.self)
    Logger.sharedInstance.allowClass(className: className)
  }

  static func disableLogging() {
    let className = String(describing: Self.self)
    Logger.sharedInstance.ignoreClass(className: className)
  }

  static func log(
    level: LogLevel,
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) {
    let className = String(describing: Self.self)
    Logger.sharedInstance.log(
      level: level,
      className: className,
      message: message(),
      path, function,
      line: line
    )
  }

  static func logDefault(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) {
    log(
      level: .default,
      message(),
      path,
      function,
      line: line
    )
  }

  static func logInfo(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) {
    log(
      level: .info,
      message(),
      path,
      function,
      line: line
    )
  }

  static func logDebug(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) {
    log(
      level: .debug,
      message(),
      path,
      function,
      line: line
    )
  }

  static func logError(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) {
    log(
      level: .error,
      message(),
      path,
      function,
      line: line
    )
  }

  static func logFault(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) {
    log(
      level: .fault,
      message(),
      path,
      function,
      line: line
    )
  }
}

// MARK: - Logger Type Protocol

public protocol LoggerType {
  func log(
    level: LogLevel,
    className: String,
    message: @autoclosure () -> String,
    _ path: String,
    _ function: String,
    line: Int
  )

  @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
  func logAsync(
    level: LogLevel,
    className: String,
    message: @autoclosure () -> String,
    _ path: String,
    _ function: String,
    line: Int
  ) async
}

public extension LoggerType {
  @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
  func logAsync(
    level: LogLevel,
    className: String,
    message: @autoclosure () -> String,
    _ path: String,
    _ function: String,
    line: Int
  ) async {
    // Default implementation just calls sync version
    log(
      level: level,
      className: className,
      message: message(),
      path,
      function,
      line: line
    )
  }
}

// MARK: - Logger Singleton

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public actor LoggerActor {
  private var activeLogger: LoggerType?
  private var disabledSymbols = Set<String>()
  private var minimumLevel: LogLevel = .default
  private var weakReferences: [String: WeakReference] = [:]

  private struct WeakReference {
    weak var object: AnyObject?
  }

  func setupLogger(logger: LoggerType) {
    guard activeLogger == nil else { return }
    activeLogger = logger
  }

  func setMinimumLogLevel(_ level: LogLevel) {
    minimumLevel = level
  }

  func getMinimumLogLevel() -> LogLevel {
    minimumLevel
  }

  func ignoreClass(className: String) {
    disabledSymbols.insert(className)
  }

  func allowClass(className: String) {
    disabledSymbols.remove(className)
  }

  func trackObject(_ object: AnyObject, className: String) {
    weakReferences[className] = WeakReference(object: object)
    cleanupDeallocatedReferences()
  }

  private func cleanupDeallocatedReferences() {
    weakReferences = weakReferences.compactMapValues { ref in
      ref.object != nil ? ref : nil
    }
  }

  func shouldLog(level: LogLevel, className: String) -> Bool {
    guard level <= minimumLevel else { return false }
    return !disabledSymbols.contains(className)
  }

  func performLog(
    level: LogLevel,
    className: String,
    message: String,
    _ path: String,
    _ function: String,
    line: Int
  ) {
    guard let activeLogger = activeLogger else { return }
    activeLogger.log(
      level: level,
      className: className,
      message: message,
      path,
      function,
      line: line
    )
  }

  func performAsyncLog(
    level: LogLevel,
    className: String,
    message: String,
    _ path: String,
    _ function: String,
    line: Int
  ) async {
    guard let activeLogger = activeLogger else { return }
    await activeLogger.logAsync(
      level: level,
      className: className,
      message: message,
      path,
      function,
      line: line
    )
  }
}

public final class Logger {
  // Thread-safe singleton implementation
  private static let _sharedInstance = Logger()
  private static var _customInstance: Logger?
  private static let instanceQueue = DispatchQueue(label: "com.swiftlogger.instance", attributes: .concurrent)

  public static var sharedInstance: Logger {
    instanceQueue.sync(flags: .barrier) {
      _customInstance ?? _sharedInstance
    }
  }

  // Legacy properties for backward compatibility
  internal var activeLogger: LoggerType?
  internal var disabledSymbols = Set<String>()
  internal var minimumLevel: LogLevel = .default

  // Thread safety for legacy API
  private let queue = DispatchQueue(label: "com.swiftlogger.queue", attributes: .concurrent)

  // Modern actor-based logger for iOS 13+
  @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
  private lazy var actorLogger = LoggerActor()

  /// Overrides shared instance, useful for testing
  static func setSharedInstance(logger: Logger) {
    instanceQueue.async(flags: .barrier) {
      _customInstance = logger
    }
  }

  public func setupLogger(logger: LoggerType) {
    queue.async(flags: .barrier) { [weak self] in
      guard self?.activeLogger == nil else { return }
      self?.activeLogger = logger
    }

    if #available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *) {
      Task {
        await actorLogger.setupLogger(logger: logger)
      }
    }
  }

  public func setMinimumLogLevel(_ level: LogLevel) {
    queue.async(flags: .barrier) { [weak self] in
      self?.minimumLevel = level
    }

    if #available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *) {
      Task {
        await actorLogger.setMinimumLogLevel(level)
      }
    }
  }

  public func ignoreClass(className: String) {
    queue.async(flags: .barrier) { [weak self] in
      self?.disabledSymbols.insert(className)
    }

    if #available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *) {
      Task {
        await actorLogger.ignoreClass(className: className)
      }
    }
  }

  public func allowClass(className: String) {
    queue.async(flags: .barrier) { [weak self] in
      self?.disabledSymbols.remove(className)
    }

    if #available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *) {
      Task {
        await actorLogger.allowClass(className: className)
      }
    }
  }

  public func log(
    level: LogLevel,
    className: String,
    message: @autoclosure () -> String,
    _ path: String,
    _ function: String,
    line: Int
  ) {
    // Performance optimization: check if we should log before evaluating message
    let shouldLog = queue.sync { [weak self] in
      guard let self = self else { return false }
      return level <= self.minimumLevel && !self.disabledSymbols.contains(className)
    }

    guard shouldLog else { return }

    // Evaluate the message once to avoid escaping closure issue
    let messageValue = message()

    // Use modern actor-based logging if available
    if #available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *) {
      Task {
        let canLog = await actorLogger.shouldLog(level: level, className: className)
        guard canLog else { return }
        await actorLogger.performLog(
          level: level,
          className: className,
          message: messageValue,
          path,
          function,
          line: line
        )
      }
    } else {
      // Fallback to legacy thread-safe logging
      queue.sync { [weak self] in
        guard let activeLogger = self?.activeLogger else { return }
        activeLogger.log(
          level: level,
          className: className,
          message: messageValue,
          path,
          function,
          line: line
        )
      }
    }
  }

  @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
  public func logAsync(
    level: LogLevel,
    className: String,
    message: @autoclosure () -> String,
    _ path: String,
    _ function: String,
    line: Int
  ) async {
    guard await actorLogger.shouldLog(level: level, className: className) else { return }
    let messageValue = message()
    await actorLogger.performAsyncLog(
      level: level,
      className: className,
      message: messageValue,
      path,
      function,
      line: line
    )
  }

  public func trackObject(_ object: AnyObject, for className: String) {
    if #available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *) {
      Task {
        await actorLogger.trackObject(object, className: className)
      }
    }
  }
}

// MARK: - Async Extensions

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public extension Loggable {
  func logAsync(
    level: LogLevel,
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) async {
    let className = String(describing: type(of: self))
    await Logger.sharedInstance.logAsync(
      level: level,
      className: className,
      message: message(),
      path,
      function,
      line: line
    )
  }

  func logDefaultAsync(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) async {
    await logAsync(level: .default, message(), path, function, line: line)
  }

  func logInfoAsync(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) async {
    await logAsync(level: .info, message(), path, function, line: line)
  }

  func logDebugAsync(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) async {
    await logAsync(level: .debug, message(), path, function, line: line)
  }

  func logErrorAsync(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) async {
    await logAsync(level: .error, message(), path, function, line: line)
  }

  func logFaultAsync(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) async {
    await logAsync(level: .fault, message(), path, function, line: line)
  }
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public extension StaticLoggable {
  static func logAsync(
    level: LogLevel,
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) async {
    let className = String(describing: Self.self)
    await Logger.sharedInstance.logAsync(
      level: level,
      className: className,
      message: message(),
      path,
      function,
      line: line
    )
  }

  static func logDefaultAsync(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) async {
    await logAsync(level: .default, message(), path, function, line: line)
  }

  static func logInfoAsync(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) async {
    await logAsync(level: .info, message(), path, function, line: line)
  }

  static func logDebugAsync(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) async {
    await logAsync(level: .debug, message(), path, function, line: line)
  }

  static func logErrorAsync(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) async {
    await logAsync(level: .error, message(), path, function, line: line)
  }

  static func logFaultAsync(
    _ message: @autoclosure () -> String,
    _ path: String = #file,
    _ function: String = #function,
    line: Int = #line
  ) async {
    await logAsync(level: .fault, message(), path, function, line: line)
  }
}