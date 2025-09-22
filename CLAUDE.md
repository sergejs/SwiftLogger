# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview
SwiftLogger is a lightweight logging framework for Swift that provides a protocol-oriented approach to logging with support for multiple log levels and the ability to selectively enable/disable logging per class.

## Development Commands

### Build
```bash
swift build
```

### Run Tests
```bash
swift test

# Run tests with verbose output
swift test -v
```

### Lint Code
```bash
swiftlint
```

### Clean Build
```bash
swift package clean
swift build --configuration release
```

## Architecture

### Core Components

1. **Loggable Protocol** - Main protocol that classes adopt to gain logging capabilities
   - Provides convenience methods: `logDefault()`, `logInfo()`, `logDebug()`, `logError()`, `logFault()`
   - Automatically captures file, function, and line information
   - Classes can enable/disable their own logging via `allowLogging()` and `disableLogging()`

2. **Logger Singleton** - Central logging manager (`Logger.sharedInstance`)
   - Manages active logger implementation
   - Maintains set of disabled class names for selective logging
   - Must be configured with a LoggerType implementation via `setupLogger()`

3. **LoggerType Protocol** - Interface for custom logger implementations
   - Currently provides `osLogger` implementation using Apple's `os.log` framework
   - Each log level maps to appropriate OSLogType with emoji indicators

### Log Levels
- `default` (🟢) - Standard logging
- `info` (ℹ️) - Informational messages
- `debug` (🐞) - Debug information
- `error` (🔴) - Error conditions
- `fault` (🛑) - Critical failures

### Key Design Patterns
- **Protocol-Oriented Design**: Logging is added via protocol conformance rather than inheritance
- **Singleton Pattern**: Single Logger instance manages all logging configuration
- **Strategy Pattern**: Different logger implementations can be plugged in via LoggerType protocol
- **Lazy Evaluation**: Message closures use @autoclosure for performance

## Testing Approach
The test suite uses stub implementations to verify logging behavior without actual console output. Tests verify:
- Message content and metadata capture
- Class-specific enable/disable functionality
- Logger configuration

## SwiftLint Configuration
Custom rules include preventing direct UIColor/Color initializers in favor of design system colors. Many default rules are disabled for flexibility.

## Platform Support
- macOS 10.12+
- iOS 10+
- watchOS 3+
- tvOS 10+

## Package Structure
- Library type: Dynamic
- Swift tools version: 5.1+
- No external dependencies