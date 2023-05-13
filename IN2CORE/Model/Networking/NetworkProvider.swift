//
//  NetworkProvider.swift
//  IN2CORE
//
//  Created by Lukas Budac on 11/05/2023.
//

import Foundation

struct NetworkProvider: NetworkProviding {
    
    @Injected(\.apiUrls) var urlProvider: ApiUrlsProviding
    
    func getAllVideos() async throws -> [Video] {
        guard let url = URL(string: urlProvider.apiUrls.allVideos) else {
            throw ApiError.invalidUrl
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Video].self, from: data)
    }
    
}
