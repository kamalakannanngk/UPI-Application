//
//  GroupMemberDAO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation
import FMDB

class GroupMemberDAO {
    private let db: FMDatabase
    
    init() {
        self.db = DatabaseConnection.shared.database
    }
    
    func insertGroupMember(groupMemberDO: GroupMemberDO) -> Bool {
        let query = "INSERT INTO GroupMembers (group_id, member_user_name) VALUES (?, ?);"

        do {
            try db.executeUpdate(query, values: [groupMemberDO.groupId, groupMemberDO.member_user_name])
            print("Group Member \(groupMemberDO.member_user_name) inserted successfully!")
            return true
        } catch {
            print("Error inserting group member: \(error)")
        }
        return false
    }
    
    func getGroupMembersById(groupId: Int) -> [GroupMemberDO] {
        let query = "SELECT * FROM GroupMembers WHERE group_id = ?;"
        var members: [GroupMemberDO] = []

        do {
            let resultSet = try db.executeQuery(query, values: [groupId])

            while resultSet.next() {
                let member = GroupMemberDO(groupId: Int(resultSet.int(forColumn: "group_id")),
                                           member_user_name: resultSet.string(forColumn: "member_user_name") ?? "",
                                           addedDate: resultSet.string(forColumn: "added_date") ?? "")
                members.append(member)
            }
        } catch {
            print("Error fetching group members: \(error)")
        }
        return members
    }
    
    func getGroupsByUser(userDO: UserDO) -> [GroupsDO] {
        var groupsDOList: [GroupsDO] = []
        
        let query = """
        SELECT DISTINCT Groups.group_id, Groups.name, Groups.creater_user_name, Groups.date
        FROM Groups
        JOIN GroupMembers
        ON Groups.group_id = GroupMembers.group_id
        WHERE Groups.creater_user_name = ? OR GroupMembers.member_user_name = ?
        """
        
        do {
            let resultSet = try db.executeQuery(query, values: [userDO.username, userDO.username])
            while resultSet.next() {
                let groupsDO = GroupsDO(groupId: Int(resultSet.int(forColumn: "group_id")),
                                        groupName: resultSet.string(forColumn: "name") ?? "",
                                        createrUsername: resultSet.string(forColumn: "creater_user_name") ?? "",
                                        date: resultSet.string(forColumn: "date"))
                groupsDOList.append(groupsDO)
            }
            
        } catch {
            print("Error while fetching groups: \(error)")
        }
        
        return groupsDOList
    }
    
    func isUserInGroup(username: String, groupId: Int) -> Bool {
        let query = "SELECT * FROM GroupMembers WHERE member_user_name = ? AND group_id = ?"
        
        do {
            let resultSet = try db.executeQuery(query, values: [username, groupId])
            return resultSet.next()
        } catch {
            print("Error while checking if user is in group: \(error)")
        }
        
        return false
    }
    
    func deleteGroupMember(userDO: UserDO, groupId: Int) {
        let query = "DELETE FROM GroupMembers WHERE member_user_name = ? AND group_id = ?"
        
        do {
            try db.executeUpdate(query, values: [userDO.username, groupId])
        } catch {
            print("Error while deleting group member: \(error)")
        }
    }
}
