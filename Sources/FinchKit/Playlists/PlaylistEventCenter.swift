//
//  PlaylistEventCenter.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 23/02/2025.
//

import Foundation
import AsyncAlgorithms

public actor PlaylistEventCenter {
    
    // MARK: - Private Properties
    
    private var subscriptions: [Subscription] = []
    
    
    
    // MARK: - Functions
    
    public func observe(_ playlist: Playlist) -> Subscription {
        let channel = AsyncChannel<PlaylistEvent>()
        let subscription = Subscription(events: channel, playlist: playlist)
        
        subscriptions.append(subscription)
        
        return subscription
    }
    
    func broadcast(_ event: PlaylistEvent, for playlist: Playlist) async {
        let subscriptions = self.subscriptions.filter{ $0.playlist.id == playlist.id }
        guard !subscriptions.isEmpty else { return }
        
        for subscription in subscriptions {
            await subscription.events.send(event)
        }
    }
}
