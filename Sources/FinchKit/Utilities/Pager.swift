//
//  Pager.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 09/02/2025.
//

import Foundation

public struct Pager<Element: Decodable, Filter>: Sendable where Element: Sendable, Element: Identifiable, Filter: RawRepresentable, Filter: Sendable, Filter.RawValue == String {
    
    // MARK: - Properties
    
    public let items: [Element]
    public let total: Int
    public let limit: Int
    public let page: Int
    public let filter: Filter?
    public let sorting: Sorting
    
    public var isLastPage: Bool {
        items.count == total
    }
    
    var nextPageParameters: FinchClient.Parameters {
        var parameters = sorting.parameters
        
        if let filter {
            parameters += [
                ("filter", filter.rawValue)
            ]
        }
        
        parameters += [
            ("page", page + 1),
            ("per", limit)
        ]
        
        return parameters
    }
    
    
    
    // MARK: - Construction
    
    public init(items: [Element], total: Int, limit: Int, page: Int, filter: Filter?, sorting: Sorting) {
        self.items = items
        self.total = total
        self.limit = limit
        self.page = page
        self.filter = filter
        self.sorting = sorting
    }
    
    init(items: [Element], metadata: Metadata, filter: Filter?, sorting: Sorting) {
        self.items = items
        
        total = metadata.total
        limit = metadata.per
        page = metadata.page
        
        self.filter = filter
        self.sorting = sorting
    }
    
    
    
    // MARK: - Functions
    
    public func filter(_ isIncluded: (Element) -> Bool) -> Pager<Element, Filter> {
        Pager(items: items.filter(isIncluded), total: total, limit: limit, page: page, filter: filter, sorting: sorting)
    }
    
    public func map(_ transform: (Element) -> Element) -> Pager<Element, Filter> {
        Pager(items: items.map(transform), total: total, limit: limit, page: page, filter: filter, sorting: sorting)
    }
    
    public func isLast(_ item: Element) -> Bool {
        item.id == items.last?.id
    }
    
    func nextPage(items: [Element], metadata: Metadata) -> Pager<Element, Filter> {
        Pager(items: self.items + items, metadata: metadata, filter: filter, sorting: sorting)
    }
}

extension Pager: ExpressibleByArrayLiteral {
    
    // MARK: - Construction
    
    // MARK: ExpressibleByArrayLiteral
    
    public init(arrayLiteral elements: Element...) {
        self.init(items: elements, total: elements.count, limit: elements.count, page: 1, filter: nil, sorting: .added)
    }
}
