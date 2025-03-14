//
//  PlaylistManager.swift
//  Finch
//
//  Created by Stefan Klein Nulent on 23/02/2025.
//

import Foundation
import Factory

@MainActor
@Observable
public final class PlaylistManager {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    @Injected(\.finchClient) private var finchClient
    
    @ObservationIgnored
    @Injected(\.playlistEventCenter) private var eventCenter
    
    
    
    // MARK: - Properties
    
    public var playlists: [Playlist] = []
    
    
    
    // MARK: - Construction
    
    public init() {}
    
    
    
    // MARK: - Functions
    
    public func load() async throws {
        playlists = try await finchClient.getPlaylists()
    }
    
    public func create(name: String, description: String, item: Item? = nil) async throws {
        let playlist = try await finchClient.createPlaylist(
            name: name,
            description: description.isEmpty ? nil : description,
            items: [item].compactMap{ $0 }
        )
        
        playlists.append(playlist)
    }
    
    public func delete(_ playlist: Playlist) async throws {
        try await finchClient.delete(playlist)
        playlists = playlists.filter{ $0.id != playlist.id }
    }
    
    public func add(_ item: Item, to playlist: Playlist) async throws {
        let entry = try await finchClient.add(item, to: playlist)
        
        await eventCenter.broadcast(.added(entry), for: playlist)
    }
}
