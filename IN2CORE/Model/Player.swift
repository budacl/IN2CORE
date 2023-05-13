//
//  Player.swift
//  IN2CORE
//
//  Created by Lukas Budac on 13/05/2023.
//

import Foundation
import AVKit
import Combine

class Player {
    
    @Published private(set) var isPlaying = false
    
    private(set) var duration: Double? = nil
    
    private(set) var player = AVQueuePlayer()
    private var playerLooper: NSObject? = nil
    private var playerLayer: AVPlayerLayer? = nil
    private var playerItem: AVPlayerItem? = nil
    
    private var playerPeriodicObserver: Any? = nil
    private var statusCancellable: AnyCancellable? = nil
    
    private var isSeekInProgress = false
    private var chaseTime: CMTime = .zero
    
    var currentTimePublisher: PassthroughSubject<Double, Never> = .init()
    var currentProgressPublisher: PassthroughSubject<Double, Never> = .init()
    
    func load(_ video: Video) async throws {
        guard let url = URL(string: video.url) else {
            throw PlayerError.invalidUrl
        }

        playerItem = AVPlayerItem(url: url)
        player = AVQueuePlayer(items: [playerItem!])
        playerLayer = AVPlayerLayer(player: player)

        return try await withCheckedThrowingContinuation { continuation in
            statusCancellable = playerItem!.publisher(for: \.status)
                .filter { $0 == .readyToPlay }
                .first()
                .sink { [weak self] status in
                    guard let self = self else { return }
                    self.statusCancellable?.cancel()
                    self.statusCancellable = nil
                    self.duration = self.playerItem!.duration.seconds
                    continuation.resume(returning: ())
                }
        }
    }
    
    func play() {
        if !isPlaying {
            player.play()
            isPlaying = true
        }
    }
    
    func pause() {
        if isPlaying {
            player.pause()
            isPlaying = false
        }
    }
    
    func toggle() {
        isPlaying ? pause() : play()
    }
    
    func seekTo(time: CMTime) {
        pause()
        
        if CMTimeCompare(time, chaseTime) != 0 {
            chaseTime = time
            if !isSeekInProgress {
                seekToChaseTime()
            }
        }
    }
    
    func set(timeRange: CMTimeRange?) {
        guard let playerItem = playerItem else {
            return
        }
        
        player.removeAllItems()
        disablePeriodicObservation() //prevent updating progress to 0
        
        if let timeRange = timeRange {
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem, timeRange: timeRange)
        } else {
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        }
        
        enablePeriodicObservation()
    }
    
    private func seekToChaseTime() {
        isSeekInProgress = true
        let seekTimeInProgress = chaseTime
        
        player.seek(to: seekTimeInProgress, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            guard let self = self else { return }
            if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                self.isSeekInProgress = false
            } else {
                self.seekToChaseTime()
            }
        }
    }
    
    private func enablePeriodicObservation() {
        let time = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        playerPeriodicObserver = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] (time) in
            guard let self = self else { return }
            let progress = self.calculateProgress(currentTime: time.seconds)
            self.currentProgressPublisher.send(progress)
            self.currentTimePublisher.send(time.seconds)
        }
    }
    
    private func disablePeriodicObservation() {
        if let observer = playerPeriodicObserver {
            player.removeTimeObserver(observer)
            playerPeriodicObserver = nil
        }
    }
    
    private func calculateProgress(currentTime: Double) -> Double {
        return Double(currentTime / (duration ?? 1)) * 100
    }
}

extension Player {
    
    enum PlayerError: Error {
        case invalidUrl, videoNotSupported
        
        var message: String {
            switch self {
            case .invalidUrl: return String(localized: "error.invalid_url")
            case .videoNotSupported: return String(localized: "error.video_not_supported")
            }
        }
    }
    
}
