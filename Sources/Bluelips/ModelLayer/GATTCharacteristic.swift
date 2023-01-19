//
//  GATTCharacteristic.swift
//  
//
//  Created by Dario on 29/11/2021.
//

import CoreBluetooth

/// A `CBCharacteristic` wrapper
///
/// Encapsulates a `CBCharacteristic` and provides methods and properties related to a GATT Characteristic.
public struct GATTCharacteristic {

    public enum Property: String, CustomStringConvertible {
        case read
        /// The characteristic's value can be written and a response will indicate success or not
        case write

        /// The characteristic's value can be written without a response
        case writeWithoutResponse

        /// The characteristic's value can be received without sending a response to indicate the value was received
        case notify

        /// The characteristic's value can be received, sending a response to indicate the reception of that value
        case indicate

        public var description: String {
            return self.rawValue
        }
    }

    init(characteristic: CBCharacteristic) {
        self.cbCharacteristic = characteristic
        self.properties = GATTCharacteristic.generatePropertiesFrom(characteristic)
    }

    public let cbCharacteristic: CBCharacteristic

    public let properties: [Property]

    public var value: Data? {
        return cbCharacteristic.value
    }

    public var description: String {
        let description =
        """
        uuid: \(cbCharacteristic.uuid)
        properties: \(properties)
        isNotifying: \(cbCharacteristic.isNotifying)
        """

        return description
    }

    public var uuid: CBUUID {
        return cbCharacteristic.uuid
    }

    public var propertiesDescription: String {
        return "properties: \(properties)"
    }

    public var isReadable: Bool {
        return properties.contains(.read)
    }

    /// Notifications and indications, while functionally different at the BLE stack level, are not distinct in Core Bluetooth
    public var isNotifiable: Bool {
        return properties.contains(.indicate) || properties.contains(.notify)
    }

    public var isSendingNotifications: Bool {
        return cbCharacteristic.isNotifying
    }


    // MARK: - Private Section -
    private static func generatePropertiesFrom(_ characteristic: CBCharacteristic) -> [Property] {
        let propertiesMap: [Property: CBCharacteristicProperties] = [
            .read: .read,
            .write: .write,
            .writeWithoutResponse: .writeWithoutResponse,
            .notify: .notify,
            .indicate: .indicate
        ]

        var properties = [Property]()
        propertiesMap.forEach { (key: Property, value: CBCharacteristicProperties) in
            if characteristic.properties.contains(value) {
                properties.append(key)
            }
        }
        return properties
    }
}
