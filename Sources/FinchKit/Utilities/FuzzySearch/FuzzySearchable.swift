//
//  FuzzySearchable.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 14/03/2025.
//

import Foundation

public protocol FuzzySearchable {
    
    // MARK: - Properties
    
    var searchableString: String { get }
    
    
    
    // MARK: - Functions
    
    func fuzzyMatch(_ query: String) -> FuzzySearchMatchResult
}

extension FuzzySearchable {
    
    // MARK: - Functions
    
    public func fuzzyMatch(_ query: String) -> FuzzySearchMatchResult {
        let characters = FuzzySearchString(characters: searchableString.normalize())

        let compareString = characters.characters
        let searchString = query.lowercased()
        
        var totalScore = 0
        var matchedParts: [NSRange] = []
        
        var patternIndex = 0
        var currentScore = 0
        var currentMatchedPart = NSRange(location: 0, length: 0)
        
        for (index, character) in compareString.enumerated() {
            if let prefixLength = searchString.prefixCount(for: character, startingAt: patternIndex) {
                patternIndex += prefixLength
                currentScore += 1
                currentMatchedPart.length += 1
            } else {
                currentScore = 0
                if currentMatchedPart.length != 0 {
                    matchedParts.append(currentMatchedPart)
                }
                
                currentMatchedPart = NSRange(location: index + 1, length: 0)
            }
            
            totalScore += currentScore
        }
        
        if currentMatchedPart.length != 0 {
            matchedParts.append(currentMatchedPart)
        }
        
        if searchString.count == matchedParts.reduce(0, { partialResult, range in
            range.length + partialResult
        }) {
            return FuzzySearchMatchResult(weight: totalScore, matchedParts: matchedParts)
        } else {
            return FuzzySearchMatchResult(weight: 0, matchedParts: [])
        }
    }
}

