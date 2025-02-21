//
//  Playlist.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 21/02/2025.
//

import Foundation

public struct Playlist: Codable, Identifiable, Sendable, Hashable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    
    
    // MARK: - Properties
    
    public let id: Int
    public let name: String
    public let description: String?
    public let createdAt: Date
    public let updatedAt: Date
    
    
    
    // MARK: - Construction
    
    public init(id: Int, name: String, description: String?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
