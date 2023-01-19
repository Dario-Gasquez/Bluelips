//
//  CharacteristicDetailsViewController.swift
//  BluelipsDemo
//
//  Created by Dario on 03/12/2021.
//

import Foundation
import UIKit
import Bluelips

class CharacteristicDetailsViewController: UIViewController, Storyboarded {

    override func viewDidLoad() {
        super.viewDidLoad()

        characteristicDetailsTableView.dataSource = characteristicDetailsDataSource
        characteristicUUIDLabel.text = "UUID: \(gattCharacteristic?.uuid.uuidString ?? Constants.notAvailable)"
    }

    var peripheral: BLEPeripheral? {
        didSet {
            peripheral?.delegate = self
        }
    }

    var gattCharacteristic: GATTCharacteristic?


    // MARK: - Private Section -
    private enum Constants {
        static let subscribeButtonText = "Subscribe"
        static let unsubscribeButtonText = "Unsubscribe"
        static let notAvailable = "N/A"
    }


    private lazy var characteristicDetailsDataSource: CharacteristicDetailsDataSource = {
        guard let characteristic = gattCharacteristic else {
            fatalError("CharacteristicDetailsViewController: set getCharacteristic before presenting this view")
        }

        return CharacteristicDetailsDataSource(with: characteristic)
    }()

    @IBOutlet private var characteristicDetailsTableView: UITableView!
    @IBOutlet private var characteristicUUIDLabel: UILabel!
    @IBOutlet private var readButton: UIButton!
    @IBOutlet private var subscriptionButton: UIButton!
    @IBOutlet private var writeButton: UIButton!

    @IBAction private func didTapRead(_ sender: UIButton) {
        guard let characteristic = gattCharacteristic else {
            assertionFailure("CharacteristicDetailsViewController: be sure to set the gattCharacteristic before presenting this view")
            return
        }

        peripheral?.readValueFor(characteristic)
    }

    @IBAction private func didTapSubscription(_ sender: UIButton) {
        guard let characteristic = gattCharacteristic else {
            assertionFailure("CharacteristicDetailsViewController: be sure to set the gattCharacteristic before presenting this view")
            return
        }

        if characteristic.isSendingNotifications {
            peripheral?.unsubscribeFromNotificationsFor(characteristic)
        } else {
            peripheral?.subscribeToNotificationsFor(characteristic)
        }
    }

    @IBAction private func didTapWrite(_ sender: UIButton) {
        let anA = "A".data(using: .utf8)!

        writeToCharacteristicWithResponse(true) { characteristic in
            try peripheral?.write(anA, to: characteristic)
        }
    }


    @IBAction private func didTapWriteWithoutResponse(_ sender: UIButton) {
        let anA = "A".data(using: .utf8)!

        writeToCharacteristicWithResponse(false) { characteristic in
            try peripheral?.writeWithoutResponse(anA, to: characteristic)
        }
    }


    private func writeToCharacteristicWithResponse(_ isResponseWriteType: Bool, writeFunction: (GATTCharacteristic) throws -> Void) {
        let writeType: GATTCharacteristic.Property = (isResponseWriteType ? .write : .writeWithoutResponse)

        guard let characteristic = gattCharacteristic else {
            assertionFailure("CharacteristicDetailsViewController: be sure to set the gattCharacteristic before presenting this view")
            return
        }

        guard characteristic.properties.contains(writeType) else {
            let warningMessage = "characteristic does not support \(writeType.description) type"
            print("writeToCharacteristicWithResponse: \(warningMessage) ")
            showAlert(title: "Characteristic Write Warning", message: warningMessage)
            return
        }

        do {
            try writeFunction(characteristic)
        } catch {
            showAlert(title: "Character Write Error", message: "Failed to write with error: \(error.localizedDescription)")
        }

    }
}


extension CharacteristicDetailsViewController: BLEPeripheralDelegate {
    func didFailReadingCharacteristicValueWith(error: BLEPeripheralError) {
        print("didFailReadingCharacteristicValueWith error: \(error.localizedDescription)")
        showAlert(title: "Characteristic Read Error", message: error.description)
    }


    func didUpdateCharacteristicValueFor(_ gattCharacteristic: GATTCharacteristic) {
        print("didUpdateCharacteristicValueFor gattCharacteristic: \(gattCharacteristic.description)")
        print("new value: \(gattCharacteristic.value?.hexEncodedString ?? "no value")")

        guard let characteristic = self.gattCharacteristic, characteristic.cbCharacteristic == gattCharacteristic.cbCharacteristic else {
            print("CharacteristicDetailsViewController: mismatch between stored and read characteristics")
            return
        }

        guard let value = gattCharacteristic.value else {
            return
        }

        characteristicDetailsDataSource.addReadValue(value)
        characteristicDetailsTableView.reloadData()
    }


    func didChangeSubscriptionStateFor(_ gattCharacteristic: GATTCharacteristic) {
        print("didChangeSubscriptionStateFor gattCharacteristic: \(gattCharacteristic.description)")

        guard let characteristic = self.gattCharacteristic, characteristic.cbCharacteristic == gattCharacteristic.cbCharacteristic else {
            print("CharacteristicDetailsViewController: mismatch between stored and subscribed/unsubscribed characteristics")
            return
        }

        let subscribeButtonText = characteristic.isSendingNotifications ? Constants.unsubscribeButtonText : Constants.subscribeButtonText
        subscriptionButton.setTitle(subscribeButtonText, for: .normal)
    }


    func didFailCharacteristicSubscriptionWith(error: BLEPeripheralError) {
        print("didFailCharacteristicSubscriptionWith error: \(error.localizedDescription)")
        showAlert(title: "Characteristic Subscription Error", message: error.description)
    }


    func didWriteToCharacteristic(_ gattCharacteristic: GATTCharacteristic) {
        print("didWriteToCharacteristic: \(gattCharacteristic.description)")

        showAlert(title: "Write Success", message: "Did successfully write new value")
    }


    func didFailCharacteristicWritingWith(error: BLEPeripheralError) {
        print("didFailCharacteristicWritingWith error: \(error.localizedDescription)")
        showAlert(title: "Write Error", message: error.localizedDescription)
    }
}
