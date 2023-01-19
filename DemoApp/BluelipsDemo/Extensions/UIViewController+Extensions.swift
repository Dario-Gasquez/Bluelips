//
//  UIViewController+Extensions.swift
//  BluelipsDemo
//
//  Created by Dario on 19/11/2021.
//

import UIKit

extension UIViewController {

    func showAlert(title: String?, message: String, additionalAction: UIAlertAction? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionText = NSLocalizedString("Ok", comment: "alert view: action button text")
        let okAction = UIAlertAction(title: actionText, style: .default)
        alertController.addAction(okAction)

        if let extraAction = additionalAction {
            alertController.addAction(extraAction)
        }

        self.present(alertController, animated: true)
    }
}
