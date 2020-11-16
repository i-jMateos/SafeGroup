//
//  EventPost.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 12/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import Foundation

class EventPost {
    var id: Int
    var title: String
    var message: String
    var timestamp: Date
    var imageUrl: String?
    
    internal init(id: Int, title: String, message: String, timestamp: Date, imageUrl: String?) {
        self.id = id
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.imageUrl = imageUrl
    }
}
