# Bluelips
A Bluetooth library that works as an interface/wrapper on top of Apple's [Core Bluetooth](https://developer.apple.com/documentation/corebluetooth). If curious about the design behind this library see: [Bluelips Library Design](https://github.com/Dario-Gasquez/bluelips/wiki).<br>

## Requirements
- iOS 13.0+
- Swift 5.0+
- Xcode 12.0+

## Install Instructions

### Swift Package Manager

---

**NOTE:**
These instructions are based on Xcode 13.4.1, the steps may deffer for different Xcode versions.

---

1 . Open your project and add a package dependency as you prefer (for example: right click on the project -> *Add Packages* or from the project's *Package Dependencies* tab).

2 . Paste the following in the package URL field:  
`https://github.com/Dario-Gasquez/Bluelips.git`

3 . Follow the instructions until the **Bluelips** package is added to the project  

Once the package was successfully added you should be able to access it by importing the module:
```swift
import Bluelips
```

## Usage

### Simplest use-case: Start and Scan for peripherals
Before anything else you will need to start the library and scan for devices as the following code excerpt shows:
```Swift
import Bluelips

let bleServicesManager = BLEServicesManager(withDelegate: self)

// (1) Start the BLE services library: 
// This causes the `stateDidChangeTo(newState: BLEState)` method of the `BLEServicesDelegate` to be called
bleServicesManager.start()

...

// (2) Start scanning for Bluetooth devices:
// You want to do this after `stateDidChangeTo(newState: BLEState)` is called, and you have verified the state is valid for scanning (for example `.poweredOn`). 
bleServicesManager.startScanning()
```
Detected devices will be notified to the provided `BLEServicesDelegate`'s method: `didDiscoverPeripheral(_ blePeripheral: BLEPeripheral)`. 
Check [DemoApp](./DemoApp)  for additional functionality.


## Demo App
The [DemoApp](./DemoApp) directory contains a sample application. It provides an example to explore the BLE Library features like:
- Scan for peripherals
- Connect to a peripheral
- See the list of GATT Services and Characteristics provided by the connected peripheral
- Read, Write and Subscribe/Unsubscribe to a Characteristic
