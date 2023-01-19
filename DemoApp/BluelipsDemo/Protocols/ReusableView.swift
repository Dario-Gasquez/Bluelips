//
//  ReusableView.swift
//  BluelipsDemo
//
//  Created by Dario on 17/11/2021.
//

protocol ReusableView {
    static var reuseIdentifier: String { get }
}


extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
