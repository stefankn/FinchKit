//
//  FuzzySearchCharacter.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 14/03/2025.
//

import Foundation

struct FuzzySearchCharacter {
    
    // MARK: - Properties
    
    /// Contains the original character.
    let content: String
    
    /// Contains the case- and accent-insensitive counterpart.
    let normalizedContent: String
}
