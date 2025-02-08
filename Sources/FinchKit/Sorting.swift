//
//  Sorting.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 08/02/2025.
//

import Foundation

public struct Sorting: Codable, Identifiable, Hashable, Sendable {
    
    // MARK: - Properties
    
    public let key: Key
    public let direction: Direction
    
    public static var title: Sorting {
        .init(.title, .ascending)
    }
    
    public static var artist: Sorting {
        .init(.artist, .ascending)
    }
    
    public static var added: Sorting {
        .init(.added, .ascending)
    }
    
    var parameters: FinchClient.Parameters {
        [
            ("sort", key.rawValue),
            ("direction", direction.rawValue)
        ]
    }
    
    
    // MARK: Identifiable Properties
    
    public var id: String {
        key.rawValue + direction.rawValue
    }
    
    
    
    // MARK: - Construction
    
    public init(_ key: Key, _ direction: Direction) {
        self.key = key
        self.direction = direction
    }
}

extension Sorting {
    public enum Key: String, CaseIterable, Codable, Sendable {
        case title
        case artist
        case added
        
        
        
        // MARK: - Properties
        
        public var title: String {
            switch self {
            case .title:
                return "Title"
            case .artist:
                return "Artist"
            case .added:
                return "Date added"
            }
        }
    }
}

extension Sorting {
    public enum Direction: String, CaseIterable, Codable, Sendable {
        case ascending
        case descending
        
        
        
        // MARK: - Properties
        
        public var systemImage: String {
            switch self {
            case .ascending:
                return "arrow.up"
            case .descending:
                return "arrow.down"
            }
        }
    }
}
