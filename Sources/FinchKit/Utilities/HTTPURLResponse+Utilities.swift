//
//  HTTPURLResponse+Utilities.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

extension HTTPURLResponse {
    
    // MARK: - Properties
    
    var status: HTTPStatus {
        HTTPStatus(statusCode)
    }
}
