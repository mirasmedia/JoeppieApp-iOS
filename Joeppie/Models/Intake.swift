//
//  Intake.swift
//  Joeppie
//
//  Created by Mark van den Berg on 20/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation

struct Intake : Codable {
    let id : Int
    let medicine : Medicine
    let patient : Patient
    let timeTakenIn : Date
    let state : String
    
    enum CodingKeys : String, CodingKey {
        case id
        case medicine
        case patient
        case timeTakenIn = "time_taken_in"
        case state
    }
}
