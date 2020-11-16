//
//  EventAlert.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 12/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import Foundation

class EventAlert {
    var id: Int
    var timestamp: Date
    var lastUserLocalation: Location?
    var lastUserDistanceMeters: Int?
    
    init(id: Int, timestamp: Date, lastUserLocalation: Location?, lastUserDistanceMeters: Int?) {
        self.id = id
        self.timestamp = timestamp
        self.lastUserLocalation = lastUserLocalation
        self.lastUserDistanceMeters = lastUserDistanceMeters
    }
}
