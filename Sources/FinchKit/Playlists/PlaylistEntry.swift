//
//  PlaylistEntry.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 22/02/2025.
//

import Foundation

public struct PlaylistEntry: Codable, Identifiable, Hashable, Sendable {

    // MARK: - Properties
    
    public let id: Int
    public let index: Int
    public let createdAt: Date
    public let item: Item
    
    
    
    // MARK: - Construction
    
    public init(id: Int, index: Int, createdAt: Date, item: Item) {
        self.id = id
        self.index = index
        self.createdAt = createdAt
        self.item = item
    }
    
    init(_ playlistEntry: PlaylistEntryResponse) {
        id = playlistEntry.id
        index = playlistEntry.index
        createdAt = playlistEntry.createdAt
        item = Item(playlistEntry.item, entryId: playlistEntry.id)
    }
}

extension PlaylistEntry: FuzzySearchable {
    
    // MARK: - Properties
    
    // MARK: FuzzySearchable Properties
    
    public var searchableString: String {
        item.artist + item.title
    }
}
