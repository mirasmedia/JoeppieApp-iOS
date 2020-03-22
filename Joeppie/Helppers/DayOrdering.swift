//
//  DayOrdering.swift
//  Joeppie
//
//  Created by qa on 22/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import Foundation

extension Array where Element == Baxter {
    func reordered() -> [Baxter] {
        var weekDays = [String]()
        for day in WeekDays.allValues{
            weekDays.append(day.rawValue)
        }
        let defaultOrder = weekDays

        return self.sorted { (a, b) -> Bool in
            if let first = defaultOrder.firstIndex(of: a.dayOfWeek), let second = defaultOrder.firstIndex(of: b.dayOfWeek) {
                return first < second
            }
            return false
        }
    }
}
