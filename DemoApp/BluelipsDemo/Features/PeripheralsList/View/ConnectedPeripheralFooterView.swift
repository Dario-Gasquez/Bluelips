//
//  ConnectedPeripheralFooterView.swift
//  BluelipsDemo
//
//  Created by Dario on 22/11/2021.
//

import UIKit
import Bluelips

class ConnectedPeripheralFooterView: UIView {

    var disconnectAction: ( () -> Void )?
    var connectedPeripheralName: String? {
        didSet { updateUI() }
    }

    // MARK: - Private Section -
    private enum Constants {
        static let noPeripheralName = "none"
    }

    @IBOutlet private var connectedPeripheralLabel: UILabel!
    @IBOutlet private var disconnectButton: UIButton!

    @IBAction private func didTapDisconnect(_ sender: UIButton) {
        print("didTapDisconnect")
        disconnectAction?()
    }

    private func updateUI() {
        let peripheralName = connectedPeripheralName ?? Constants.noPeripheralName
        let isPeripheralConnected = (connectedPeripheralName != nil)

        connectedPeripheralLabel?.text = "Connected peripheral: \(peripheralName)"
        disconnectButton?.isEnabled = isPeripheralConnected
    }

}
