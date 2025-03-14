//
//  PlaylistViewModel.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 23/02/2025.
//

import Foundation
import Factory

@MainActor
@Observable
public final class PlaylistViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    @Injected(\.finchClient) private var finchClient
    
    @ObservationIgnored
    @Injected(\.playlistEventCenter) private var playlistEventCenter
    
    private var task: Task<Void, Never>?
    
    
    
    // MARK: - Properties
    
    public private(set) var entries: [PlaylistEntry] = []
    public private(set) var isLoading = false
    
    public let playlist: Playlist
    
    
    
    // MARK: - Construction
    
    public init(_ playlist: Playlist) {
        self.playlist = playlist
    }
    
    
    
    // MARK: - Functions
    
    public func observeEvents() async {
        guard task == nil else { return }
        
        let subscription = await playlistEventCenter.observe(playlist)
        
        task = Task {
            for await event in subscription.events where !Task.isCancelled {
                switch event {
                case .added(let entry):
                    entries.append(entry)
                case .removed(let entry):
                    entries.removeAll { $0.id == entry.id }
                }
            }
        }
    }
    
    public func loadEntries() async throws {
        isLoading = true
        
        do {
            entries = try await finchClient.getEntries(for: playlist)
        } catch {
            isLoading = false
            throw error
        }
        
        isLoading = false
    }
    
    public func entry(for id: PlaylistEntry.ID) -> PlaylistEntry? {
        entries.first(where: { $0.id == id })
    }
    
    public func remove(_ entry: PlaylistEntry) async throws {
        do {
            try await finchClient.delete(entry, from: playlist)
            await playlistEventCenter.broadcast(.removed(entry), for: playlist)
        } catch {
            try await loadEntries()
            throw error
        }
    }
}
