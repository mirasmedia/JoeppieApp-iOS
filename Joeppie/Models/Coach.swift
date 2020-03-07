//
//  Coach.swift
//  Joeppie
//
//  Created by Shahin Mirza on 08/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation

struct Coach : Codable {
    let id : Int
    let user : NestedUser
    
    enum CodingKeys : String, CodingKey {
        case id
        case user
    }
}
