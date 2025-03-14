//
//  String+Utilities.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 14/03/2025.
//

import Foundation

extension String {
    
    // MARK: - Functions
    
    /// Creates a case- and accent insensitive version of the string and returns it in an
    /// array of `FuzzySearchCharacter` objects, representing the original and normalized
    /// version of each character.
    ///
    func normalize() -> [FuzzySearchCharacter] {
        lowercased().map { character in
            guard
                let data = String(character).data(using: .ascii, allowLossyConversion: true),
                let normalizedCharacter = String(data: data, encoding: .ascii) else {
                
                return FuzzySearchCharacter(content: String(character), normalizedContent: String(character))
            }
            
            return FuzzySearchCharacter(content: String(character), normalizedContent: normalizedCharacter)
        }
    }
    
    func prefixCount(for prefix: FuzzySearchCharacter, startingAt index: Int) -> Int? {
        guard let stringIndex = self.index(startIndex, offsetBy: index, limitedBy: endIndex) else { return nil }
        
        let searchString = suffix(from: stringIndex)
        for prefix in [prefix.content, prefix.normalizedContent] where searchString.hasPrefix(prefix) {
            return prefix.count
        }
        
        return nil
    }
}
