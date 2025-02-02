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
    
    func getOfflineAlbums() throws -> [Album] {
        let context = ModelContext(container)
        
        let offlineAlbums = try context.fetch(FetchDescriptor<OfflineAlbum>())
        return offlineAlbums.map(Album.init)
    }
    
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
    
    func isAvailableOffline(_ album: Album) throws -> Bool {
        let context = ModelContext(container)
        let albumId = album.id
        
        return try context.fetch(FetchDescriptor<OfflineAlbum>(predicate: #Predicate{ $0.id == albumId })).first != nil
    }
    
    func deleteOfflineItem(for item: Item) throws {
        let context = ModelContext(container)
        let itemId = item.id
        
        if
            let offlineItem = try context.fetch(FetchDescriptor<OfflineItem>(predicate: #Predicate{ $0.id == itemId })).first,
            let album = offlineItem.album, album.items?.count ?? 0 < 2 {
            
            context.delete(album)
        } else {
            try context.delete(model: OfflineItem.self, where: #Predicate{ $0.id == itemId })
        }
        
        try context.save()
    }
    
    func deleteOfflineAlbum(for album: Album) throws {
        let context = ModelContext(container)
        let albumId = album.id
        
        try context.delete(model: OfflineAlbum.self, where: #Predicate{ $0.id == albumId })
        try context.save()
    }
    
    func createOfflineItem(for item: Item, filename: String) throws -> Item {
        let context = ModelContext(container)
        var offlineAlbum: OfflineAlbum?
        
        if let albumId = item.albumId {
            offlineAlbum = try context.fetch(FetchDescriptor<OfflineAlbum>(predicate: #Predicate{ $0.id == albumId })).first
        }
        
        let offlineItem = OfflineItem(item, filename: filename, album: offlineAlbum)
 
        context.insert(offlineItem)
        try context.save()
        
        return Item(offlineItem)
    }
    
    @discardableResult func createOfflineAlbum(for album: Album) throws -> Album {
        let context = ModelContext(container)
        let offlineAlbum = OfflineAlbum(album)
        
        context.insert(offlineAlbum)
        try context.save()
        
        return Album(offlineAlbum)
    }
}
