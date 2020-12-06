[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsergejs%2FStateMachine%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/sergejs/StateMachine)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsergejs%2FStateMachine%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/sergejs/StateMachine)
# SwiftLogger

Easy logger, just import, add protocol, use it!


```swift
import SwiftLogger
...
class ClassnName: Loggable {
  func funcName() {
    logDefault("Default level log Message")
    logInfo("Info level log Message")
    logDebug("Debug level log Message")
    logError("Error level log Message")
    logFault("Fault level log Message")
  }
}
```

## TODO:

[ ] Add tags

[ ] Implement more logging control 
