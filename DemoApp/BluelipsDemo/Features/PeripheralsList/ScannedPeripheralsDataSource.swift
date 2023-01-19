//
//  ScannedPeripheralsDataSource.swift
//  BluelipsDemo
//
//  Created by Dario on 16/11/2021.
//


import UIKit
import Bluelips

final class ScannedPeripheralsDataSource: NSObject, UITableViewDataSource {

    func addPeripheral(_ peripheral: BLEPeripheral) {
        peripherals.update(with: peripheral)
        print("updated peripherals set ----------")
        print(peripherals.debugDescription)
    }


    func peripheralAt(index: Int) -> BLEPeripheral? {
        guard index < peripherals.count else {
            assertionFailure("ScannedPeripheralsDataSource:Index out of bounds for peripherals")
            return nil
        }

        return peripherals.sorted()[index]
    }


    /// Removes all scanned peripherals
    func cleanPeripheralsList() {
        peripherals.removeAll()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < peripherals.count else {
            fatalError("Index out of bound for ScannedPeripheralsDataSource's peripherals array")
        }

        let peripheralsSortedArray = peripherals.sorted()
        let peripheral = peripheralsSortedArray[indexPath.row]
        let cell: BLEPeripheralTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.textLabel?.text = peripheral.name

        return cell
    }


    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Detected Peripherals"
    }

    // MARK: - Private Section -
    private var peripherals = Set<BLEPeripheral>()
}
