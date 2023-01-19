//
//  PeripheralsListViewController.swift
//  BluelipsDemo
//
//  Created by Dario on 12/11/2021.
//

import UIKit
import Bluelips

class PeripheralsListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Start the BLE services library
        bleServicesManager.start()

        scannedPeripheralsTableView.dataSource = scannedPeripheralsDataSource
        scannedPeripheralsTableView.delegate = self

        connectedPeripheralFooter.disconnectAction = { [weak self] in
            self?.bleServicesManager.disconnectFromPeripheral()
        }
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateHeaderUIWith(state: bleServicesManager.currentState)
        updateConnectedPeripheralFooter()
        // peripherals information could have changed so we need to refresh the list to reflect any possible change in name, order, etcetera.
        scannedPeripheralsTableView.reloadData()
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if bleServicesManager.currentState == .scanning {
            bleServicesManager.stopScanning()
        }
    }

    // MARK: - Private Section -
    private enum Constants {
        static let stopScanButtonText = "Stop"
        static let startScanButtonText = "Scan"
    }

    @IBOutlet private var bleStateLabel: UILabel!
    @IBOutlet private var scanButton: UIBarButtonItem!
    @IBOutlet private var scannedPeripheralsTableView: UITableView!
    @IBOutlet private var connectedPeripheralFooter: ConnectedPeripheralFooterView!

    private lazy var bleServicesManager = BLEServicesManager(withDelegate: self)

    private let scannedPeripheralsDataSource = ScannedPeripheralsDataSource()


    @IBAction private func didTapScan(_ sender: UIBarButtonItem) {
        if bleServicesManager.currentState == .scanning {
            bleServicesManager.stopScanning()
        } else {
            scannedPeripheralsDataSource.cleanPeripheralsList()
             bleServicesManager.startScanning()
        }
    }


    private func updateConnectedPeripheralFooter() {
        connectedPeripheralFooter.connectedPeripheralName = bleServicesManager.connectedPeripheralName
    }


    private func updateHeaderUIWith(state: BLEState) {
        let stateDescription = "Bluetooth state: \(state)"
        print(stateDescription)
        bleStateLabel.text = stateDescription

        scanButton.isEnabled = (state == .poweredOn || state == .scanning)
        scanButton.title = (state == .scanning ? Constants.stopScanButtonText : Constants.startScanButtonText)
    }
}



extension PeripheralsListViewController: BLEServicesDelegate {
    func didDisconnectFrom(blePeripheral: BLEPeripheral, error: BLEServicesError?) {
        print("didDisconnectFrom: \(blePeripheral)")

        if let anError = error {
            let disconnectionMessage =
            """
            Disconnected from \(blePeripheral.name).
            Disconnection reason:
            \(anError.description)
            """
            showAlert(title: "Peripheral Disconnection", message: disconnectionMessage)
        }

        updateConnectedPeripheralFooter()
    }


    func didFailConnectionTo(blePeripheral: BLEPeripheral, error: BLEServicesError) {
        print("didFailConnectionTo blePeripheral: \(blePeripheral) with error: \(error.localizedDescription)")
        showAlert(title: "Peripheral Connection Error", message: error.localizedDescription)
    }


    func stateDidChangeTo(newState: BLEState) {
        updateHeaderUIWith(state: newState)
    }


    func didDiscoverPeripheral(_ blePeripheral: BLEPeripheral) {
        print("new peripheral was discovered: \(blePeripheral)")

        scannedPeripheralsDataSource.addPeripheral(blePeripheral)
        scannedPeripheralsTableView.reloadData()
    }


    func didConnectTo(blePeripheral: BLEPeripheral) {
        print("didConnectTo: \(blePeripheral)")

        let peripheralDetailsVC = PeripheralDetailsViewController.instantiate()
        peripheralDetailsVC.peripheral = blePeripheral
        self.navigationController?.pushViewController(peripheralDetailsVC, animated: true)
    }
}


extension PeripheralsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedPeripheral = scannedPeripheralsDataSource.peripheralAt(index: indexPath.row) else {
            assertionFailure("UITableViewDelegate: Unable to retrieve selected peripheral")
            return
        }

        // Ask BLE Services Library to connect to the selected peripheral
        bleServicesManager.connectTo(blePeripheral: selectedPeripheral)
    }
}
