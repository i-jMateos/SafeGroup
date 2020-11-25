//
//  Event.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 11/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import Foundation
class Event: Codable {
    var id: Int?
    var name: String
    var localitation: Location
    var startDate: Date
    var endDate: Date
    var eventCode: String?
    var description: String
    var user: User
    var imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, localitation, startDate, endDate, eventCode, description, user, imageUrl
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        localitation = try container.decode(Location.self, forKey: .localitation)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        eventCode = try container.decodeIfPresent(String.self, forKey: .eventCode)
        description = try container.decode(String.self, forKey: .description)
        user = try container.decode(User.self, forKey: .user)
        imageUrl =  try container.decodeIfPresent(String.self, forKey: .imageUrl)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(localitation, forKey: .localitation)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(eventCode, forKey: .eventCode)
        try container.encode(description, forKey: .description)
        try container.encode(description, forKey: .description)
        try container.encode(user, forKey: .user)
        try container.encode(imageUrl, forKey: .imageUrl)
    }
    
    internal init(id: Int?, name: String, localitation: Location, startDate: Date, endDate: Date, eventCode: String?, description: String, user: User, imageUrl: String?) {
        self.id = id
        self.name = name
        self.localitation = localitation
        self.startDate = startDate
        self.endDate = endDate
        self.eventCode = eventCode
        self.description = description
        self.user = user
        self.imageUrl = imageUrl
    }
    
    

    func getParticipants() {
    }

    func getAlerts() {

    }

    func editEvent() {

    }

    func deleteEvent() {

    }

    func getPost() {

    }
}
