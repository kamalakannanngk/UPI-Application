//
//  GroupsDAO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation

class GroupsDO {
    var groupId: Int?
    var groupName: String
    var createrUsername: String
    var date: String?
    
    init(groupId: Int? = nil, groupName: String, createrUsername: String, date: String? = nil) {
        self.groupId = groupId
        self.groupName = groupName
        self.createrUsername = createrUsername
        self.date = date
    }
}
