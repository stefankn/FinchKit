//
//  PlayerQueue.swift
//  Finch
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

extension Player {
    public struct Queue: Codable {
        
        // MARK: - Types
        
        public enum Context: Codable {
            case album(Album, items: [Item])
            
            var items: [Item] {
                switch self {
                case .album(_, let items):
                    return items
                }
            }
        }
        
        
        
        // MARK: - Properties
        
        public private(set) var current: Item
        public let context: Context
        
        public var previousItems: [Item] {
            let items = context.items
            if let index = items.firstIndex(of: current) {
                if index > 0 {
                    return Array(items.prefix(upTo: index))
                }
            }
            
            return []
        }
        
        public var nextItems: [Item] {
            let items = context.items
            if let index = items.firstIndex(of: current) {
                if index + 1 < items.count {
                    return Array(items.suffix(from: index + 1))
                }
            }
            
            return []
        }
        
        
        // MARK: - Construction
        
        init(context: Context, initialItem: Item) {
            current = initialItem
            self.context = context
        }
        
        
        
        // MARK: - Functions
        
        public mutating func select(_ item: Item) {
            guard context.items.contains(item) else { return }
            
            current = item
        }
    }
}
