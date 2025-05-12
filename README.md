
# Le Monde Capping - iOS SDK

## Requirements

- iOS 14.0+

## Installation

To add LMDCapping in a SwiftPM project, add it to your Package.swift:

```
dependencies: [
  .package(url: "https://github.com/lemonde/capping-spm.git", from: "1.3.0")
]
```

And then add the following product to any target that needs access to the library:
```
targets: [
    .target(name: "MyTarget", dependencies: ["LMDCapping"])
]
```

## Usage

### Getting started
```
import LMDCapping
```
Create a `CappingService` object with the two required parameters:
- `baseURL`: the base URL that will be used for the capping operations requests.
- `apiKey`: the api key that will be used for the capping operations requests.

You can pass an optional `configuration` parameter to tweak some settings of the `CappingService`.
```
let cappingService = CappingService(baseURL: <baseURL>, apiKey: <apiKey>)
```

### Properties

#### Active (optional, default value: `true`)
On creation, the capping service is activated by default. Use this property to deactivate it.

Note: Stop any running session before deactivating the capping service.
```
cappingService.isActive = false
```

#### User id (required)
Before starting a first session, you must set an identifier for the current user. This id can be updated on runtime.

Note: Ensure no capping session is currently running when updating the user identifier.
```
cappingService.setUserId(<user_id>)
```

#### Tolerance (optional, default value: `0`)
The tolerance is the number of simultaneous sessions allowed in a day before being capped. This value can be updated at runtime.
```
cappingService.setTolerance(<tolerance>)
```

#### Auto unblock (optional, default value: `true`)
Indicates whether the `CappingLock` should be automatically unlocked when the current session switches from blocked to unblocked. Disable it if you don't want a capped user to
 be automatically uncapped when its current session becomes the active one.
 
 Note: this is only applicable when the current running session is blocked.
```
cappingService.autoUnblock = false
```

### Configuration
The `CappingService` constructor takes an optional `CappingConfiguration` parameter, with the following cutomizable properties:

#### mode
The `mode: CappingMode` property represents two capping behaviors in case the maximum number of simultaneous readings is reached. reading mode allows a new reading device to take over, capping a random currently reading device. Conversely, device mode caps the new reading device immediately, and if it signals "continue reading", a random currently reading device is capped instead.

#### blockingMinDelay (optional, default value: `10.0`)
The minimum amount of time the session will stay blocked in the app. When the server returns a `blocked` state, the `CappingLock` will stay in a locked state at least during this time, even if the server returns a `unblocked` state in the meantime. 

### Session Management
When using or viewing a capped object in your app, you should start a capping session.
```
cappingService.startSession()
```
When the capped object is not used anymore, you should stop the capping session.
```
cappingService.stopSession()
```
When a capping session is currently running and blocked, you can take the control back and block the other active sessions, by calling:
```
cappingService.continueReading()
```

### Lock Status
The lock current status can be accessed through the `lock` property of the `CappingService`, which returns an instance of `CappingLock`.
You can register an object to be notified of the lock status changes, by calling:
```
cappingService.addObserver(<observer>, selector: #selector(lockStatusDidChange(_:)))
```
The `selector` can take an argument of type `Notification`. This notification embeds the `CappingLock` instance that triggered it, which is accessible with the key `LockStatusDidChangeUserInfoKey` inside the `userInfo`.
```
@objc func lockStatusDidChange(_ notification: Notification) {
  let lock = notification.userInfo?[LockStatusDidChangeUserInfoKey] as? CappingLock
}
```
When not needed anymore, you can remove a registered observer by calling:
```
cappingService.removeObserver(<observer>)
```

### Error Handling
Any error encountered during the capping operations will be forwarded to the `errorDelegate` of the `CappingService`. These are only informative and no action is expected as the internal mechanics of the `CappingService` always handle these errors.
To be notified of errors, assign the delegate, and implement the method required by the protocol.
```
cappingService.errorDelegate = <delegate>
...
func  cappingServiceOperationFailedWithError(_ error: NSError) { ... }
```

### Event tracking
If you want to track an event you can use the provided `trackEvent` function.

Example with the conversion event:
```
cappingService.trackEvent(.conversion)
```
N.B.: the previous `trackConversionEvent` has been deprecated and will be removed in a future update.
