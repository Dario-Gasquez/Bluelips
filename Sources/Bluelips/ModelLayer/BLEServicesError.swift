//
//  BLEServicesError.swift
//  
//
//  Created by Dario on 10/11/2021.
//

import Foundation

public enum BLEServicesError: Error {
    case unknown
    case setupFailed
    case connectionFailed(description: String?)
    case disconnectionError(description: String?)


    public var description: String {
        switch self {
        case .unknown:
            return "Unknown error"
        case .setupFailed:
            return "BLE Services Library setup failed"
        case .connectionFailed(let description):
            return "Connection failed due to \(description ?? "unknown cause")"
        case .disconnectionError(let description):
            return "Disconnected because \(description ?? "unknown cause")"
        }
    }
}


extension BLEServicesError: LocalizedError {
    public var errorDescription: String? {
        return "BLEServicesError: \(self.description)"
    }
}
