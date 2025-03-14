//
//  GroupView.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 13/03/25.
//

import Foundation

enum GroupActions: Int {
    case viewGroupMembers = 1
    case addGroupMembers = 2
    case createSplitBill = 3
    case viewSplitBill = 4
    case leaveGroup = 5
    case exit = 6
}

class GroupView {
    
    static func createGroup(userDO: UserDO) {

        print("Enter the Group Name:")
        if let groupName = readLine(), !groupName.isEmpty {
            
            let groupsDO = GroupsDO(groupName: groupName, createrUsername: userDO.username)
            
            guard let groupId = GroupController().createGroup(groupsDO: groupsDO) else {
                print("Found while after inserting Group \(groupName)")
                return
            }
            
            GroupController().addGroupMember(userDO: userDO, groupMemberDO: GroupMemberDO(groupId: groupId, member_user_name: userDO.username))
            
            addGroupMembers(userDO: userDO, groupId: groupId)
            
            
        } else {
            print("Group Name cannot be empty!")
        }
    }
    
    static func addGroupMembers(userDO: UserDO, groupId: Int) {
        
        if GroupController().isGroupIdExist(groupId: groupId) {
            if GroupController().isGroupCreator(userDO: userDO, groupId: groupId) {
                while true {
                    print("""
                    ----------------------------------
                    1. Add Group Member
                    2. Exit
                    ----------------------------------
                    """)
                    if let input = readLine(), let choice = Int(input) {
                        switch choice {
                        case 1:
                            print("Enter the username of the Group Member to add:")
                            if let username = readLine(), !username.isEmpty {
                                
                                let groupMemberDO = GroupMemberDO(groupId: groupId, member_user_name: username)
                                
                                GroupController().addGroupMember(userDO: userDO, groupMemberDO: groupMemberDO)
                                
                            } else {
                                print("username cannot be empty!")
                            }
                        case 2:
                            return
                        default:
                            print("Invalid choice!")
                        }
                    }
                }
            } else {
                print("You are not a creator of this group!")
                return
            }
        } else {
            print("Group ID does not exist!")
            return
        }
        
    }
    
    static func viewGroupMembers(groupId: Int) {
        let groupMembersDO = GroupController().getGroupMembers(groupId: groupId)
        
        for groupMemberDO in groupMembersDO {
            if let date = groupMemberDO.addedDate {
                print("""
            ----------------------------------
            Group ID: \(groupId)
            Member User Name: \(groupMemberDO.member_user_name)
            Created Date and Time: \(date)
            ----------------------------------
            """)
            }
        }
    }
    
    static func viewGroups(userDO: UserDO) {
        let groupsDOList = GroupController().getGroupsForUser(userDO: userDO)
        
        for groupDO in groupsDOList {

            if let groupId = groupDO.groupId {
                if let date = groupDO.date {
                    
                    print("""
                    ----------------------------------
                    Group ID: \(groupId)
                    Group Name: \(groupDO.groupName)
                    Creater User Name: \(groupDO.createrUsername)
                    Created Date and Time: \(date)
                    ----------------------------------
                    """)
                    
                }
            }
        }
        
        
        print("Enter the Group Id for Actions:")
        
        if let input = readLine(), let groupId = Int(input), !input.isEmpty {
            if !GroupController().isUserInGroup(username: userDO.username, groupId: groupId) {
                print("Group Id is not valid for the User!")
                return
            }
        
            while true {
                
                print("""
        ----------------------------------
        1. View Group Members
        2. Add Group Members
        3. Create Split Bill
        4. View Split Bills
        5. Leave Group
        6. Exit
        ----------------------------------
        """)
                if let input = readLine(), let choice = Int(input), let action = GroupActions(rawValue: choice) {
                    switch action {
                    case .viewGroupMembers:
                        viewGroupMembers(groupId: groupId)
                        
                    case .addGroupMembers:
                        addGroupMembers(userDO: userDO, groupId: groupId)
                        
                    case .createSplitBill:
                        SplitBillView.createSplitBill(userDO: userDO, groupId: groupId)
                        
                    case .viewSplitBill:
                        SplitBillView.viewSplitBillForUserInGroup(userDO: userDO, groupId: groupId)
                        
                    case .leaveGroup:
                        GroupController().leaveGroup(userDO: userDO, groupId: groupId)
                        print("Left the group successfully!")
                        return
                    case .exit:
                        return
                    }
                }
            }
        } else {
            print("Input cannot be empty!")
        }
        
    }
}
