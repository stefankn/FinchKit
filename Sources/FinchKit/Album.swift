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
    public let artworkPath: String?
    public let addedAt: Date
    public let media: String?
    public let catalogNumber: String?
    public let barcode: String?
    public let asin: String?
    public let isOfflineAvailable: Bool
    
    
    
    // MARK: - Construction
    
    public init(
        id: Int,
        title: String,
        artist: String,
        artistSortKey: String,
        type: AlbumType,
        types: [AlbumType],
        genre: String?,
        year: Int,
        discCount: Int,
        label: String?,
        isArtworkAvailable: Bool,
        artworkPath: String?,
        addedAt: Date,
        media: String?,
        catalogNumber: String?,
        barcode: String?,
        asin: String?,
        isOfflineAvailable: Bool
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artistSortKey = artistSortKey
        self.type = type
        self.types = types
        self.genre = genre
        self.year = year
        self.discCount = discCount
        self.label = label
        self.isArtworkAvailable = isArtworkAvailable
        self.artworkPath = artworkPath
        self.addedAt = addedAt
        self.media = media
        self.catalogNumber = catalogNumber
        self.barcode = barcode
        self.asin = asin
        self.isOfflineAvailable = isOfflineAvailable
    }
    
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
        artworkPath = response.artworkPath
        addedAt = response.addedAt
        media = response.media
        catalogNumber = response.catalogNumber
        barcode = response.barcode
        asin = response.asin
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
        artworkPath = album.artworkPath
        addedAt = album.addedAt
        media = album.media
        catalogNumber = album.catalogNumber
        barcode = album.barcode
        asin = album.asin
        isOfflineAvailable = true
    }
}
