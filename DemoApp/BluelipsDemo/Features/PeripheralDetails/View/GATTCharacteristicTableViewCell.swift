//
//  GATTCharacteristicTableViewCell.swift
//  BluelipsDemo
//
//  Created by Dario on 24/11/2021.
//

import UIKit
import Bluelips


class GATTCharacteristicTableViewCell: UITableViewCell {

    var gattCharacteristic: GATTCharacteristic? {
        didSet { updateUI() }
    }

    // MARK: - Private Section -
    @IBOutlet private var uuidLabel: UILabel!
    @IBOutlet private var propertiesLabel: UILabel!

    private func updateUI() {
        guard let characteristic = gattCharacteristic else { return }

        uuidLabel.text = "Characteristic uuid: \(characteristic.uuid)"
        propertiesLabel.text = characteristic.propertiesDescription
    }
}
