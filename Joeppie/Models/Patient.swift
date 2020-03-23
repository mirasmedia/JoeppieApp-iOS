//
//  Patient.swift
//  Joeppie
//
//  Created by Shahin Mirza on 08/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation

struct Patient : Codable {
    let id : Int
    var user : NestedUser
    let createdAt : Date
    let updatedAt : Date
    let firstName : String
    let insertion : String?
    let lastName : String
    let coachId : Int
    let dateOfBirth : Date
    
    enum CodingKeys : String, CodingKey {
        case id
        case user
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case firstName = "first_name"
        case insertion
        case lastName = "last_name"
        case coachId = "coach_id"
        case dateOfBirth = "date_of_birth"
    }
}

struct NestedPatient : Codable {
    let id : Int
    let user : Int
    let createdAt : Date
    let updatedAt : Date
    let firstName : String
    let insertion : String?
    let lastName : String
    let coachId : Int
    let dateOfBirth : Date
    
    enum CodingKeys : String, CodingKey {
        case id
        case user
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case firstName = "first_name"
        case insertion
        case lastName = "last_name"
        case coachId = "coach_id"
        case dateOfBirth = "date_of_birth"
    }
}
