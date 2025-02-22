//
//  CreatePlaylistEntry.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 22/02/2025.
//

import Foundation

struct CreatePlaylistEntry: Encodable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
    }
    
    
    
    // MARK: - Properties
    
    let itemId: Int
}
