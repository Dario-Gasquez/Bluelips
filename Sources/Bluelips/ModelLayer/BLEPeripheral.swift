//
//  BLEPeripheral.swift
//  
//
//  Created by Dario on 10/11/2021.
//

import CoreBluetooth
import Foundation
import SwiftyBeaver

/// A wrapper class for a `CBPeripheral`
public class BLEPeripheral: NSObject {
    public let cbPeripheral: CBPeripheral
    public private(set) var rssi: NSNumber?
    public private(set) var txPower: NSNumber?

    public weak var delegate: BLEPeripheralDelegate?


    init(cbPeripheral: CBPeripheral, rssi: NSNumber? = nil, txPower: NSNumber? = nil, resultQueue: DispatchQueue) {
        self.cbPeripheral = cbPeripheral
        self.rssi = rssi
        self.txPower = txPower
        self.resultQueue = resultQueue

        super.init()
        self.cbPeripheral.delegate = self
    }

    public var name: String {
        return cbPeripheral.name ?? "Undefined"
    }

    public var identifier: UUID {
        cbPeripheral.identifier
    }


    public func detectServices() {
        cbPeripheral.discoverServices(nil)
    }


    public func readValueFor(_ gattCharacteristic: GATTCharacteristic) {
        cbPeripheral.readValue(for: gattCharacteristic.cbCharacteristic)
    }


    public func subscribeToNotificationsFor(_ gattCharacteristic: GATTCharacteristic) {
        cbPeripheral.setNotifyValue(true, for: gattCharacteristic.cbCharacteristic)
    }


    public func unsubscribeFromNotificationsFor(_ gattCharacteristic: GATTCharacteristic) {
        cbPeripheral.setNotifyValue(false, for: gattCharacteristic.cbCharacteristic)
    }


    /// Write `value` to `gattCharacteristics` if it contains the write property
    ///
    /// This method corresponds with the Write Characteristic Value as defined in Bluetooth's Core Specification (4.9.3). A response is received and notified to the delegate's `didUpdateCharacteristicValueFor(_)` method. Also known as a write request, this is preferred for sporadic writes.
    public func write(_ value: Data, to gattCharacteristic: GATTCharacteristic) throws {
        guard gattCharacteristic.properties.contains(.write) else {
            throw BLEPeripheralError.writeTypeNotSupported
        }

        cbPeripheral.writeValue(value, for: gattCharacteristic.cbCharacteristic, type: .withResponse)
    }


    /// Write `value` to `gattCharacteristics` if it contains the writeWithoutResponse property.
    ///
    /// This method corresponds with the Write Without Response as defined in Bluetooth's Core Specification (4.9.1). In this case a response is not received. This write alternative, also knows as write command is preferred when sending larger amounts of data.
    public func writeWithoutResponse(_ value: Data, to gattCharacteristic: GATTCharacteristic) throws {
        guard gattCharacteristic.properties.contains(.writeWithoutResponse) else {
            throw BLEPeripheralError.writeTypeNotSupported
        }

        cbPeripheral.writeValue(value, for: gattCharacteristic.cbCharacteristic, type: .withoutResponse)
    }


    public func serviceAt(index: Int) -> GATTService? {
        guard index < services.count else {
            assertionFailure("BLEPeripheral: index out of bounds trying to get a service")
            return nil
        }

        return services[index]
    }


    // MARK: - Private Section -
    private var services = [GATTService]()

    /// The DispatchQueue where the delegate methods will be executed
    private let resultQueue: DispatchQueue

}


// MARK: - Comparable
extension BLEPeripheral: Comparable {
    public static func < (lhs: BLEPeripheral, rhs: BLEPeripheral) -> Bool {
        lhs.name < rhs.name
    }
}


// MARK: - Custom Equatable, Hashable
extension BLEPeripheral {
    public override func isEqual(_ blePeripheral: Any?) -> Bool {
        guard let peripheral = blePeripheral as? BLEPeripheral else { return false }

        guard let myName = self.cbPeripheral.name, let otherPeripheralName = peripheral.cbPeripheral.name else {
            return self.identifier == peripheral.identifier
        }

        return self.identifier == peripheral.identifier || myName == otherPeripheralName
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
}


// MARK: - CustomDebugStringComparable
extension BLEPeripheral {
    public override var debugDescription: String {
        let debugString =
        """

            ~ BLEPeripheral ~~~~~~~~~~~~~~~
            Name: \(name)
            rssi: \(rssi?.stringValue ?? "N/A")
            txPower: \(txPower?.stringValue ?? "N/A")
            identifier: \(identifier)
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        """

        return debugString
    }
}


// MARK: - CBPeripheralDelegate
extension BLEPeripheral: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("peripheral: \(peripheral) -------------")
        print("didDiscoverServices: \(String(describing: peripheral.services))")
        print("with error: \(error?.localizedDescription ?? "no error")")

        if let anError = error {
            resultQueue.async {
                self.delegate?.didFailDiscoveringServicesWith(error: .serviceDiscoveryFailed(description: anError.localizedDescription))
            }
            return
        }

        guard let discoveredServices = peripheral.services else {
            resultQueue.async {
                self.delegate?.didFailDiscoveringServicesWith(error: .noServicesDiscovered)
            }
            return
        }

        services = discoveredServices.map { GATTService(service: $0) }

        discoveredServices.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }


    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")
        SwiftyBeaver.info("peripheral: \(peripheral) ~~~~~~~~~~~~~~~~~")
        SwiftyBeaver.info("Characteristics: \(String(describing: service.characteristics))")
        SwiftyBeaver.info("error: \(error?.localizedDescription ?? "no error")")

        if let anError = error {
            resultQueue.async {
                self.delegate?.didFailDiscoveringServicesWith(error: .characteristicsDiscoveryFailed(description: anError.localizedDescription))
            }
            return
        }

        resultQueue.async {
            self.delegate?.didDiscoverService(GATTService(service: service))
        }
    }


    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")
        SwiftyBeaver.info("peripheral: \(peripheral) ~~~~~~~~~~~~~~~~~")
        SwiftyBeaver.info("Characteristic: \(characteristic)")

        if let anError = error {
            resultQueue.async {
                self.delegate?.didFailReadingCharacteristicValueWith(error: .characteristicReadValueFailed(description: anError.localizedDescription))
            }
            return
        }


        resultQueue.async {
            self.delegate?.didUpdateCharacteristicValueFor(GATTCharacteristic(characteristic: characteristic))
        }
    }


    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let anError = error {
            resultQueue.async {
                self.delegate?.didFailCharacteristicSubscriptionWith(error: .characteristicSubscriptionFailed(description: anError.localizedDescription))
            }
            return
        }

        resultQueue.async {
            self.delegate?.didChangeSubscriptionStateFor(GATTCharacteristic(characteristic: characteristic))
        }
    }


    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral: \(peripheral) ~~~~~~~~~~~~~~~")
        print("didWriteValueFor: \(characteristic)")
        print("with error: \(error?.localizedDescription ?? "no error")")

        if let anError = error {
            resultQueue.async {
                self.delegate?.didFailCharacteristicWritingWith(error: .characteristicWriteFailed(description: anError.localizedDescription))

            }
            return
        }

        resultQueue.async {
            self.delegate?.didWriteToCharacteristic(GATTCharacteristic(characteristic: characteristic))
        }
    }
}
