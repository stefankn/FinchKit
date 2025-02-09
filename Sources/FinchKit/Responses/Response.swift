//
//  Response.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 09/02/2025.
//

import Foundation

struct Response<T: Decodable>: Decodable {
    
    // MARK: - Properties
    
    let metadata: Metadata
    let items: [T]
}

struct Metadata: Decodable {
    let page: Int
    let total: Int
    let per: Int
}
