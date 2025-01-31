//
//  AlbumType.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

extension Album {
    public enum AlbumType: String, Codable, Sendable {
        case album
        case compilation
        case djmix = "dj-mix"
    }
}
