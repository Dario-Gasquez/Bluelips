//
//  CharacteristicDetailsDataSource.swift
//  BluelipsDemo
//
//  Created by Dario on 03/12/2021.
//

import UIKit
import Bluelips

final class CharacteristicDetailsDataSource: NSObject, UITableViewDataSource {

    init(with characteristic: GATTCharacteristic) {
        self.gattCharacteristic = characteristic
    }

    func addReadValue(_ value: Data) {
        readValues.append(value)
    }


    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .properties:
            return gattCharacteristic.properties.count
        case .readValues:
            return readValues.count
        }
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CharacteristicDetailsTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        switch sections[indexPath.section] {
        case .properties:
            cell.textLabel?.text = gattCharacteristic.properties[indexPath.row].rawValue
        case .readValues:
            cell.textLabel?.text = "hex value: \(readValues[indexPath.row].hexEncodedString)"
        }

        return cell
    }


    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }


    // MARK: - Private Section -
    private enum Section {
        case properties
        case readValues

        var title: String {
            switch self {
            case .properties:
                return "Properties"
            case .readValues:
                return "Read Values"
            }
        }
    }

    private let sections: [Section] = [
        .properties,
        .readValues
    ]

    private let gattCharacteristic: GATTCharacteristic
    private var readValues = [Data]()
}
