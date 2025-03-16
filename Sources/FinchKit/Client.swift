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
    func getAlbums(type: AlbumType, sorting: Sorting, limit: Int) async throws -> Pager<Album>
    func getNextPage(_ pager: Pager<Album>) async throws -> Pager<Album>
    func getItems(for album: Album) async throws -> [Item]
    func getEntries(for playlist: Playlist) async throws -> [PlaylistEntry]
    func getSingletons(type: AlbumType?, sorting: Sorting, limit: Int) async throws -> Pager<Item>
    func getNextPage(_ pager: Pager<Item>) async throws -> Pager<Item>
    func path(for album: Album) async throws -> String
    func delete(_ album: Album, deleteFiles: Bool) async throws
    func artworkURL(for album: Album) -> URL?
    func artworkThumbnailURL(for album: Album) -> URL?
    func streamURL(for item: Item) throws -> URL
    func getStats() async throws -> Stats
    func getPlaylists() async throws -> [Playlist]
    func createPlaylist(name: String, description: String?, items: [Item]?) async throws -> Playlist
    func delete(_ playlist: Playlist) async throws
    func add(_ item: Item, to playlist: Playlist) async throws -> PlaylistEntry
    func delete(_ entry: PlaylistEntry, from playlist: Playlist) async throws
    func update(_ item: Item, artist: String, artists: String, title: String) async throws -> Item
    func update(_ album: Album, artist: String, title: String, artworkPath: String?) async throws -> Album
    func delete(_ item: Item) async throws
}
