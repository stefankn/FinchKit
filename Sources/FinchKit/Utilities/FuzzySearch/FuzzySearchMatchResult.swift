//
//  FuzzySearchMatchResult.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 14/03/2025.
//

import Foundation

public struct FuzzySearchMatchResult {
    
    // MARK: - Properties
    
    /// The score of the result, higher is better.
    let weight: Int
    
    /// The ranges of the string that match the search query.
    let matchedParts: [NSRange]
}
