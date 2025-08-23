//
//  Item.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 31/01/2025.
//

import Foundation

public struct Item: Codable, Hashable, Identifiable, Sendable, Comparable {
    
    // MARK: - Private Properties
    
    private var sortIndex: Int {
        (disc ?? 0) * 1000 + (track ?? 0)
    }
    
    

    // MARK: - Properties
    
    public let id: Int
    public let entryId: Int?
    public let track: Int?
    public let disc: Int?
    public let title: String
    public let artist: String
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
    private(set) var offlineFilename: String?
    
    public var artistsDescription: String {
        artist
    }
    
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
    
    public init(
        id: Int,
        entryId: Int?,
        track: Int?,
        disc: Int?,
        title: String,
        artist: String,
        duration: Duration,
        format: String,
        bitrate: Int,
        sampleRate: Int,
        genre: String?,
        lyricist: String?,
        composer: String?,
        comments: String?,
        musicBrainzId: String?,
        albumId: Int?,
        offlineFilename: String?
    ) {
        self.id = id
        self.entryId = entryId
        self.track = track
        self.disc = disc
        self.title = title
        self.artist = artist
        self.duration = duration
        self.format = format
        self.bitrate = bitrate
        self.sampleRate = sampleRate
        self.genre = genre
        self.lyricist = lyricist
        self.composer = composer
        self.comments = comments
        self.musicBrainzId = musicBrainzId
        self.albumId = albumId
        self.offlineFilename = offlineFilename
    }
    
    init(_ response: ItemResponse, entryId: Int? = nil) {
        id = response.id
        self.entryId = entryId
        track = response.track
        disc = response.disc
        title = response.title
        artist = response.artist
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
        entryId = nil
        track = offlineItem.track
        disc = offlineItem.disc
        title = offlineItem.title
        artist = offlineItem.artist
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
    
    
    
    // MARK: - Functions
    
    mutating func fileRemoved() {
        offlineFilename = nil
    }
    
    
    // MARK: Comparable Functions
    
    public static func < (lhs: Item, rhs: Item) -> Bool {
        lhs.sortIndex < rhs.sortIndex
    }
}
