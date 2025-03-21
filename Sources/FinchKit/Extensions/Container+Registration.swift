//
//  Container+Registration.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 31/01/2025.
//

import Foundation
import Factory

public extension Container {
    
    // MARK: - Properties
    
    var finchClient: Factory<Client> {
        Factory(self) { FinchClient(store: self.store()) }.singleton
    }
    
    var store: Factory<Store> {
        Factory(self) { Store() }
    }
    
    var playlistEventCenter: Factory<PlaylistEventCenter> {
        Factory(self) { PlaylistEventCenter() }.singleton
    }
}
