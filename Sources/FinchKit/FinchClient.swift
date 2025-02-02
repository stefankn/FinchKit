//
//  FinchClient.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

public actor FinchClient: Client {
    
    // MARK: - Types
    
    typealias Parameters = [(name: String, value: CustomStringConvertible)]
    
    
    // MARK: - Private Properties
    
    private let store: Store
    
    
    
    // MARK: - Properties
    
    // MARK: Client Properties
    
    public private(set) var url: URL? {
        didSet {
            if let url {
                UserDefaults.standard.set(url.absoluteString, for: .host)
            } else {
                UserDefaults.standard.remove(for: .host)
            }
        }
    }
    
    
    // MARK: - Construction
    
    public init(store: Store) {
        self.store = store
        
        guard let host = UserDefaults.standard.string(for: .host), let url = URL(string: host) else { return }
        
        self.url = url
    }
    
    
    
    // MARK: - Functions
    
    public func connect(to url: URL) async throws {
        do {
            self.url = url
            let _: Stats = try await get("/api/v1/stats", waitsForConnectivity: true)
        } catch {
            self.url = nil
            throw error
        }
    }
    
    public func getAlbums() async throws -> [Album] {
        let albums: [AlbumResponse] = try await get("/api/v1/albums")
        
        let offlineAlbums = try await store.getOfflineAlbums()
        return albums.map(Album.init).map{ album in offlineAlbums.first{ $0.id == album.id } ?? album }
    }
    
    public func getItems(for album: Album) async throws -> [Item] {
        let items: [ItemResponse] = try await get("/api/v1/albums/\(album.id)/items")
        
        let offlineItems = try await store.items(for: album)
        return items.map(Item.init).map{ item in offlineItems.first{ $0.id == item.id } ?? item }.sorted()
    }
    
    @discardableResult public func getStats() async throws -> Stats {
        try await get("/api/v1/stats")
    }
    
    public func artworkURL(for album: Album) -> URL? {
        guard album.isArtworkAvailable else { return nil }
        
        return try? url(for: "/api/v1/albums/\(album.id)/artwork")
    }
    
    public func artworkThumbnailURL(for album: Album) -> URL? {
        guard album.isArtworkAvailable else { return nil }
        
        return try? url(for: "/api/v1/albums/\(album.id)/artwork/thumbnail")
    }
    
    public func streamURL(for item: Item) throws -> URL {
        try url(for: "/api/v1/items/\(item.id)/stream")
    }
    
    
    
    // MARK: - Private Functions
    
    private func get<Response: Decodable>(_ path: String, parameters: Parameters? = nil, waitsForConnectivity: Bool = false) async throws -> Response {
        try await request(URLRequest(.get, url: url(for: path, parameters: parameters)), waitsForConnectivity: waitsForConnectivity)
    }
    
    private func post<Body: Encodable, Response: Decodable>(_ path: String, parameters: Parameters? = nil, body: Body) async throws -> Response {
        try await request(URLRequest(.post, url: url(for: path, parameters: parameters)), body: body)
    }
    
    private func post<Body: Encodable>(_ path: String, parameters: Parameters? = nil, body: Body) async throws {
        try await request(URLRequest(.post, url: url(for: path, parameters: parameters)), body: body)
    }
    
    private func post(_ path: String, parameters: Parameters? = nil) async throws {
        try await request(URLRequest(.post, url: url(for: path, parameters: parameters)))
    }
    
    private func delete<Body: Encodable>(_ path: String, parameters: Parameters? = nil, body: Body) async throws {
        try await request(URLRequest(.delete, url: url(for: path, parameters: parameters)), body: body)
    }
    
    private func delete(_ path: String, parameters: Parameters? = nil) async throws {
        try await request(URLRequest(.delete, url: url(for: path, parameters: parameters)))
    }
    
    func request<Body: Encodable, Response: Decodable>(_ request: URLRequest, body: Body, waitsForConnectivity: Bool = false) async throws -> Response {
        var request = request
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await self.request(request, waitsForConnectivity: waitsForConnectivity)
    }
    
    private func request<Body: Encodable>(_ request: URLRequest, parameters: Parameters? = nil, body: Body, waitsForConnectivity: Bool = false) async throws {
        var request = request
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        try await self.request(request, waitsForConnectivity: waitsForConnectivity)
    }
    
    func request<Response: Decodable>(_ request: URLRequest, waitsForConnectivity: Bool = false) async throws -> Response {
        let (data, _) = try await self.request(request, waitsForConnectivity: waitsForConnectivity)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Response.self, from: data)
    }
    
    @discardableResult private func request(_ request: URLRequest, waitsForConnectivity: Bool = false) async throws -> (Data, URLResponse) {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = waitsForConnectivity
        let session = URLSession(configuration: configuration)
        
        do {
            let (data, response) = try await session.data(for: request)

            if let response = response as? HTTPURLResponse, !response.status.isSuccess {
                let message = String(data: data, encoding: .utf8)
                
                switch response.status {
                case .badRequest:
                    throw APIError.badRequest(message)
                case .notFound:
                    throw APIError.notFound
                default:
                    throw APIError.failure(response.status, data)
                }
            }
            
            return (data, response)
        } catch {
            throw error
        }
    }
    
    private func url(for path: String, parameters: Parameters? = nil) throws -> URL {
        if let baseURL = self.url, let url = URL(string: path, relativeTo: baseURL) {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            if let parameters {
                let queryItems = (components?.queryItems ?? []) + parameters.map{ URLQueryItem(name: $0.name, value: $0.value.description) }
                components?.queryItems = queryItems
            }
            
            if let url = components?.url {
                return url
            } else {
                throw URLError(.badURL)
            }
        } else {
            throw URLError(.badURL)
        }
    }
}
