//
//  BLEPeripheralDelegate.swift
//  
//
//  Created by Dario on 23/11/2021.
//

import CoreBluetooth

public protocol BLEPeripheralDelegate: AnyObject {
    func didDiscoverService(_ service: GATTService)
    func didFailDiscoveringServicesWith(error: BLEPeripheralError)
    func didFailReadingCharacteristicValueWith(error: BLEPeripheralError)
    func didUpdateCharacteristicValueFor(_ gattCharacteristic: GATTCharacteristic)
    func didChangeSubscriptionStateFor(_ gattCharacteristic: GATTCharacteristic)
    func didFailCharacteristicSubscriptionWith(error: BLEPeripheralError)
    func didWriteToCharacteristic(_ gattCharacteristic: GATTCharacteristic)
    func didFailCharacteristicWritingWith(error: BLEPeripheralError)
}

// MARK: - Optionals
public extension BLEPeripheralDelegate {
    func didDiscoverService(_ service: GATTService) {}
    func didFailDiscoveringServicesWith(error: BLEPeripheralError) {}
    func didFailReadingCharacteristicValueWith(error: BLEPeripheralError) {}
    func didUpdateCharacteristicValueFor(_ gattCharacteristic: GATTCharacteristic) {}
    func didChangeSubscriptionStateFor(_ gattCharacteristic: GATTCharacteristic) {}
    func didFailCharacteristicSubscriptionWith(error: BLEPeripheralError) {}
    func didWriteToCharacteristic(_ gattCharacteristic: GATTCharacteristic) {}
    func didFailCharacteristicWritingWith(error: BLEPeripheralError) {}
}
