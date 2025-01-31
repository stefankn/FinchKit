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
    
    @discardableResult func seek(to duration: Duration) async -> Bool {
        await withCheckedContinuation { continuation in
            let time = CMTime(seconds: duration.seconds, preferredTimescale: 60000)
            
            seek(to: time) { isCompleted in
                continuation.resume(with: .success(isCompleted))
            }
        }
    }
}
