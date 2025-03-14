//
//  FuzzySearchableArray+Utilities.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 14/03/2025.
//

import Foundation

extension Collection where Iterator.Element: FuzzySearchable {
    
    // MARK: - Functions
    
    public func fuzzySearch(_ query: String) -> [Iterator.Element] {
        fuzzySearchScores(query).map{ $0.item }
    }
    
    func fuzzySearchScores(_ query: String) -> [(result: FuzzySearchMatchResult, item: Iterator.Element)] {
        map{ (result: $0.fuzzyMatch(query), item: $0) }
            .filter{ $0.result.weight > 0 }
            .sorted{ $0.result.weight > $1.result.weight }
    }
}
