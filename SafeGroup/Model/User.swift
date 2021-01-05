//
//  User.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 11/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import Foundation
import Firebase

class User: Codable {
    internal init(id: String, email: String, firtname: String? = nil, lastname: String? = nil, role: Role = .participante) {
        self.id = id
        self.email = email
        self.firstname = firtname
        self.lastname = lastname
        self.role = role
    }
    
    var id: String
    var email: String
    var firstname: String?
    var lastname: String?
    var role: Role?
    
    var displayName: String {
        return "\(firstname ?? "") \(lastname ?? "")"
    }
    
    var initials: String {
        return "\(firstname?.first?.uppercased() ?? "")\(lastname?.first?.uppercased() ?? "")"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, firstname, lastname, role
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        firstname = try container.decodeIfPresent(String.self, forKey: .firstname)
        lastname = try container.decodeIfPresent(String.self, forKey: .lastname)
        role = try container.decodeIfPresent(Role.self, forKey: .role)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(firstname, forKey: .firstname)
        try container.encode(lastname, forKey: .lastname)
        try container.encode(role, forKey: .role)
    }
}

extension User {
    static var currentUser: User?
    
//    static var currentUser: User? {
//        guard let firUser = Auth.auth().currentUser else { return nil }
//        
//        return User(id: firUser.uid, email: firUser.email!)
//    }
    
    static func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        if writeToUserDefaults {
            if let data = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
            }
        }
        
        currentUser = user
    }
}
