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
    func getAlbums(sorting: Sorting, limit: Int) async throws -> Pager<Album>
    func getNextPage(_ pager: Pager<Album>) async throws -> Pager<Album>
    func getItems(for album: Album) async throws -> [Item]
    func getSingletons(sorting: Sorting, limit: Int) async throws -> Pager<Item>
    func getNextPage(_ pager: Pager<Item>) async throws -> Pager<Item>
    func artworkURL(for album: Album) -> URL?
    func artworkThumbnailURL(for album: Album) -> URL?
    func streamURL(for item: Item) throws -> URL
    func getStats() async throws -> Stats
}
