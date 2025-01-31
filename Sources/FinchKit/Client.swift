//
//  Client.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

public protocol Client: Actor {
    
    // MARK: - Properties
    
    var url: URL? { get }
    
    
    // MARK: - Functions
    
    func connect(to url: URL) async throws
    func getAlbums() async throws -> [Album]
    func getItems(for album: Album) async throws -> [Item]
    func artworkURL(for album: Album) -> URL?
    func artworkThumbnailURL(for album: Album) -> URL?
    func streamURL(for item: Item) throws -> URL
    func getStats() async throws -> Stats
}
