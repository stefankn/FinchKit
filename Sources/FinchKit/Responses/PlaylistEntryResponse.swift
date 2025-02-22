//
//  PlaylistEntryResponse.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 22/02/2025.
//

import Foundation

struct PlaylistEntryResponse: Codable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case id
        case index
        case item
        case createdAt = "created_at"
    }
    
    
    
    // MARK: - Properties
    
    let id: Int
    let index: Int
    let item: ItemResponse
    let createdAt: Date
}
