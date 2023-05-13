//
//  NetworkProviding.swift
//  IN2CORE
//
//  Created by Lukas Budac on 11/05/2023.
//

import Foundation

protocol NetworkProviding {
    
    func getAllVideos() async throws -> [Video]
    
}
