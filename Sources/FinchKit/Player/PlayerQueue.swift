//
//  PlayerQueue.swift
//  Finch
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

extension Player {
    public struct Queue: Codable, Sendable {
        
        // MARK: - Types
        
        public enum Context: Codable, Sendable {
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
        public private(set) var context: Context
        
        public var previousItems: [Item] {
            let items = context.items
            if let index = items.firstIndex(where: { $0.id == current.id }) {
                if index > 0 {
                    return Array(items.prefix(upTo: index))
                }
            }
            
            return []
        }
        
        public var nextItems: [Item] {
            let items = context.items
            if let index = items.firstIndex(where: { $0.id == current.id }) {
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
            guard context.items.contains(where: { $0.id == item.id }) else { return }
            
            current = item
        }
        
        public mutating func replace(_ item: Item) {
            guard context.items.contains(where: { $0.id == item.id }), item.id != current.id else { return }
            
            switch context {
            case .album(let album, let items):
                context = .album(album, items: items.map{ $0.id == item.id ? item : $0 })
            }
        }
    }
}
