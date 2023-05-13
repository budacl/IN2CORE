//
//  Video.swift
//  IN2CORE
//
//  Created by Lukas Budac on 11/05/2023.
//

import Foundation

struct Video: Decodable, Identifiable {
    
    struct InOut: Equatable {
        let start: Double
        let end: Double
    }
    
    let id: String
    let name: String
    let url: String
    let inOuts: [InOut]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
        case inouts
    }

    init(id: String, name: String, url: String, inouts: [InOut]) {
        self.id = id
        self.name = name
        self.url = url
        self.inOuts = inouts
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        url = try values.decode(String.self, forKey: .url)
        
        inOuts = try values.decode([[Double]].self, forKey: .inouts)
            .filter { $0.count == 2 }
            .map { InOut(start: $0[0], end: $0[1]) }
    }
}
