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
    
    private var tasks: [Item: Task<Void, Never>] = [:]
    private var progressObservationTasks: [Item: Task<Void, Never>] = [:]
    private var initiatedDownloads: [URL: Item] = [:]
    
    
    
    // MARK: - Properties
    
    public private(set) var downloadsInProgress: [Item: Double] = [:]
    
    
    
    // MARK: - Functions
    
    public func isAvailableOffline(_ item: Item) async -> Bool {
        (try? await store.isAvailableOffline(item)) == true
    }
    
    public func download(_ item: Item) async throws -> Item {
        guard !isDownloading(item), try await !store.isAvailableOffline(item), let offlineItemsPath = URL.offlineItemsPath else { return item }
        
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
        
        return try await store.createOfflineItem(for: item, filename: filename)
    }
    
    public func isDownloading(_ item: Item) -> Bool {
        tasks.keys.contains(item)
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
