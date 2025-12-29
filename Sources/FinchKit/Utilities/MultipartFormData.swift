//
//  MultipartFormData.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 29/12/2025.
//

import Foundation

public struct MultipartFormData {
    
    // MARK: - Private Properties
    
    private let separator = "\r\n"
    private var data = Data()
    
    
    
    // MARK: - Properties
    
    public let boundary: String
    
    public var httpContentTypeHeaderValue: String {
        "multipart/form-data; boundary=\(boundary)"
    }
    
    public var httpBody: Data {
        var body = data
        body.append("--\(boundary)--")
        return body
    }
    
    
    
    // MARK: - Construction
    
    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
    }
    
    
    
    // MARK: - Functions
    
    public mutating func add(key: String, value: String) {
        appendBoundarySeparator()
        data.append(disposition(key) + separator)
        appendSeparator()
        data.append(value + separator)
    }
    
    public mutating func add(key: String, fileName: String, mimeType: String, fileData: Data) {
        appendBoundarySeparator()
        data.append(disposition(key) + "; filename=\"\(fileName)\"" + separator)
        data.append("Content-Type: \(mimeType)" + separator + separator)
        data.append(fileData)
        appendSeparator()
    }
    
    
    
    // MARK: - Private Functions
    
    private func disposition(_ key: String) -> String {
        "Content-Disposition: form-data; name=\"\(key)\""
    }
    
    private mutating func appendBoundarySeparator() {
        data.append("--\(boundary)\(separator)")
    }
    
    private mutating func appendSeparator() {
        data.append(separator)
    }
}
