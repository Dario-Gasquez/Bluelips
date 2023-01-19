//
//  PeripheralServicesDataSource.swift
//  BluelipsDemo
//
//  Created by Dario on 24/11/2021.
//

import UIKit
import Bluelips


final class PeripheralServicesDataSource: NSObject, UITableViewDataSource {

    func addService(_ gattService: GATTService) {
        services.append(gattService)
    }

    var userDidChooseRead: ( (_ characteristic: GATTCharacteristic) -> Void )?

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return services.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < services.count else {
            fatalError("Index out of bound for PeripheralServicesDataSource's services array")
        }

        return services[section].characteristicsCount
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section < services.count else {
            fatalError("Index out of bound for PeripheralServicesDataSource's services array")
        }

        let service = services[indexPath.section]
        guard let characteristic = service.characteristicAt(index: indexPath.row) else {
            fatalError("Unable to get characteristic at \(indexPath.row)")
        }

        let cell: GATTCharacteristicTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.gattCharacteristic = characteristic

        return cell
    }


    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < services.count else {
            fatalError("Index out of bound for PeripheralServicesDataSource's services array")
        }

        return "Service \(services[section].description)"
    }

    // MARK: - Private Section -
    private var services = [GATTService]()
}
