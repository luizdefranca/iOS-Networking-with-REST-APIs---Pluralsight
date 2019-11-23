//
//  Gist.swift
//  RESThub
//
//  Created by Luiz on 11/23/19.
//  Copyright © 2019 Harrison. All rights reserved.
//

import Foundation

struct Gist: Codable {

    var id : String
    var isPublic: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case isPublic = "public"
    }
    
}
