//
//  AlbumType.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

public enum AlbumType: String, Codable, Sendable {
    case album
    case compilation
    case djmix = "dj-mix"
    case live
    case ep
    case soundtrack
    case single
}
