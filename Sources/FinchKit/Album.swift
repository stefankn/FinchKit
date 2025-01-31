//
//  Album.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

public struct Album: Codable, Identifiable, Hashable, Sendable {
    
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
    
    public let id: Int
    public let title: String
    public let artist: String
    public let artistSortKey: String
    public let type: AlbumType
    public let types: [AlbumType]
    public let genre: String?
    public let year: Int
    public let discCount: Int
    public let label: String?
    public let isArtworkAvailable: Bool
    public let addedAt: Date
    public let media: String?
}
