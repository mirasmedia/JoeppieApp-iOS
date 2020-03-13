//
//  Intake.swift
//  Joeppie
//
//  Created by Shahin Mirza on 20/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation

struct Intake : Codable {
    let id : Int
    let medicine : Medicine
    let patient : NestedPatient
    let timeTakenIn : Date
    let state : String
    let createdAt : Date
    let updatedAt : Date
    
    enum CodingKeys : String, CodingKey {
        case id
        case medicine
        case patient
        case timeTakenIn = "time_taken_in"
        case state
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
