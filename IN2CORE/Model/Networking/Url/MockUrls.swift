//
//  ProductionUrls.swift
//  IN2CORE
//
//  Created by Lukas Budac on 11/05/2023.
//

import Foundation

struct MockUrls: ApiUrls {
    
    private static let base: String = "https://private-eafb4-in2core.apiary-mock.com/"
    
    let allVideos: String = base + "videos"
    
}
