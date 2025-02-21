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
            case playlist(Playlist, items: [Item])
            case singleton([Item])
            
            var items: [Item] {
                switch self {
                case .album(_, let items):
                    return items
                case .playlist(_, let items):
                    return items
                case .singleton(let items):
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
        
        public init(context: Context, initialItem: Item) {
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
            case .playlist(let playlist, let items):
                context = .playlist(playlist, items: items.map{ $0.id == item.id ? item : $0 })
            case .singleton(let items):
                context = .singleton(items.map{ $0.id == item.id ? item : $0 })
            }
        }
        
        public mutating func delete(_ item: Item) {
            guard context.items.contains(where: { $0.id == item.id }), item.id != current.id else { return }
            
            switch context {
            case .album(let album, let items):
                context = .album(album, items: items.filter{ $0.id != item.id })
            case .playlist(let playlist, let items):
                context = .playlist(playlist, items: items.filter{ $0.id != item.id })
            case .singleton(let items):
                context = .singleton(items.filter{ $0.id != item.id })
            }
        }
    }
}
