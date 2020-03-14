//
//  NewUser.swift
//  Joeppie
//
//  Created by qa on 13/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import Foundation

// MARK: - NewUser
struct NewUser: Codable {
    let jwt: String
    let user: AddedUser
}

// MARK: - User
struct AddedUser: Codable {
    let username, email, provider: String
    let role: Int
    let confirmed: Bool
    let id: Int
}
