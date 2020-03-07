//
//  Baxter.swift
//  Joeppie
//
//  Created by Shahin Mirza on 09/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation

struct Baxter : Codable {

    let id : Int
    let intakeTime : Date
    let patient : NestedPatient
    var doses : [NestedDose]?
    let dayOfWeek : String
    let createdAt : Date
    let updatedAt : Date
    
    enum CodingKeys : String, CodingKey {
        case id
        case intakeTime = "intake_time"
        case patient
        case doses
        case dayOfWeek = "day_of_week"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct NestedBaxter : Codable {
    let id : Int
    let intakeTime : Date
    let patient : Int
    var doses : [Int]?
    let dayOfWeek : String
    let createdAt : Date
    let updatedAt : Date
    
    enum CodingKeys : String, CodingKey {
        case id
        case intakeTime = "intake_time"
        case patient
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case dayOfWeek = "day_of_week"
        case doses
    }
}
