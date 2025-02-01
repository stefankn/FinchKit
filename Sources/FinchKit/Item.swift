//
//  Item.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 31/01/2025.
//

import Foundation

public struct Item: Codable, Hashable, Identifiable, Sendable {
    
    // MARK: - Properties
    
    public let id: Int
    public let track: Int?
    public let disc: Int?
    public let title: String
    public let artist: String
    public let artists: String
    public let duration: Duration
    public let format: String
    public let bitrate: Int
    public let sampleRate: Int
    public let genre: String?
    public let lyricist: String?
    public let composer: String?
    public let comments: String?
    public let musicBrainzId: String?
    public let albumId: Int?
    public let offlineFilename: String?
    
    public var durationDescription: String {
        duration.formatted(Duration.TimeFormatStyle(pattern: (duration.seconds / 60) >= 60 ? .hourMinuteSecond : .minuteSecond))
    }
    
    public var offlineURL: URL? {
        guard let offlineFilename, let offlineItemsPath = URL.offlineItemsPath else { return nil }
        
        return offlineItemsPath.appendingPathComponent(offlineFilename)
    }
    
    public var isOfflineAvailable: Bool {
        offlineURL != nil
    }
    
    
    
    // MARK: - Construction
    
    init(_ response: ItemResponse) {
        id = response.id
        track = response.track
        disc = response.disc
        title = response.title
        artist = response.artist
        artists = response.artists
        duration = .seconds(response.length)
        format = response.format
        bitrate = response.bitrate
        sampleRate = response.sampleRate
        genre = response.genre
        lyricist = response.lyricist
        composer = response.composer
        comments = response.comments
        musicBrainzId = response.musicBrainzId
        albumId = response.albumId
        offlineFilename = nil
    }
    
    init(_ offlineItem: OfflineItem) {
        id = offlineItem.id
        track = offlineItem.track
        disc = offlineItem.disc
        title = offlineItem.title
        artist = offlineItem.artist
        artists = offlineItem.artists
        duration = .seconds(offlineItem.duration)
        format = offlineItem.format
        bitrate = offlineItem.bitrate
        sampleRate = offlineItem.sampleRate
        genre = offlineItem.genre
        lyricist = offlineItem.lyricist
        composer = offlineItem.composer
        comments = offlineItem.comments
        musicBrainzId = offlineItem.musicBrainzId
        albumId = offlineItem.albumId
        offlineFilename = offlineItem.filename
    }
}
