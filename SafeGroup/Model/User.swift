//
//  User.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 11/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import Foundation

class User {
    var id: Int
    var email: String
    //var events: [Event]
    
    init(id: Int, email: String) {
        self.id = id
        self.email = email
    }
}
