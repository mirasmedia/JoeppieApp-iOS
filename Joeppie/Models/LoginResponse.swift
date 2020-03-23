//
//  loginResponse.swift
//  Joeppie
//
//  Created by Shahin Mirza on 20/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation

struct LoginResponse : Codable {
    let token : String
    let user : User
    
    enum CodingKeys : String, CodingKey {
        case token = "jwt"
        case user
    }
}
