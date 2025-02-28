//
//  Pager.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 09/02/2025.
//

import Foundation

public struct Pager<T: Decodable>: Sendable where T: Sendable, T: Identifiable {
    
    // MARK: - Properties
    
    public let items: [T]
    public let total: Int
    public let limit: Int
    public let page: Int
    public let type: AlbumType?
    public let sorting: Sorting
    
    public var isLastPage: Bool {
        items.count == total
    }
    
    var nextPageParameters: FinchClient.Parameters {
        var parameters = sorting.parameters
        
        if let type {
            parameters += [
                ("type", type.rawValue)
            ]
        }
        
        parameters += [
            ("page", page + 1),
            ("per", limit)
        ]
        
        return parameters
    }
    
    
    
    // MARK: - Construction
    
    public init(items: [T], total: Int, limit: Int, page: Int, type: AlbumType?, sorting: Sorting) {
        self.items = items
        self.total = total
        self.limit = limit
        self.page = page
        self.type = type
        self.sorting = sorting
    }
    
    init(items: [T], metadata: Metadata, type: AlbumType?, sorting: Sorting) {
        self.items = items
        
        total = metadata.total
        limit = metadata.per
        page = metadata.page
        
        self.type = type
        self.sorting = sorting
    }
    
    
    
    // MARK: - Functions
    
    public func filter(_ isIncluded: (T) -> Bool) -> Pager<T> {
        Pager(items: items.filter(isIncluded), total: total, limit: limit, page: page, type: type, sorting: sorting)
    }
    
    public func map(_ transform: (T) -> T) -> Pager<T> {
        Pager(items: items.map(transform), total: total, limit: limit, page: page, type: type, sorting: sorting)
    }
    
    public func isLast(_ item: T) -> Bool {
        item.id == items.last?.id
    }
    
    func nextPage(items: [T], metadata: Metadata) -> Pager<T> {
        Pager(items: self.items + items, metadata: metadata, type: type, sorting: sorting)
    }
}

extension Pager: ExpressibleByArrayLiteral {
    
    // MARK: - Construction
    
    // MARK: ExpressibleByArrayLiteral
    
    public init(arrayLiteral elements: T...) {
        self.init(items: elements, total: elements.count, limit: elements.count, page: 1, type: nil, sorting: .added)
    }
}
