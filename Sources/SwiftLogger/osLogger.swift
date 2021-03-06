//
//  osLogger.swift
//
//
//  Created by Sergejs Smirnovs on 06/07/2020.
//

import Foundation
import os.log

private extension LogLevel {
  func OSLogType() -> OSLogType {
    switch self {
      case .default:
        return .default
      case .info:
        return .info
      case .debug:
        return .debug
      case .error:
        return .error
      case .fault:
        return .fault
    }
  }

  func emoji() -> String {
    switch self {
      case .default:
        return "🟢"
      case .info:
        return "ℹ️"
      case .debug:
        return "🐞"
      case .error:
        return "🔴"
      case .fault:
        return "🛑"
    }
  }
}

extension OSLog {
  private static var subsystem = Bundle.main.bundleIdentifier ?? "OS_LOGGER"
  static let appLogger = OSLog(subsystem: subsystem, category: "AppLogger")
}

public class osLogger: LoggerType {
  public init() {}

  public func log(
    level: LogLevel,
    className: String,
    message: @autoclosure () -> String,
    _ path: String,
    _ function: String,
    line: Int
  ) {
    os_log(
      "%@[%@ -> %@:%d] %@",
      log: OSLog.appLogger,
      type: level.OSLogType(),
      level.emoji(),
      className,
      function,
      line,
      message()
    )
  }
}
