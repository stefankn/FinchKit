//
//  HTTPStatus.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

public struct HTTPStatus: Equatable, Sendable {
    
    // MARK: - Constants
    
    public static let ok = HTTPStatus(200)
    public static let badRequest = HTTPStatus(400)
    public static let unauthorized = HTTPStatus(401)
    public static let forbidden = HTTPStatus(403)
    public static let notFound = HTTPStatus(404)
    public static let notAllowed = HTTPStatus(405)
    public static let preconditionFailed = HTTPStatus(412)
    
    
    
    // MARK: - Properties
    
    public let code: Int
    
    public var isSuccess: Bool {
        200 ..< 300 ~= code
    }
    
    public var isClientError: Bool {
        400 ..< 500 ~= code
    }
    
    public var isServerError: Bool {
        500 ..< 600 ~= code
    }
    
    
    
    // MARK: - Construction
    
    init(_ code: Int) {
        self.code = code
    }
}
