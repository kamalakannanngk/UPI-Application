//
//  GroupController.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 13/03/25.
//

import Foundation

class GroupController {
    private let groupsDAO = GroupsDAO()
    private let groupMemberDAO = GroupMemberDAO()
    private let userDAO = UserDAO()
    
    func createGroup(groupsDO: GroupsDO) -> Int? {
        return groupsDAO.insertGroup(groupDO: groupsDO)
    }
    
    func addGroupMember(userDO: UserDO, groupMemberDO: GroupMemberDO) {
        
        if !isUserInGroup(username: groupMemberDO.member_user_name, groupId: groupMemberDO.groupId) {
            if userDAO.isUserExist(username: groupMemberDO.member_user_name) {
                if groupMemberDAO.insertGroupMember(groupMemberDO: groupMemberDO) {
                    print("\(groupMemberDO.member_user_name) inserted successfully!")
                } else {
                    print("Failed to insert \(groupMemberDO.member_user_name)")
                }
            } else {
                print("Username not exist!")
            }
        } else {
            print("User already exist in the group!")
        }
        
    }
    
    func isUserInGroup(username: String, groupId: Int) -> Bool {
        return groupMemberDAO.isUserInGroup(username: username, groupId: groupId)
    }
    
    func getGroupsForUser(userDO: UserDO) -> [GroupsDO] {
        return groupMemberDAO.getGroupsByUser(userDO: userDO)
    }
    
    func isGroupIdExist(groupId: Int) -> Bool {
        return groupsDAO.isGroupIdExist(groupId: groupId)
    }
    
    func isGroupCreator(userDO: UserDO, groupId: Int) -> Bool {
        return groupsDAO.isGroupCreater(groupId: groupId, username: userDO.username)
    }
    
    func getGroupMembers(groupId: Int) -> [GroupMemberDO] {
        return groupMemberDAO.getGroupMembersById(groupId: groupId)
    }
    
    func leaveGroup(userDO: UserDO, groupId: Int) {
        groupMemberDAO.deleteGroupMember(userDO: userDO, groupId: groupId)
    }
    
}
