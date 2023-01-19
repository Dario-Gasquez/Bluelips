//
//  CBCentralManagerMock.swift
//  
//
//  Created by Dario on 17/12/2021.
//

import CoreBluetooth


final class CBCentralManagerMock: CBCentralManager {
    init(withDelegate delegate: CBCentralManagerDelegate?) {
        super.init(delegate: delegate, queue: nil, options: nil)
    }

    override func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]? = nil) {}

    override func stopScan() {}

    override var state: CBManagerState {
        return .poweredOn
    }
}
