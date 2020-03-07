//
//  Medicine.swift
//  Joeppie
//
//  Created by Ercan kalan on 09/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation


struct Medicine : Codable {
    let id : Int
    let name : String
    let type : String
    let methodOfAdministration : String
    let reason : String
    let createdAt : Date
    let updatedAt : Date
    
    enum CodingKeys : String, CodingKey {
        case id
        case name
        case type
        case methodOfAdministration = "method_of_administration"
        case reason
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
