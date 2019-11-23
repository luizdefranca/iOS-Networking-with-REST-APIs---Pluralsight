//
//  Gist.swift
//  RESThub
//
//  Created by Luiz on 11/23/19.
//  Copyright © 2019 Harrison. All rights reserved.
//

import Foundation

struct Gist: Encodable {

    var id : String
    var isPublic: Bool
    var description: String

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case isPublic = "public"
    }



    func encode(to enconder: Encoder) throws {
        var container = try enconder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(isPublic, forKey: .isPublic)
        try container.encodeIfPresent(description, forKey: .description)
    }
}

extension Gist: Decodable {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: CodingKeys.id)
        self.isPublic = try container.decode(Bool.self, forKey: CodingKeys.isPublic)
        self.description = try container.decodeIfPresent(String.self, forKey: CodingKeys.description) ?? "Description is nil"

    }
}
