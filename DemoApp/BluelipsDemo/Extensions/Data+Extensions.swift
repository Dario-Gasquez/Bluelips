//
//  Data+Extensions.swift
//  BluelipsDemo
//
//  Created by Dario on 30/11/2021.
//

import Foundation

extension Data {
    var hexEncodedString: String {
        let format = "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}
