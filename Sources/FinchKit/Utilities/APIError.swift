//
//  APIError.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

public enum APIError: LocalizedError {
    case badRequest(String?)
    case failure(HTTPStatus, Data?)
    case imageTooLarge
    case invalidImage
    case notFound
    
    
    
    // MARK: - Properties
    
    public var errorDescription: String? {
        switch self {
        case .badRequest(let message):
            return message ?? "Invalid request"
        case .imageTooLarge:
            return "Image is too large"
        case .invalidImage:
            return "Invalid image"
        case .notFound:
            return "Not found"
        case .failure(_, _):
            return "Request failed"
        }
    }
}
