//
//  ClientMock.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

public final actor ClientMock: Client {
    
    // MARK: - Properties
    
    // MARK: Client Properties
    
    public var url: URL? = nil
    
    
    
    // MARK: - Construction
    
    public init() {}
    
    
    
    // MARK: - Functions
    
    // MARK: Client Functions
    
    public func connect(to url: URL) async throws {
        
    }
    
    public func getAlbums() async throws -> [Album] {
        []
    }
    
    public func getItems(for album: Album) async throws -> [Item] {
        []
    }
    
    public func artworkURL(for album: Album) -> URL? {
        nil
    }
    
    public func artworkThumbnailURL(for album: Album) -> URL? {
        nil
    }
    
    public func getStats() async throws -> Stats {
        Stats(trackCount: 5, totalTime: "1 hour", approximateTotalSize: "1 GB", artistCount: 2, albumCount: 2, albumArtistCount: 2)
    }
    
    public func streamURL(for item: Item) throws -> URL {
        URL(string: "http://test.local")!
    }
}
