//
//  PeripheralDetailsViewController.swift
//  BluelipsDemo
//
//  Created by Dario on 18/11/2021.
//

import UIKit
import Bluelips

class PeripheralDetailsViewController: UIViewController, Storyboarded {

    var peripheral: BLEPeripheral? {
        didSet {
            peripheral?.delegate = self
            peripheral?.detectServices()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        servicesTableView.dataSource = peripheralServicesDataSource
        servicesTableView.delegate = self

        updateUI()
    }

    // MARK: - Private Section -
    @IBOutlet private var peripheralName: UILabel!
    @IBOutlet private var servicesTableView: UITableView!
    private let peripheralServicesDataSource = PeripheralServicesDataSource()


    private func updateUI() {
        navigationItem.title = "Peripheral Details"
        peripheralName.text = peripheral?.name
    }
}



extension PeripheralDetailsViewController: BLEPeripheralDelegate {

    func didFailDiscoveringServicesWith(error: BLEPeripheralError) {
        showAlert(title: "Service Discovery Error", message: error.description)
    }

    func didDiscoverService(_ service: GATTService) {
        peripheralServicesDataSource.addService(service)

        peripheralServicesDataSource.userDidChooseRead = { [weak self] gattCharacteristic in
            self?.peripheral?.readValueFor(gattCharacteristic)
        }

        servicesTableView?.reloadData()
    }


    func didFailReadingCharacteristicValueWith(error: BLEPeripheralError) {
        showAlert(title: "Characteristic Read Error", message: error.description)
    }

    func didUpdateCharacteristicValueFor(_ gattCharacteristic: GATTCharacteristic) {
        let noData = "no data"
        let valueAsHexString = gattCharacteristic.value?.hexEncodedString ?? noData
        var valueAsUTF8 = noData

        if let data = gattCharacteristic.value {
            valueAsUTF8 = String(data: data, encoding: .utf8) ?? "no utf8 compatible"
        }
        let msg =
            """
            uuid: \(gattCharacteristic.uuid)

            new value as hex:
            \(valueAsHexString)

            new value as utf8:
            \(valueAsUTF8)
            """

        showAlert(title: "Successfully read characteristic", message: msg)
    }
}


extension PeripheralDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedService = peripheral?.serviceAt(index: indexPath.section) else {
            assertionFailure("PeripheralDetailsViewController: unable to obtain selected GATTService from BLEPerihperal")
            return
        }

        guard let selectedCharacteristic = selectedService.characteristicAt(index: indexPath.row) else {
            assertionFailure("PeripheralDetailsViewController: unable to obtain selected GATTCharacteristic from selected service")
            return
        }

        let characteristicDetailsVC = CharacteristicDetailsViewController.instantiate()
        characteristicDetailsVC.peripheral = peripheral
        characteristicDetailsVC.gattCharacteristic = selectedCharacteristic
        navigationController?.pushViewController(characteristicDetailsVC, animated: true)
    }
}
