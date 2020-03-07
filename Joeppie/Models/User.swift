//
//  User.swift
//  Joeppie
//
//  Created by Shahin Mirza on 08/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//


import Foundation

struct User : Codable {
    let username : String
    let id : Int
    let email : String
    let provider : String
    let confirmed : Bool
    let blocked : Bool
    let role : Role
    let notes : String?
    
    enum CodingKeys : String, CodingKey {
        case username
        case id
        case email
        case provider
        case confirmed
        case blocked
        case role
        case notes
    }
}

struct NestedUser : Codable {
    let username : String
    let id : Int
    let email : String
    let provider : String
    let confirmed : Bool
    let blocked : Bool
    let role : Int
    let notes : String?
    
    enum CodingKeys : String, CodingKey {
        case username
        case id
        case email
        case provider
        case confirmed
        case blocked
        case role
        case notes
    }
}
