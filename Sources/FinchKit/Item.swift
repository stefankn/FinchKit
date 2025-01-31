//
//  Item.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

public struct Item: Codable, Hashable, Identifiable, Sendable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case id
        case track
        case disc
        case title
        case artist
        case artists
        case length
        case format
        case bitrate
        case sampleRate = "sample_rate"
        case genre
        case lyricist
        case composer
        case comments
        case musicBrainzId = "music_brainz_id"
        case albumId = "album_id"
    }
    
    
    
    // MARK: - Properties
    
    public let id: Int?
    public let track: Int?
    public let disc: Int?
    public let title: String
    public let artist: String
    public let artists: String
    public let length: Double
    public let format: String
    public let bitrate: Int
    public let sampleRate: Int
    public let genre: String?
    public let lyricist: String?
    public let composer: String?
    public let comments: String?
    public let musicBrainzId: String?
    public let albumId: Int?
    
    public var duration: Duration {
        .seconds(length)
    }
    
    public var durationDescription: String {
        duration.formatted(Duration.TimeFormatStyle(pattern: (duration.seconds / 60) >= 60 ? .hourMinuteSecond : .minuteSecond))
    }
}
