//
//  Storyboarded.swift
//  BluelipsDemo
//
//  Created by Dario on 18/11/2021.
//

import UIKit

/// A protocol that lets us instantiate view controllers from any storyboard.
protocol Storyboarded {
    static func instantiate(fromStoryboard storyboard: StoryboardName) -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(fromStoryboard storyboard: StoryboardName = .main) -> Self {
        // Creates a view controller from our storyboards. This relies on view controllers having the same storyboard identifier as their class name. This method shouldn't be overridden in conforming types.
        let storyboardIdentifier = String(describing: self)

        // instantiate a CustomViewController from the storyboard
        let storyboard = UIStoryboard(name: storyboard.rawValue, bundle: Bundle.main)

        // swiftlint:disable:next force_cast
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}

enum StoryboardName: String {
    case main           = "Main"
}
