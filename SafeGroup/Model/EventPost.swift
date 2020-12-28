//
//  EventPost.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 12/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import Foundation

class EventPost: Codable {
    var id: String
    var message: String
    var timestamp: Date
    var imageUrl: String?
    var user: User
    var event: Event
    
    internal init(id: String, message: String, timestamp: Date, imageUrl: String?, user: User, event: Event) {
        self.id = id
        self.message = message
        self.timestamp = timestamp
        self.imageUrl = imageUrl
        self.user = user
        self.event = event
    }
    
    enum CodingKeys: String, CodingKey {
        case id, message, timestamp, imageUrl, user, event
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        message = try container.decode(String.self, forKey: .message)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        user = try container.decode(User.self, forKey: .user)
        event = try container.decode(Event.self, forKey: .event)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(message, forKey: .message)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(user, forKey: .user)
        try container.encode(event, forKey: .event)
    }
}
