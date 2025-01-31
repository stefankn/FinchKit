//
//  Stats.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

public struct Stats: Decodable, Sendable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case trackCount = "track_count"
        case totalTime = "total_time"
        case approximateTotalSize = "approximate_total_size"
        case artistCount = "artist_count"
        case albumCount = "album_count"
        case albumArtistCount = "album_artist_count"
    }
    
    
    
    // MARK: - Properties
    
    public let trackCount: Int
    public let totalTime: String
    public let approximateTotalSize: String
    public let artistCount: Int
    public let albumCount: Int
    public let albumArtistCount: Int
}
