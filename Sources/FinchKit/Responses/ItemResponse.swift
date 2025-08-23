//
//  ItemResponse.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

struct ItemResponse: Codable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case id
        case track
        case disc
        case title
        case artist
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
    
    let id: Int
    let track: Int?
    let disc: Int?
    let title: String
    let artist: String
    let length: Double
    let format: String
    let bitrate: Int
    let sampleRate: Int
    let genre: String?
    let lyricist: String?
    let composer: String?
    let comments: String?
    let musicBrainzId: String?
    let albumId: Int?
}
