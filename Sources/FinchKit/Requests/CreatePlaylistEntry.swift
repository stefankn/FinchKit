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
        case itemIds = "item_ids"
    }
    
    
    
    // MARK: - Properties
    
    let itemIds: [Int]
}
