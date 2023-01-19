//
//  BLEServicesDelegate.swift
//  
//
//  Created by Dario on 10/11/2021.
//

public protocol BLEServicesDelegate: AnyObject {
    func stateDidChangeTo(newState: BLEState)
    func didDiscoverPeripheral(_ blePeripheral: BLEPeripheral)
    func didConnectTo(blePeripheral: BLEPeripheral)
    func didFailConnectionTo(blePeripheral: BLEPeripheral, error: BLEServicesError)
    func didDisconnectFrom(blePeripheral: BLEPeripheral, error: BLEServicesError?)
}


// MARK: - Optionals
public extension BLEServicesDelegate {
    func stateDidChangeTo(newState: BLEState) {}
    func didDiscoverPeripheral(_ blePeripheral: BLEPeripheral) {}
    func didConnectTo(blePeripheral: BLEPeripheral) {}
    func didFailConnectionTo(blePeripheral: BLEPeripheral, error: BLEServicesError) {}
    func didDisconnectFrom(blePeripheral: BLEPeripheral, error: BLEServicesError?) {}
}
