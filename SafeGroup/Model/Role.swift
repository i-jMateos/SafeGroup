//
//  Role.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 12/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import Foundation

class Role {
    internal init(id: Int, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
    
    var id: Int
    var name: String
    var description: String
}
