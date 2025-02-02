//
//  Sequence+Utilities.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 02/02/2025.
//

import Foundation

extension Sequence {
    
    // MARK: - Functions
    
    func asyncMap<T>(_ transform: @Sendable (Element) async throws -> T) async rethrows -> [T] {
        var values: [T] = []
        
        for element in self {
            try await values.append(transform(element))
        }
        
        return values
    }
}
