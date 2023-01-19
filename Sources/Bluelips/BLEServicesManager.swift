//
//  BLEServicesManager.swift
//  
//
//  Created by Dario on 10/11/2021.
//

import CoreBluetooth
import SwiftyBeaver

public enum BLEState: Equatable {

    case nonDetermined
    case poweredOff
    case poweredOn
    case unauthorized
    case scanning
    case connecting
    case connected(BLEPeripheral)

    /// The device does not support Bluetooth
    case unsupported
}


/// Provides an interface with the Bluelips Library
/// For more information see [BluelipsLibrary]
///
/// [BluelipsLibrary]:
/// https://github.com/Dario-Gasquez/Bluelips
public final class BLEServicesManager: NSObject {

    /// Initialises this manager with the provided delegate an optional dispatch queue
    ///
    /// Although the default `resultQueue` used to call the delegate's methods is the main queue (UI thread), a client application may choose to use a different one if required.
    public init(withDelegate bleDelegate: BLEServicesDelegate, resultQueue: DispatchQueue = .main, centralManagerFactory: CentralManagerFactory = CentralManagerFactory()) {
        self.delegate = bleDelegate
        self.resultQueue = resultQueue
        self.centralManagerFactory = centralManagerFactory
    }


    /// Starts the BLE Services library
    ///
    /// IMPORTANT: This method has to be executed before anything else
    public func start() {
        centralManager = centralManagerFactory.makeACentralManager(withDelegate: self, queue: centralManagerQueue, shouldPreserveState: true)
    }

    /// Initiates Bluetooth peripheral's scan
    ///
    /// As devices are detected the delegate's `didDiscoverPeripheral(blePeripheral:)` method will be executed.
    public func startScanning() {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")

        guard let cbManager = centralManager else {
            assertionFailure("centralManager not set, make sure to call `start()` before using this library")
            return
        }

        currentState = .scanning
        cbManager.scanForPeripherals(withServices: nil, options: nil)
    }


    public func stopScanning() {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")
        guard let cbManager = centralManager else {
            assertionFailure("centralManager not set, make sure to call `start()` before using this library")
            return
        }

        cbManager.stopScan()
        setCurrentStateFrom(cbManager.state)
    }


    public func connectTo(blePeripheral: BLEPeripheral) {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")
        SwiftyBeaver.info("blePeripheral: \(blePeripheral)")

        guard let cbManager = centralManager else {
            assertionFailure("centralManager not set, make sure to call `start()` before using this library")
            return
        }

        cbManager.connect(blePeripheral.cbPeripheral, options: nil)
    }


    public func disconnectFromPeripheral() {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")
        guard let cbManager = centralManager else {
            assertionFailure("centralManager not set, make sure to call `start()` before using this library")
            return
        }

        guard let peripheral = connectedPeripheral?.cbPeripheral else {
            assertionFailure("disconnectFromPeripheral() called with connectedPeripheral == nil")
            return
        }

        cbManager.cancelPeripheralConnection(peripheral)
    }


    public private (set) var currentState: BLEState = .nonDetermined {
        didSet {
            resultQueue.async {
                self.delegate.stateDidChangeTo(newState: self.currentState)
            }
        }
    }

    public var connectedPeripheralName: String? {
        return connectedPeripheral?.name
    }


    // MARK: - Private Section
    private let delegate: BLEServicesDelegate // swiftlint:disable:this weak_delegate
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: BLEPeripheral?
    private let centralManagerQueue = DispatchQueue(label: "com.ble-services-library.centraManagerQueue")
    private let centralManagerFactory: CentralManagerFactory

    /// The DispatchQueue where the delegate methods will be executed
    private let resultQueue: DispatchQueue


    private func setCurrentStateFrom(_ centraManagerState: CBManagerState) {
        switch centraManagerState {
        case .poweredOff:
            currentState = .poweredOff
        case .poweredOn:
            currentState = .poweredOn
        case .resetting:
            // Wait for next state update
        break
        case .unauthorized:
            currentState = .unauthorized
        case .unsupported:
            currentState = .unsupported
        case .unknown:
            // Wait for next state update
        break
        @unknown default:
            assertionFailure("BLEServicesManager: unsupported CBManagerState")
        }
    }
}



extension BLEServicesManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")
        SwiftyBeaver.info("state: \(centralManager?.state.rawValue ?? -1)")
        setCurrentStateFrom(central.state)
    }


    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")
        SwiftyBeaver.info("peripheral: \(peripheral)")
        SwiftyBeaver.info("advertisementData: \(advertisementData)")

        let txPower = advertisementData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber
        let blePeripheral = BLEPeripheral(cbPeripheral: peripheral, rssi: RSSI, txPower: txPower, resultQueue: resultQueue)

        resultQueue.async {
            self.delegate.didDiscoverPeripheral(blePeripheral)
        }
    }


    /// Tells the delegate the central manager failed to create a connection with a peripheral.
    ///
    ///  Because connection attempts don’t time out, a failed connection usually indicates a transient issue, in which case you may attempt connecting to the peripheral again.
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")
        SwiftyBeaver.info("peripheral: \(peripheral). Error: \(error?.localizedDescription ?? "unknown error")")
        resultQueue.async {
            self.delegate.didFailConnectionTo(blePeripheral: BLEPeripheral(cbPeripheral: peripheral, resultQueue: self.resultQueue), error: .connectionFailed(description: error?.localizedDescription))
        }
    }


    /// Called as soon as a connection to `peripheral` is established
    ///
    /// This  method is called immediately after a basic connection is established, and before any pairing or bonding is attempted
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")
        SwiftyBeaver.info("peripheral: \(peripheral)")

        let blePeripheral = BLEPeripheral(cbPeripheral: peripheral, resultQueue: resultQueue)
        connectedPeripheral = blePeripheral
        resultQueue.async {
            self.delegate.didConnectTo(blePeripheral: blePeripheral)
        }
    }


    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")
        SwiftyBeaver.info("peripheral: \(peripheral). error: \(error?.localizedDescription ?? "unknown error")")

        if connectedPeripheral?.cbPeripheral == peripheral {
            connectedPeripheral = nil
        }

        var disconnectionError: BLEServicesError?
        if let anError = error {
            disconnectionError = .disconnectionError(description: anError.localizedDescription)
        }

        let blePeripheral = BLEPeripheral(cbPeripheral: peripheral, resultQueue: resultQueue)
        resultQueue.async {
            self.delegate.didDisconnectFrom(blePeripheral: blePeripheral, error: disconnectionError)
        }
    }


    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")

        let restoredPeripherals = dict[CBCentralManagerRestoredStatePeripheralsKey]
        SwiftyBeaver.info("restored peripherals: \(String(describing: restoredPeripherals))")
    }
}
