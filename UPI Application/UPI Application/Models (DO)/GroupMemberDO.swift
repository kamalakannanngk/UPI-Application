//
//  GroupMemberDO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation

class GroupMemberDO {
    var groupId: Int
    var member_user_name: String
    var addedDate: String?
    
    init(groupId: Int, member_user_name: String, addedDate: String? = nil) {
        self.groupId = groupId
        self.member_user_name = member_user_name
        self.addedDate = addedDate
    }
    
}
