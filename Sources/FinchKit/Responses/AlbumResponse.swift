//
//  AlbumResponse.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

struct AlbumResponse: Codable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case artist
        case artistSortKey = "artist_sort_key"
        case type
        case types
        case genre
        case year
        case discCount = "disc_count"
        case label
        case isArtworkAvailable = "is_artwork_available"
        case addedAt = "added_at"
        case media
    }
    
    
    
    // MARK: - Properties
    
    let id: Int
    let title: String
    let artist: String
    let artistSortKey: String
    let type: AlbumType
    let types: [AlbumType]
    let genre: String?
    let year: Int
    let discCount: Int
    let label: String?
    let isArtworkAvailable: Bool
    let addedAt: Date
    let media: String?
}
