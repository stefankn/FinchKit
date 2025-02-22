//
//  Player.swift
//  Finch
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Combine
import MediaPlayer
import Factory
#if os(iOS)
import UIKit
#else
import AppKit
#endif

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
    
    private var isOfflineModeEnabled: Bool {
        UserDefaults.standard.bool(for: .isOfflineModeEnabled)
    }
    
    
    
    // MARK: - Properties

    public private(set) var status: AVPlayer.TimeControlStatus = .waitingToPlayAtSpecifiedRate
    public private(set) var artworkURL: URL?
    
    public private(set) var currentPlaybackPosition: Duration?
    
    public private(set) var queue: Queue? {
        didSet {
            Task { await updateInfoCenter() }
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
    
    public init(_ initialQueue: Queue? = nil) {
        player.actionAtItemEnd = .advance
        
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longFormAudio)
        } catch {
            assertionFailure("Failed to configure `AVAudioSession`: \(error.localizedDescription)")
        }
        #endif
        
        setupRemoteControl()
        
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
        
        if let initialQueue {
            queue = initialQueue
            Task { await refreshArtworkURL() }
        } else if let queue = UserDefaults.standard.object(Queue.self, for: .queue) {
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
        
        Task { await updateInfoCenter() }
    }
    
    public func pause() {
        player.pause()
        
        Task { await updateInfoCenter() }
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
        
        if let position = currentPlaybackPosition, position > .seconds(10) || queue.current.id == queue.context.items.first?.id {
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
        
        await updateInfoCenter()
        
        return isSuccess
    }
    
    public func seek(to percentage: Double) async -> Bool {
        if let duration = queue?.current.duration {
            return await seek(to: .seconds(percentage * duration.seconds))
        }
        
        return false
    }
    
    public func seekBackward(_ duration: Duration) async {
        guard isPlaying, let currentPlaybackPosition else { return }
        
        let updatedDuration = currentPlaybackPosition - duration
        await seek(to: updatedDuration.seconds < 0 ? .zero : updatedDuration)
    }
    
    public func seekForward(_ duration: Duration) async {
        guard isPlaying, let currentPlaybackPosition, let currentDuration = queue?.current.duration else { return }
        
        let updatedDuration = currentPlaybackPosition + duration
        if updatedDuration < currentDuration {
            await seek(to: updatedDuration)
        }
    }
    
    public func isPlaying(_ item: Item, album: Album? = nil, playlist: Playlist? = nil) -> Bool {
        guard let queue else { return false }
        
        switch queue.context {
        case .album(let currentAlbum, _):
            return album?.id == currentAlbum.id && queue.current.id == item.id
        case .playlist(let currentPlaylist, _):
            return playlist?.id == currentPlaylist.id && queue.current.entryId == item.entryId
        case .singleton:
            return album == nil && playlist == nil && queue.current.id == item.id
        }
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
        assetMapping.removeAll()
        artworkURL = nil
    }
    
    public func updateQueue(for item: Item) {
        guard let queue else { return }
        
        self.queue?.replace(item)
        
        // If the updated item is in the queue, update the player items
        switch queue.context {
        case .album, .singleton:
            guard queue.nextItems.contains(where: { $0.id == item.id }) else { return }
        case .playlist:
            guard queue.nextItems.contains(where: { $0.entryId == item.entryId }) else { return }
        }
        
        updatePlayerItems()
    }
    
    public func delete(_ entry: PlaylistEntry) {
        guard let queue, case .playlist = queue.context else { return }
        
        let isScheduled = queue.nextItems.contains(where: { $0.id == entry.item.id })
        self.queue?.delete(entry)
        
        if isScheduled {
            updatePlayerItems()
        }
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
            
            await loadNextItems()
        }
    }
    
    private func loadNextItems() async {
        guard let queue else { return }
        
        for item in queue.nextItems where !Task.isCancelled {
            await load(item)
        }
    }
    
    private func playerItemUpdated(_ playerItem: AVPlayerItem?) {
        guard let item = item(for: playerItem) else { return }
        
        print("item update, url: \((playerItem?.asset as? AVURLAsset)?.url)")
        
        queue?.select(item)
    }
    
    private func item(for playerItem: AVPlayerItem?) -> Item? {
        guard let playerItem else { return nil }
        
        return assetMapping.first{ $0.asset == playerItem.asset }?.item
    }
    
    private func load(_ item: Item) async {
        do {
            var streamURL = item.offlineURL
            
            if streamURL == nil && !isOfflineModeEnabled {
                streamURL = try await finchClient.streamURL(for: item)
            }

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
        case .singleton, .playlist:
            self.artworkURL = nil
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
    
    private func updatePlayerItems() {
        guard let queue else { return }
        
        loadQueueTask?.cancel()
        
        for nextItem in queue.nextItems {
            if let asset = assetMapping.first(where: { $0.item.id == nextItem.id }) {
                assetMapping.remove(asset)
                
                if let playerItem = player.items().first(where: { $0.asset == asset.asset }) {
                    player.remove(playerItem)
                }
            }
        }
        
        loadQueueTask = Task {
            await loadNextItems()
        }
    }
    
    private func updateInfoCenter() async {
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = queue?.previousItems.isEmpty == false
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = queue?.nextItems.isEmpty == false
        
        guard let queue else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        
        if let artworkURL {
            let request = URLRequest(url: artworkURL, cachePolicy: .returnCacheDataElseLoad)
            if let response = URLSession.shared.configuration.urlCache?.cachedResponse(for: request) {
                setInfoCenterData(queue.current, imageData: response.data)
            } else {
                do {
                    let (data, _) = try await URLSession.shared.data(for: request)
                    setInfoCenterData(queue.current, imageData: data)
                } catch {
                    print(error)
                }
            }
        } else {
            setInfoCenterData(queue.current)
        }
    }
    
    private func setInfoCenterData(_ item: Item, imageData: Data? = nil) {
        guard let queue else { return }
        
        var info: [String: Any] = [
            MPMediaItemPropertyArtist: item.artists,
            MPMediaItemPropertyTitle: item.title,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player.currentItem?.currentTime().seconds ?? 0,
            MPMediaItemPropertyPlaybackDuration: item.duration.seconds,
            MPNowPlayingInfoPropertyPlaybackRate: player.rate
        ]
        
        switch queue.context {
        case .album(let album, _):
            info[MPMediaItemPropertyAlbumTitle] = album.title
        case .singleton, .playlist:
            info[MPMediaItemPropertyAlbumTitle] = nil
        }
        
        #if os(iOS)
        if let imageData, let image = UIImage(data: imageData) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { @Sendable _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }
        #else
        if let imageData, let image = NSImage(data: imageData) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { @Sendable _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }
        #endif
        
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func setupRemoteControl() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { _ in
            self.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { _ in
            self.pause()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                Task { await self.seek(to: .seconds(event.positionTime)) }
            }
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { event in
            self.previous()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { event in
            self.next()
            return .success
        }
    }
}
