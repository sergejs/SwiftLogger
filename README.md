[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsergejs%2FSwiftLogger%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/sergejs/SwiftLogger)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsergejs%2FSwiftLogger%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/sergejs/SwiftLogger)

# SwiftLogger

A lightweight, protocol-oriented logging framework for Swift with support for multiple log levels, thread-safe operations, and both instance and static logging methods.

## Features

- ✅ **Protocol-oriented design** - Add logging to any class via protocol conformance
- ✅ **Multiple log levels** - Fault, Error, Debug, Info, Default with emoji indicators
- ✅ **Thread-safe operations** - Concurrent queue protection and actor-based logging for iOS 13+
- ✅ **Performance optimized** - Log level filtering to avoid unnecessary message construction
- ✅ **Instance and static logging** - Support for both object instances and static methods
- ✅ **Async/await support** - Modern concurrency with structured async logging
- ✅ **Selective logging** - Enable/disable logging per class
- ✅ **Memory management** - Weak reference tracking to prevent retain cycles
- ✅ **Backward compatible** - Works with iOS 10+ while providing modern features for iOS 13+

## Installation

### Swift Package Manager

Add SwiftLogger to your project using Xcode or by adding it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sergejs/SwiftLogger.git", from: "1.0.0")
]
```

### CocoaPods

```ruby
pod 'SwiftLogger'
```

## Quick Start

### 1. Setup Logger

```swift
import SwiftLogger

// Setup with default osLogger (uses Apple's os.log)
let logger = osLogger()
Logger.sharedInstance.setupLogger(logger: logger)
```

### 2. Add Logging to Your Classes

#### Instance Logging

```swift
class MyViewController: UIViewController, Loggable {
    override func viewDidLoad() {
        super.viewDidLoad()
        logInfo("View controller loaded")
        logDebug("Setting up UI components")
    }

    private func handleError(_ error: Error) {
        logError("Failed to load data: \(error.localizedDescription)")
    }
}
```

#### Static Logging

```swift
class NetworkManager: StaticLoggable {
    static func fetchData() async throws -> Data {
        logInfo("Starting data fetch")

        do {
            let data = try await performNetworkRequest()
            logDebug("Successfully fetched \(data.count) bytes")
            return data
        } catch {
            logError("Network request failed: \(error)")
            throw error
        }
    }
}
```

## Log Levels

SwiftLogger provides 5 log levels in order of severity:

| Level | Emoji | Usage |
|-------|-------|-------|
| `fault` | 🛑 | Critical system failures |
| `error` | 🔴 | Error conditions |
| `debug` | 🐞 | Debug information |
| `info` | ℹ️ | Informational messages |
| `default` | 🟢 | Standard logging |

### Available Logging Methods

#### Instance Logging (Loggable Protocol)
```swift
class MyClass: Loggable {
    func example() {
        logFault("Critical system failure")
        logError("Something went wrong")
        logDebug("Debug information")
        logInfo("Informational message")
        logDefault("Standard log message")
    }
}
```

#### Static Logging (StaticLoggable Protocol)
```swift
class MyClass: StaticLoggable {
    static func example() {
        Self.logFault("Critical system failure")
        Self.logError("Something went wrong")
        Self.logDebug("Debug information")
        Self.logInfo("Informational message")
        Self.logDefault("Standard log message")
    }
}
```

#### Async Logging (iOS 13+)
```swift
class MyClass: Loggable {
    func asyncExample() async {
        await logInfoAsync("Async informational message")
        await logErrorAsync("Async error message")
    }
}

class MyStaticClass: StaticLoggable {
    static func asyncExample() async {
        await Self.logInfoAsync("Static async message")
    }
}
```

## Advanced Features

### Log Level Filtering

Set a minimum log level to filter out less important messages:

```swift
// Only log error and fault messages
Logger.sharedInstance.setMinimumLogLevel(.error)

// This will be logged (error level)
logError("This error will appear")

// This will be ignored (debug < error)
logDebug("This debug message will be filtered out")
```

### Selective Class Logging

Enable or disable logging for specific classes:

```swift
class MyClass: Loggable {
    func disableMyLogging() {
        disableLogging() // Disable logging for this class
        logInfo("This won't be logged")
    }

    func enableMyLogging() {
        allowLogging() // Re-enable logging for this class
        logInfo("This will be logged")
    }
}

// Or control externally
Logger.sharedInstance.ignoreClass(className: "MyClass")
Logger.sharedInstance.allowClass(className: "MyClass")
```

### Custom Logger Implementation

Create your own logger by implementing the `LoggerType` protocol:

```swift
class FileLogger: LoggerType {
    func log(
        level: LogLevel,
        className: String,
        message: @autoclosure () -> String,
        _ path: String,
        _ function: String,
        line: Int
    ) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logMessage = "[\(timestamp)] [\(level)] \(className).\(function):\(line) - \(message())"

        // Write to file
        writeToFile(logMessage)
    }

    // iOS 13+ async support
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    func logAsync(
        level: LogLevel,
        className: String,
        message: @autoclosure () -> String,
        _ path: String,
        _ function: String,
        line: Int
    ) async {
        // Async file writing implementation
        await writeToFileAsync(/* ... */)
    }
}

// Use your custom logger
let fileLogger = FileLogger()
Logger.sharedInstance.setupLogger(logger: fileLogger)
```

### Memory Management

Track objects to prevent memory leaks:

```swift
class MyViewController: UIViewController, Loggable {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Track this object for memory management
        Logger.sharedInstance.trackObject(self, for: String(describing: type(of: self)))

        logInfo("View controller loaded and tracked")
    }
}
```

## Thread Safety

SwiftLogger is designed to be thread-safe:

- **iOS 13+**: Uses actor-based concurrency for modern thread safety
- **iOS 10-12**: Uses concurrent dispatch queues with barrier operations
- All logging operations can be safely called from any thread

```swift
// Safe to call from any queue
DispatchQueue.global().async {
    logInfo("Background thread logging")
}

DispatchQueue.main.async {
    logInfo("Main thread logging")
}
```

## Testing

SwiftLogger includes comprehensive testing support:

```swift
// Create a test logger stub
class TestLoggerStub: LoggerType {
    var lastMessage: String?

    func log(level: LogLevel, className: String, message: @autoclosure () -> String, _ path: String, _ function: String, line: Int) {
        lastMessage = message()
    }
}

// Use in tests
let testLogger = TestLoggerStub()
Logger.sharedInstance.setupLogger(logger: testLogger)

// Test logging
myObject.logInfo("Test message")
XCTAssertEqual(testLogger.lastMessage, "Test message")
```

## Requirements

- iOS 13.0+ / macOS 10.15+ / watchOS 6.0+ / tvOS 13.0+ (for full feature set)
- iOS 10.0+ / macOS 10.12+ / watchOS 3.0+ / tvOS 10.0+ (legacy support)
- Swift 5.9+
- Xcode 15.0+

## Migration Guide

### From 1.x to 2.x

- **Swift tools version**: Updated from 5.1 to 5.9
- **Platform requirements**: Minimum versions increased for full feature support
- **New features**: Static logging, async support, thread safety improvements
- **Breaking changes**: None - fully backward compatible

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## TODO

- [ ] Add tags support for categorizing log messages
- [ ] Implement more advanced logging controls (rate limiting, buffering)
- [ ] Add network logger implementation
- [ ] Support for structured logging (JSON format)
- [ ] Log rotation for file-based loggers