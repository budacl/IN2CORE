//
//  VideoViewModel.swift
//  IN2CORE
//
//  Created by Lukas Budac on 11/05/2023.
//

import Foundation
import AVKit
import Combine



@MainActor
class VideoViewModel: ObservableObject {
    
    @Published var video: Video? = nil
    @Published var inOut: Video.InOut? = nil
    @Published var progress: Double = 0 //in %
    
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private var subscriptions: Set<AnyCancellable> = .init()
    
    let pplayer = Player()
    
    init() {
        $inOut
            .dropFirst() //ignore initial value
            .sink { [weak self] inOut in
                guard let self = self, inOut == nil || self.inOut != inOut else { return }
                self.setInOut(inOut)
            }.store(in: &subscriptions)
        
        pplayer.currentProgressPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.progress = progress
            }.store(in: &subscriptions)
    }
    
    
    
    func load(_ video: Video) async  {
        guard self.video == nil else {
            return
        }

        self.video = video
        isLoading = true
        
        do {
            try await pplayer.load(video)
            isLoading = false
            inOut = video.inOuts.first
        } catch {
            self.error = (error as? Player.PlayerError)?.message ?? String(localized: "error.unkown")
            print(error)
        }        
    }
    
    func seekTo(percentage: Double) {
        if let inOut = getClosestInOut(percentage: percentage) {
            self.inOut = inOut
        } else {
            scrub(percentage: percentage)
        }
    }
    
    func scrub(percentage: Double) {
        guard let duration = pplayer.duration else {
            return
        }
        
        let seconds = duration * (percentage/100.0)
        
        guard let inOut = getClosestInOut(percentage: percentage) else {
            let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            pplayer.seekTo(time: time)
            return
        }
        
        let secondsWithinBounds = seconds.inRangeOrEqualTo(
            min: inOut.start*duration,
            max: inOut.end*duration
        )
        
        let percentageWithinBounds = percentage.inRangeOrEqualTo(
            min: inOut.start*100,
            max: inOut.end*100
        )
        
        let time = CMTime(seconds: secondsWithinBounds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        progress = percentageWithinBounds
        
        self.inOut = inOut
        pplayer.seekTo(time: time)
    }

    private func setInOut(_ inOut: Video.InOut?) {
        guard let duration = pplayer.duration else {
            return
        }

        var timeRange: CMTimeRange? = nil
        
        if let inOut = inOut {
            let startSeconds = inOut.start * duration
            let endSeconds = inOut.end * duration
            let delta: Double = 0.00001
            
            guard endSeconds-startSeconds > delta else {
                return
            }

            let startTime = CMTime(seconds: startSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            let endTime = CMTime(seconds: endSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeRange = CMTimeRange(start: startTime, end: endTime)
        }
        
        pplayer.set(timeRange: timeRange)
    }
    
    private func getClosestInOut(percentage: Double) -> Video.InOut? {
        guard let video = video, !video.inOuts.isEmpty else {
            return nil
        }
        let points = video.inOuts.flatMap { [$0.start*100, $0.end*100] }
        let closest = points.enumerated().min(by: { abs($0.1 - percentage) < abs($1.1 - percentage) })!
        let index = closest.offset / 2
        return video.inOuts[index]
    }
    
}
