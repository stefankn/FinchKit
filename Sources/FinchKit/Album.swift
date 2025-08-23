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
    public let filter: AlbumFilter
    public let type: String
    public let genre: String?
    public let style: String?
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
    public let discogsAlbumId: Int?
    public let discogsArtistId: Int?
    public let discogsLabelId: Int?
    public let isOfflineAvailable: Bool
    
    public var discogsAlbumURL: URL? {
        guard let discogsAlbumId else { return nil }
        
        return URL(string: "https://discogs.com/release/\(discogsAlbumId)")
    }
    
    
    
    // MARK: - Construction
    
    public init(
        id: Int,
        title: String,
        artist: String,
        filter: AlbumFilter,
        type: String,
        genre: String?,
        style: String?,
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
        discogsAlbumId: Int?,
        discogsArtistId: Int?,
        discogsLabelId: Int?,
        isOfflineAvailable: Bool
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.filter = filter
        self.type = type
        self.genre = genre
        self.style = style
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
        self.discogsAlbumId = discogsAlbumId
        self.discogsArtistId = discogsArtistId
        self.discogsLabelId = discogsLabelId
        self.isOfflineAvailable = isOfflineAvailable
    }
    
    init(_ response: AlbumResponse, filter: AlbumFilter) {
        id = response.id
        title = response.title
        artist = response.artist
        type = response.type
        genre = response.genre
        style = response.style
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
        discogsAlbumId = response.discogsAlbumId
        discogsArtistId = response.discogsArtistId
        discogsLabelId = response.discogsLabelId
        
        isOfflineAvailable = false
        self.filter = filter
    }
    
    init(_ album: OfflineAlbum) {
        id = album.id
        title = album.title
        artist = album.artist
        filter = AlbumFilter(rawValue: album.filter) ?? .album
        type = album.type
        genre = album.genre
        style = album.style
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
        discogsAlbumId = album.discogsAlbumId
        discogsArtistId = album.discogsArtistId
        discogsLabelId = album.discogsLabelId
        isOfflineAvailable = true
    }
}
