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
    var artistSortKey: String
    var type: String
    var types: String
    var genre: String?
    var year: Int
    var discCount: Int
    var label: String?
    var isArtworkAvailable: Bool
    var addedAt: Date
    var media: String?
    
    @Relationship(deleteRule: .cascade, inverse: \OfflineItem.album) var items: [OfflineItem]?
    
    
    
    // MARK: - Construction
    
    init(_ album: Album) {
        id = album.id
        title = album.title
        artist = album.artist
        artistSortKey = album.artistSortKey
        type = album.type.rawValue
        types = album.types.map{ $0.rawValue }.joined(separator: ",")
        genre = album.genre
        year = album.year
        discCount = album.discCount
        label = album.label
        isArtworkAvailable = album.isArtworkAvailable
        addedAt = album.addedAt
        media = album.media
        items = []
    }
}
