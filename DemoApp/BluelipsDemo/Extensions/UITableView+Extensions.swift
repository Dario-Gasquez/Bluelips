//
//  UITableView+Extensions.swift
//  BluelipsDemo
//
//  Created by Dario on 17/11/2021.
//

import UIKit

extension UITableView {

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue a reusable table view cell")
        }

        return cell
    }

}
