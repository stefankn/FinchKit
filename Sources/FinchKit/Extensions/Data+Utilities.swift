//
//  Data+Utilities.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 29/12/2025.
//

import Foundation

extension Data {
    
    // MARK: - Functions
    
    mutating func append(_ string: String, encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
