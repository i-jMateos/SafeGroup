//
//  EventAlert.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 12/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import Foundation

enum EventAlertType: String, Codable {
    case lost
    case needABreak
    
    var message: String {
        switch self {
        case .lost:
            return "Me he perdido"
        case .needABreak:
            return "Necesito un descanso urgente"
        }
    }
    
    var title: String {
        switch self {
        case .lost:
            return "Me he perdido"
        case .needABreak:
            return "Necesito un descanso urgente"
        }
    }
}

struct EventAlert: Codable {
    var id: String
    var timestamp: Date
    var message: String?
    var lastUserLocalation: Location?
    var lastUserDistanceMeters: Int?
    var event: Event
    var user: User?
    var type: EventAlertType
    
    init(id: String, timestamp: Date, message: String? = nil, lastUserLocalation: Location? = nil, lastUserDistanceMeters: Int? = nil, event: Event, user: User, type: EventAlertType) {
        self.id = id
        self.timestamp = timestamp
        self.message = message
        self.lastUserLocalation = lastUserLocalation
        self.lastUserDistanceMeters = lastUserDistanceMeters
        self.event = event
        self.user = user
        self.type = type
    }
    
    static func create(_ type: EventAlertType, lastUserLocalation: Location? = nil, lastUserDistanceMeters: Int? = nil, event: Event, user: User) -> EventAlert {
        switch type {
        case .lost:
            return EventAlert(id: UUID().uuidString, timestamp: Date(), message: type.message, lastUserLocalation: lastUserLocalation, lastUserDistanceMeters: lastUserDistanceMeters, event: event, user: user, type: type)
        case .needABreak:
            return EventAlert(id: UUID().uuidString, timestamp: Date(), message: type.message, event: event, user: user, type: type)
        }
    }
    
}
