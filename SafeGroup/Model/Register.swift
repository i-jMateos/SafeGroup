//
//  Register.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 18/12/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import Foundation

class register {
    internal init(id: String, email: String, firtname: String, lastname: String, password: String) {
        self.id = id
        self.email = email
        self.firtname = firtname
        self.lastname = lastname
        self.password = password
    }
    
    var id: String
    var email: String
    var firtname: String
    var lastname: String
    var password: String
}
