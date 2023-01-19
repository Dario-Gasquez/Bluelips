//
//  BLEPeripheralError.swift
//  
//
//  Created by Dario on 24/11/2021.
//

public enum BLEPeripheralError: Error {
    case noServicesDiscovered
    case serviceDiscoveryFailed(description: String?)
    case characteristicsDiscoveryFailed(description: String?)
    case characteristicReadValueFailed(description: String?)
    case characteristicSubscriptionFailed(description: String?)
    case writeTypeNotSupported
    case characteristicWriteFailed(description: String?)

    public var description: String {
        let unknownCause = "unknown cause"
        switch self {
        case .noServicesDiscovered:
            return "No GATT service were discovered"
        case .serviceDiscoveryFailed(let description):
            return "Service discovery failed due to: \(description ?? unknownCause)"
        case .characteristicsDiscoveryFailed(let description):
            return "Characteristics discovery failed due to: \(description ?? unknownCause)"
        case .characteristicReadValueFailed(let description):
            return "Characteristic read value failed with error: \(description ?? unknownCause)"
        case .characteristicSubscriptionFailed(let description):
            return "Characteristic subscription/unsubscription failed with error: \(description ?? unknownCause)"
        case .writeTypeNotSupported:
            return "The Characteristic does not support the desired write type"
        case .characteristicWriteFailed(let description):
            return "Characteristic write failed with error: \(description ?? unknownCause)"
        }
    }
}
