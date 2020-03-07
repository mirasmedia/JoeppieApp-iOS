//
//  Role.swift
//  Joeppie
//
//  Created by Shahin Mirza on 20/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation

struct Role : Codable {
    let id : Int
    let name : String
    let description : String
    let type : String
    
    enum CodingKeys : String, CodingKey {
        case id
        case name
        case description
        case type
    }
}
