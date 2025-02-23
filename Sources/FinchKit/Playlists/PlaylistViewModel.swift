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
    
    private var subscription: PlaylistEventCenter.Subscription?
    
    
    
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
        let subscription = await playlistEventCenter.observe(playlist)
        
        for await event in subscription.events {
            switch event {
            case .added(let entry):
                entries.append(entry)
            }
        }
        
        self.subscription = subscription
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
}
