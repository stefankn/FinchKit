//
//  URL+Paths.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 31/01/2025.
//

import Foundation

extension URL {
    
    // MARK: - Properties
    
    static var documentsPath: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    static var offlineItemsPath: URL? {
        documentsPath?.appendingPathComponent("OfflineItems")
    }
}
