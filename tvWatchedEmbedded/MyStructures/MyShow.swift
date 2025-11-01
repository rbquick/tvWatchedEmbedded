//
//  MyShow.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-30.
//

import Foundation

struct MyShow: Codable, Equatable, Hashable, Identifiable {
    let id: Int
    let name: String
    let episodes: [MyEpisode]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, episodes
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.episodes = try container.decode([MyEpisode].self, forKey: .episodes)
    }
    // Encoding method to conform to Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(episodes, forKey: .episodes)
    }
    init(id: Int = 1, name: String = "New", episodes: [MyEpisode]? = nil) {
        self.id = id
        self.name = name
        self.episodes = episodes
    }
    static func == (lhs: MyShow, rhs: MyShow) -> Bool {
            lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.episodes == rhs.episodes
        }
    }

