//
//  PlaylistEventCenterSubscription.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 23/02/2025.
//

import Foundation
import AsyncAlgorithms

extension PlaylistEventCenter {
    public struct Subscription: Sendable {
        
        // MARK: - Properties
        
        public let events: AsyncChannel<PlaylistEvent>
        let playlist: Playlist
    }
}
