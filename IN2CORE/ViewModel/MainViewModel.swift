//
//  MainViewMdoel.swift
//  IN2CORE
//
//  Created by Lukas Budac on 11/05/2023.
//

import Foundation

@MainActor
class MainViewModel: ObservableObject {
    
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    
    @Injected(\.network) var networkProvider: NetworkProviding
    
    func loadVideos() async {
        guard !isLoading else { return }
        isLoading = true
        do {
            videos = try await networkProvider.getAllVideos()
            isLoading = false
        } catch {
            print(error)
            self.error = String(localized: "error.load_videos")
        }
    }
    
}
