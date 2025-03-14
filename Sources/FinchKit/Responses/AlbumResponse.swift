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
        case artworkPath = "artwork_path"
        case addedAt = "added_at"
        case media
        case catalogNumber = "catalog_number"
        case barcode
        case asin
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
    let artworkPath: String?
    let addedAt: Date
    let media: String?
    let catalogNumber: String?
    let barcode: String?
    let asin: String?
}
