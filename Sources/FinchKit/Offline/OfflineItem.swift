//
//  OfflineItem.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 31/01/2025.
//

import Foundation
import SwiftData

@Model final class OfflineItem {
    
    // MARK: - Properties
    
    @Attribute(.unique) public var id: Int
    
    var track: Int?
    var disc: Int?
    var title: String
    var artist: String
    var duration: Double
    var format: String
    var bitrate: Int
    var sampleRate: Int
    var genre: String?
    var lyricist: String?
    var composer: String?
    var comments: String?
    var musicBrainzId: String?
    var albumId: Int?
    var filename: String
    
    var album: OfflineAlbum?
    
    
    
    // MARK: - Construction
    
    init(_ item: Item, filename: String, album: OfflineAlbum?) {
        id = item.id
        
        track = item.track
        disc = item.disc
        title = item.title
        artist = item.artist
        duration = item.duration.seconds
        format = item.format
        bitrate = item.bitrate
        sampleRate = item.sampleRate
        genre = item.genre
        lyricist = item.lyricist
        composer = item.composer
        comments = item.comments
        musicBrainzId = item.musicBrainzId
        albumId = item.albumId
        
        self.filename = filename
        self.album = album
    }
}
