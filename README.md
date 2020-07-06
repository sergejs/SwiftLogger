# SwiftLogger

Easy logger, just import, add protocol, use it!


```
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
