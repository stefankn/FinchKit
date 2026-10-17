//
//  RemovePlaylistEntries.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 10/10/2026.
//

import Foundation

struct RemovePlaylistEntries: Encodable {

    // MARK: - Types

    enum CodingKeys: String, CodingKey {
        case entryIds = "entry_ids"
    }



    // MARK: - Properties

    let entryIds: [Int]
}
