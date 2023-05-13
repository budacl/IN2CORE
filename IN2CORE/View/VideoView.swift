//
//  VideoView.swift
//  IN2CORE
//
//  Created by Lukas Budac on 11/05/2023.
//

import SwiftUI
import AVKit
import UIKit

struct VideoView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = VideoViewModel()
    let video: Video
    
    var body: some View {
        VStack {
            videoPlayer
            playButton
            slider
            
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
            
            Text(viewModel.error ?? "")
                .foregroundColor(.red)
            
            Spacer()
        }
        .navigationTitle(viewModel.video?.name ?? "")
    }
    
}

extension VideoView {
    
    private var videoPlayer: some View {
        VideoPlayer(player: viewModel.pplayer.player)
            .disabled(true)
            .onAppear() {
                Task {
                    await viewModel.load(video)                    
                }
            }
            .onDisappear {
                viewModel.pplayer.pause()
            }
    }
    
    private var playButton: some View {
        Button(action: {
            viewModel.pplayer.toggle()
        }) {
            Image(viewModel.pplayer.isPlaying ? "ic_pause" : "ic_play")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(width: 48, height: 48)
        }
        .frame(width: 64, height: 64)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 2)
        )
        .cornerRadius(8)
        .padding(16)
        .interactive(isLoading: viewModel.isLoading, error: viewModel.error)
    }
    
    private var slider: some View {
        SliderView(viewModel: viewModel)
            .frame(height: 48)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 40)
            .interactive(isLoading: viewModel.isLoading, error: viewModel.error)
    }
    
}

struct VideoView_Previews: PreviewProvider {
    
    static var previews: some View {
        VideoView(
            video: Video(
                id: "0",
                name: "Video",
                url: "",
                inouts: [
                    Video.InOut(start: 0, end: 0.1),
                    Video.InOut(start: 0.2, end: 0.3)
                ]
            )
        )
    }
}

