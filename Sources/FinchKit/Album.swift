//
//  Album.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 31/01/2025.
//

import Foundation

public struct Album: Codable, Identifiable, Hashable, Sendable {
    
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
    
    
    
    // MARK: -  Construction
    
    init(_ response: AlbumResponse) {
        id = response.id
        title = response.title
        artist = response.artist
        artistSortKey = response.artistSortKey
        type = response.type
        types = response.types
        genre = response.genre
        year = response.year
        discCount = response.discCount
        label = response.label
        isArtworkAvailable = response.isArtworkAvailable
        addedAt = response.addedAt
        media = response.media
    }
}
