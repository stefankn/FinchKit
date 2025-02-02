//
//  FileDownloader.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 31/01/2025.
//

import Foundation
import Factory

@MainActor
@Observable
public class FileDownloader: NSObject, URLSessionTaskDelegate {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    @Injected(\.finchClient) private var finchClient
    
    @ObservationIgnored
    @Injected(\.store) private var store
    
    private var tasks: [Item: Task<Item, any Error>] = [:]
    private var taskGroups: [Album: ThrowingTaskGroup<Item, any Error>] = [:]
    private var progressObservationTasks: [Item: Task<Void, Never>] = [:]
    private var initiatedDownloads: [URL: Item] = [:]
    
    
    
    // MARK: - Properties
    
    public private(set) var downloadsInProgress: [Item: Double] = [:]
    
    
    
    // MARK: - Functions
    
    public func isAvailableOffline(_ item: Item) async -> Bool {
        (try? await store.isAvailableOffline(item)) == true
    }
    
    public func download(_ items: [Item], from album: Album) async throws -> [Item] {
        do {
            let items = try await withThrowingTaskGroup(of: Item.self, returning: [Item].self) { taskGroup in
                taskGroups[album] = taskGroup
                
                items.forEach{ item in taskGroup.addTask{ try await self.download(item) } }
                
                var updatedItems: [Item] = []
                for try await result in taskGroup {
                    updatedItems.append(result)
                }
                
                return updatedItems
            }
            
            taskGroups.removeValue(forKey: album)
            
            return items.sorted()
        } catch {
            taskGroups.removeValue(forKey: album)
            throw error
        }
    }
    
    public func download(_ item: Item) async throws -> Item {
        guard !isDownloading(item), try await !store.isAvailableOffline(item), let offlineItemsPath = URL.offlineItemsPath else { return item }
        
        let task = Task {
            let filename = "\(item.id).\(item.format.lowercased())"
            let localURL = offlineItemsPath.appendingPathComponent(filename)
            
            downloadsInProgress[item] = 0
            
            let url = try await finchClient.streamURL(for: item)
            initiatedDownloads[url] = item
            
            let (tempURL, _) = try await URLSession.shared.download(from: url, delegate: self)
            cancelProgressObservation(for: item)

            let fileManager = FileManager.default
            try fileManager.createDirectory(atPath: localURL.path, withIntermediateDirectories: true)
            
            if fileManager.fileExists(atPath: localURL.path()) {
                try fileManager.removeItem(at: localURL)
            }
            
            try fileManager.copyItem(at: tempURL, to: localURL)
            try fileManager.removeItem(at: tempURL)
            
            downloadsInProgress.removeValue(forKey: item)
            
            return try await store.createOfflineItem(for: item, filename: filename)
        }
        
        tasks[item] = task
        
        do {
            let updatedItem = try await task.value
            tasks.removeValue(forKey: item)
            
            return updatedItem
        } catch {
            tasks.removeValue(forKey: item)
            throw error
        }
    }
    
    public func isDownloading(_ item: Item) -> Bool {
        tasks.keys.contains(item)
    }
    
    public func deleteDownload(for item: Item) async throws -> Item {
        tasks[item]?.cancel()
        
        try await store.deleteOfflineItem(for: item)
        
        if let offlineURL = item.offlineURL {
            try FileManager.default.removeItem(at: offlineURL)
        }
        
        var item = item
        item.fileRemoved()
        
        return item
    }
    
    public func deleteDownload(for album: Album, items: [Item]) async throws -> [Item] {
        taskGroups[album]?.cancelAll()
        
        return try await items.asyncMap{ try await deleteDownload(for: $0) }.sorted()
    }
    
    
    // MARK: URLSessionsTaskDelegate Functions
    
    nonisolated public func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        guard let url = task.originalRequest?.url else { return }
        
        Task {
            guard let item = await initiatedDownloads[url] else { return }
            await MainActor.run { _ = initiatedDownloads.removeValue(forKey: url) }
            
            let progressTask = Task {
                for await progress in task.progressStream {
                    await MainActor.run {
                        self.downloadsInProgress[item] = progress
                    }
                }
            }
            
            await MainActor.run { progressObservationTasks[item] = progressTask }
        }
    }
    
    
    
    // MARK: - Private Functions
    
    private func cancelProgressObservation(for item: Item) {
        progressObservationTasks[item]?.cancel()
        progressObservationTasks.removeValue(forKey: item)
    }
}
