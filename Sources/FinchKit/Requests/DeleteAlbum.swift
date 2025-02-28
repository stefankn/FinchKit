//
//  DeleteAlbum.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 28/02/2025.
//

import Foundation

struct DeleteAlbum: Encodable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case deleteFiles = "delete_files"
    }
    
    
    
    // MARK: - Properties
    
    let deleteFiles: Bool
}
