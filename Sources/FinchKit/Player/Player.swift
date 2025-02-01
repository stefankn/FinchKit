//
//  Player.swift
//  Finch
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation
import Combine
import MediaPlayer
import Factory

@MainActor
@Observable
public final class Player {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    @Injected(\.finchClient) private var finchClient

    private let player = AVQueuePlayer()
    private var assetMapping: Set<Asset> = []
    private var loadQueueTask: Task<Void, Never>?
    private var playbackPositionObservationToken: Any?
    private var subscriptions: Set<AnyCancellable> = []
    
    
    
    // MARK: - Properties

    public private(set) var status: AVPlayer.TimeControlStatus = .waitingToPlayAtSpecifiedRate
    public private(set) var artworkURL: URL?
    
    public private(set) var currentPlaybackPosition: Duration?
    
    public private(set) var queue: Queue? {
        didSet {
            UserDefaults.standard.set(queue, for: .queue)
        }
    }
    
    public var isPlaying: Bool {
        status == .playing
    }
    
    public var isPreviousTrackAvailable: Bool {
        guard let queue else { return false }
        
        return !queue.previousItems.isEmpty || queue.current == queue.context.items.first
    }
    
    public var isNextTrackAvailable: Bool {
        guard let queue else { return false }
        
        return !queue.nextItems.isEmpty
    }
    
    
    
    // MARK: - Construction
    
    public init() {
        player.actionAtItemEnd = .advance
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longFormAudio)
        } catch {
            assertionFailure("Failed to configure `AVAudioSession`: \(error.localizedDescription)")
        }
        
        player
            .publisher(for: \.timeControlStatus)
            .assign(to: \.status, on: self)
            .store(in: &subscriptions)
        
        player
            .publisher(for: \.currentItem)
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.playerItemUpdated($0) }
            .store(in: &subscriptions)
        
        Task {
            for await duration in player.periodicTimes {
                self.currentPlaybackPosition = duration
                
                await storePlaybackPosition()
            }
        }
        
        if let queue = UserDefaults.standard.object(Queue.self, for: .queue) {
            loadQueue(queue, restorePlaybackPosition: true)
        }
    }
    
    
    
    // MARK: - Functions
    
    public func loadContext(_ context: Queue.Context, initialItem: Item, autoplay: Bool = true) {
        clearQueue()
        
        let queue = Queue(context: context, initialItem: initialItem)
        loadQueue(queue, autoplay: autoplay)
    }
    
    public func play() {
        player.play()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func toggle() {
        isPlaying ? pause() : play()
    }
    
    public func play(_ item: Item) {
        guard let queue, queue.context.items.contains(item) else { return }
        
        loadQueueTask?.cancel()
        
        pause()
        player.removeAllItems()
        
        loadQueue(Queue(context: queue.context, initialItem: item), autoplay: true)
    }
    
    public func previous() {
        guard let queue else { return }
        
        if let position = currentPlaybackPosition, position > .seconds(10) || queue.current == queue.context.items.first {
            Task { await seek(to: .zero) }
        } else if let previousItem = queue.previousItems.last {
            play(previousItem)
        }
    }
    
    public func next() {
        player.advanceToNextItem()
        Task { await seek(to: .zero) }
    }
    
    @discardableResult public func seek(to duration: Duration) async -> Bool {
        let isSuccess = await player.seek(to: duration)
        if isSuccess {
            await self.storePlaybackPosition(isExact: true)
        }
        
        return isSuccess
    }
    
    public func seek(to percentage: Double) async -> Bool {
        if let duration = queue?.current.duration {
            return await seek(to: .seconds(percentage * duration.seconds))
        }
        
        return false
    }
    
    public func isPlaying(_ item: Item) -> Bool {
        queue?.current == item
    }
    
    public func isAlbumLoaded(_ album: Album) -> Bool {
        if let queue, case let .album(currentAlbum, _) = queue.context, currentAlbum == album {
            return true
        }
        
        return false
    }
    
    public func clearQueue() {
        guard queue != nil else { return }
        
        loadQueueTask?.cancel()
        player.pause()
        
        queue = nil
        player.removeAllItems()
        artworkURL = nil
    }
    
    
    
    // MARK: - Private Functions
    
    private func loadQueue(_ queue: Queue, restorePlaybackPosition: Bool = false, autoplay: Bool = false) {
        self.queue = queue
        
        if !restorePlaybackPosition {
            UserDefaults.standard.remove(for: .playbackPosition)
        }
        
        loadQueueTask = Task {
            await refreshArtworkURL()
            await load(queue.current)
            
            if restorePlaybackPosition, let playbackPosition = UserDefaults.standard.integer(for: .playbackPosition) {
                await seek(to: Duration.seconds(playbackPosition))
            }
            
            if autoplay {
                play()
            }
            
            for item in queue.nextItems {
                await load(item)
            }
        }
    }
    
    private func playerItemUpdated(_ playerItem: AVPlayerItem?) {
        guard let item = item(for: playerItem) else { return }
        
        queue?.select(item)
    }
    
    private func item(for playerItem: AVPlayerItem?) -> Item? {
        guard let playerItem else { return nil }
        
        return assetMapping.first{ $0.asset == playerItem.asset }?.item
    }
    
    private func load(_ item: Item) async {
        do {
            let streamURL = item.offlineURL != nil ? item.offlineURL : try await finchClient.streamURL(for: item)

            if let streamURL {
                let asset = AVURLAsset(url: streamURL)
                assetMapping.insert(Asset(asset, item: item))
                
                let item = AVPlayerItem(asset: asset)
                
                if player.canInsert(item, after: nil) {
                    player.insert(item, after: nil)
                }
            }
        } catch {
            print(error)
        }
    }
    
    private func refreshArtworkURL() async {
        guard let queue else {
            artworkURL = nil
            return
        }
        
        switch queue.context {
        case .album(let album, _):
            let artworkURL = await finchClient.artworkThumbnailURL(for: album)
            if artworkURL != self.artworkURL {
                self.artworkURL = artworkURL
            }
        }
    }
    
    private func storePlaybackPosition(isExact: Bool = false) async {
        if let currentPlaybackPosition {
            if isExact || Int(currentPlaybackPosition.seconds) % 10 == 0 {
                UserDefaults.standard.set(Int(currentPlaybackPosition.seconds), for: .playbackPosition)
            }
        } else {
            UserDefaults.standard.remove(for: .playbackPosition)
        }
    }
}
