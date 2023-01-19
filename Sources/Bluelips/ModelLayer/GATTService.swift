//
//  GATTService.swift
//  
//
//  Created by Dario on 24/11/2021.
//

import CoreBluetooth


/// A `CBService` wrapper
///
/// Encapsulates a `CBService` and provides methods and properties related to a GATT service and its characteristics.
public struct GATTService {

    init(service: CBService) {
        self.service = service
    }

    public var description: String {
        "uuid: \(service.uuid)"
    }

    public var characteristicsCount: Int {
        return service.characteristics?.count ?? 0
    }


    public func characteristicAt(index: Int) -> GATTCharacteristic? {
        guard let characteristics = service.characteristics else {
            assertionFailure("GATTService: tried to access a characteristic description with a nil characteristics array")
            return nil
        }

        guard index < characteristics.count else {
            fatalError("GATTService: index out of bound when trying to read a characteristic description")
        }

        let characteristic = characteristics[index]

        return GATTCharacteristic(characteristic: characteristic)
    }

    // MARK: - Private Section -
    private let service: CBService
}
