//
//  URLSessionTask+Utilities.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 31/01/2025.
//

import Foundation

extension URLSessionTask {
    
    // MARK: - Properties
    
    var progressStream: AsyncStream<Double> {
        AsyncStream { continuation in
            let observation = progress.observe(\.fractionCompleted) { _, change in
                continuation.yield(self.progress.fractionCompleted)
            }
            
            continuation.onTermination = { _ in
                _ = observation
            }
        }
    }
}
