//
//  DayOfWeek.swift
//  Joeppie
//
//  Created by qa on 18/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import Foundation

enum DayOfWeek: String, CaseIterable {
    case MONDAY = "monday"
    case TUESDAY = "tuesday"
    case WEDNESDAY = "wednesday"
    case THURSDAY = "thursday"
    case FRIDAY = "friday"
    case SATURDAY = "saturday"
    case SUNDAY = "sunday"
    
    init?(id: Int){
        switch id {
        case 1: self = .MONDAY
        case 2: self = .TUESDAY
        case 3: self = .WEDNESDAY
        case 4: self = .THURSDAY
        case 5: self = .FRIDAY
        case 6: self = .SATURDAY
        case 7: self = .SUNDAY
        default: return nil
        }
    }
}
