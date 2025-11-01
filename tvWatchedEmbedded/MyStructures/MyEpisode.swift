//
//  MyEpisodes.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-30.
//

import Foundation

struct MyEpisode: Codable, Equatable, Hashable, Identifiable {
    let id: Int
    let dateWatched: String?
    
    enum CodingKeys: String, CodingKey {
        case id, dateWatched
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.dateWatched = try container.decodeIfPresent(String.self, forKey: .dateWatched)
    }
    // Encoding method to satisfy Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(dateWatched, forKey: .dateWatched)
    }
    init (id: Int = 0, dateWatched: String? = nil) {
        self.id = id
        self.dateWatched = dateWatched
    }
    static func == (lhs: MyEpisode, rhs: MyEpisode) -> Bool {
            lhs.id == rhs.id &&
            lhs.dateWatched == rhs.dateWatched
    }
}


