//
//  PlaylistEvent.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 23/02/2025.
//

import Foundation

public enum PlaylistEvent: Sendable {
    case added(PlaylistEntry)
    case removed(PlaylistEntry)
}
