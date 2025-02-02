//
//  UserDefaultsKey+Registration.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

extension UserDefaults.Key {
    
    // MARK: - Constants
    
    static let host: UserDefaults.Key = "host"
    static let queue: UserDefaults.Key = "queue"
    static let playbackPosition: UserDefaults.Key = "playbackPosition"
    
    public static let isOfflineModeEnabled: UserDefaults.Key = "isOfflineModeEnabled"
}
