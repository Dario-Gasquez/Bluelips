//
//  CentralManagerFactory.swift
//  
//
//  Created by Dario on 17/12/2021.
//

import Foundation
import CoreBluetooth

public final class CentralManagerFactory {

    public init(shouldMakeAMock: Bool = false) {
        self.shouldMakeAMock = shouldMakeAMock
    }


    func makeACentralManager(withDelegate delegate: CBCentralManagerDelegate?, queue: DispatchQueue?, shouldPreserveState: Bool = false) -> CBCentralManager {
        if shouldMakeAMock {
            return CBCentralManagerMock(withDelegate: delegate)
        } else {
            var options: [String: Any]?
            if shouldPreserveState {
                options = [CBCentralManagerOptionRestoreIdentifierKey: Constants.centralManagerRestorationIdentifier]
            }

            return CBCentralManager(delegate: delegate, queue: queue, options: options)
        }
    }


    // MARK: - Private Section -
    private enum Constants {
        static let centralManagerRestorationIdentifier = "com.ble-services-library.centralManagerRestorationIdentifier"
    }

    private let shouldMakeAMock: Bool


}
