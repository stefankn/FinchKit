//
//  OfflineAlbum.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 02/02/2025.
//

import Foundation
import SwiftData

@Model final class OfflineAlbum {
    
    // MARK: - Properties
    
    @Attribute(.unique) public var id: Int
    
    var title: String
    var artist: String
    var filter: String
    var type: String
    var genre: String?
    var style: String?
    var year: Int
    var discCount: Int
    var label: String?
    var isArtworkAvailable: Bool
    var artworkPath: String?
    var addedAt: Date
    var media: String?
    var catalogNumber: String?
    var barcode: String?
    var asin: String?
    var discogsAlbumId: Int?
    var discogsArtistId: Int?
    var discogsLabelId: Int?
    
    @Relationship(deleteRule: .cascade, inverse: \OfflineItem.album) var items: [OfflineItem]?
    
    
    
    // MARK: - Construction
    
    init(_ album: Album) {
        id = album.id
        title = album.title
        artist = album.artist
        filter = album.filter.rawValue
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
        items = []
    }
}
