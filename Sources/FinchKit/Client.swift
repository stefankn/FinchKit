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
    func getAlbums(filter: AlbumFilter, sorting: Sorting, limit: Int) async throws -> Pager<Album, AlbumFilter>
    func getNextPage(_ pager: Pager<Album, AlbumFilter>) async throws -> Pager<Album, AlbumFilter>
    func getItems(for album: Album) async throws -> [Item]
    func getEntries(for playlist: Playlist) async throws -> [PlaylistEntry]
    func getSingletons(filter: SingletonFilter?, sorting: Sorting, limit: Int) async throws -> Pager<Item, SingletonFilter>
    func getNextPage(_ pager: Pager<Item, SingletonFilter>) async throws -> Pager<Item, SingletonFilter>
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
