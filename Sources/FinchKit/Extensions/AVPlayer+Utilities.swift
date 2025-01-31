//
//  AVPlayer+Utilities.swift
//  Finch
//
//  Created by Stefan Klein Nulent on 31/01/2025.
//

import Foundation
import AVFoundation

extension AVPlayer {
    
    // MARK: - Properties
    
    var periodicTimes: AsyncStream<Duration> {
        AsyncStream { continuation in
            addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 10), queue: .main) { time in
                continuation.yield(with: .success(Duration.seconds(time.seconds)))
            }
        }
    }
    
    
    
    // MARK: - Functions
    
    func seek(to duration: Duration, completion: (@Sendable (Bool) -> Void)? = nil) {
        let time = CMTime(seconds: duration.seconds, preferredTimescale: 60000)
        
        if let completion {
            seek(to: time, completionHandler: completion)
        } else {
            seek(to: time)
        }
    }
}
