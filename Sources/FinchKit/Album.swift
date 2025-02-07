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
    public let isOfflineAvailable: Bool
}

extension Album {
    
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
        isOfflineAvailable = false
    }
    
    init(_ album: OfflineAlbum) {
        id = album.id
        title = album.title
        artist = album.artist
        artistSortKey = album.artistSortKey
        type = AlbumType(rawValue: album.type) ?? .album
        types = album.types.split(separator: ",").compactMap{ AlbumType(rawValue: String($0)) }
        genre = album.genre
        year = album.year
        discCount = album.discCount
        label = album.label
        isArtworkAvailable = album.isArtworkAvailable
        addedAt = album.addedAt
        media = album.media
        isOfflineAvailable = true
    }
}
