//
//  UserDO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

class UserDO {
    var username: String
    var phoneNumber: String
    var password: String
    
    init(username: String, phoneNumber: String, password: String) {
        self.username = username
        self.phoneNumber = phoneNumber
        self.password = password
    }
}
