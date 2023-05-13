//
//  ContentView.swift
//  IN2CORE
//
//  Created by Lukas Budac on 11/05/2023.
//

import SwiftUI

struct MainView: View {
    
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        NavigationView {
            
            if let error = viewModel.error {
                Text(error)                
                    .foregroundColor(.red)
            } else {
                List {
                    ForEach(viewModel.videos) { video in
                        NavigationLink(video.name) {
                            VideoView(video: video)
                        }
                    }
                }
                .task {
                    if viewModel.videos.isEmpty {
                        await viewModel.loadVideos()
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("main.header")
                .overlay {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .opacity(viewModel.isLoading ? 1 : 0)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
