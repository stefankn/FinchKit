//
//  PlayerAsset.swift
//  Finch
//
//  Created by Stefan Klein Nulent on 31/01/2025.
//

import Foundation
import AVFoundation

extension Player {
    struct Asset: Hashable {
        
        // MARK: - Properties
        
        let asset: AVAsset
        let item: Item
        
        
        
        // MARK: - Construction
        
        init(_ asset: AVAsset, item: Item) {
            self.asset = asset
            self.item = item
        }
        
        
        
        // MARK: - Functions
        
        // MARK: Hashable Functions
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(asset)
        }
    }
}
