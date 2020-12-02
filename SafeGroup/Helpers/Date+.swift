//
//  Date+.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 01/12/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import Foundation

extension Date {
    func isBetween(startDate:Date, endDate:Date) -> Bool {
         return (startDate.compare(self) == .orderedAscending) && (endDate.compare(self) == .orderedDescending)
    }
}
