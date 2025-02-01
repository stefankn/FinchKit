//
//  Store.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 31/01/2025.
//

import Foundation
import SwiftData

public actor Store {
    
    // MARK: - Properties
    
    public let container: ModelContainer
    
    
    
    // MARK: - Construction
    
    public init(inMemory: Bool = false) {
        let configuration = ModelConfiguration(for: OfflineItem.self)
        
        do {
            container = try ModelContainer(for: OfflineItem.self, configurations: configuration)
            
            print(container.configurations.first?.url)
        } catch {
            fatalError("Failed to create container, \(error)")
        }
    }
    
    
    
    // MARK: - Functions
    
    func items(for album: Album) throws -> [Item] {
        let context = ModelContext(container)
        let albumId = album.id
        
        let offlineItems = try context.fetch(FetchDescriptor<OfflineItem>(predicate: #Predicate{ $0.albumId == albumId }))
        return offlineItems.map(Item.init)
    }
    
    func isAvailableOffline(_ item: Item) throws -> Bool {
        let context = ModelContext(container)
        let itemId = item.id
        
        return try context.fetch(FetchDescriptor<OfflineItem>(predicate: #Predicate{ $0.id == itemId })).first != nil
    }
    
    func createOfflineItem(for item: Item, filename: String) throws -> Item {
        let context = ModelContext(container)
        let offlineItem = OfflineItem(item, filename: filename)
        
        context.insert(offlineItem)
        try context.save()
        
        return Item(offlineItem)
    }
}
