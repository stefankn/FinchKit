//
//  CreatePlaylist.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 21/02/2025.
//

import Foundation

struct CreatePlaylist: Encodable {
    
    // MARK: - Properties
    
    let name: String
    let description: String?
    let items: [Int]?
}
