//
//  Event.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 11/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import Foundation
class Event {
    var id: Int
    var name: String
    var localitation: Location
    var startDate: Date
    var endDate: Date
    var eventCode: String
    var description: String
    var user: User
    var imageUrl: String
    
    internal init(id: Int, name: String, localitation: Location, startDate: Date, endDate: Date, eventCode: String, description: String, user: User, imageUrl: String) {
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
