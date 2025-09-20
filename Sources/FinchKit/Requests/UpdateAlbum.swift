//
//  UpdateAlbum.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 14/03/2025.
//

import Foundation

struct UpdateAlbum: Encodable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case artist
        case title
        case type
        case artworkPath = "artwork_path"
    }
    
    
    
    // MARK: - Properties
    
    let artist: String
    let title: String
    let type: String
    let artworkPath: String?
    
    
    
    // MARK: - Construction
    
    init(artist: String, title: String, type: String, artworkPath: String?) {
        self.artist = artist
        self.title = title
        self.type = type
        
        let artworkPath = artworkPath?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let artworkPath, !artworkPath.isEmpty {
            self.artworkPath = artworkPath
        } else {
            self.artworkPath = nil
        }
    }
}
