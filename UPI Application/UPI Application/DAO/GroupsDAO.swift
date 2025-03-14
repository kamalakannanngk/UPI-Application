//
//  GroupsDAO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation
import FMDB

class GroupsDAO {
    private let db: FMDatabase
    
    init() {
        self.db = DatabaseConnection.shared.database
    }
    
    func insertGroup(groupDO: GroupsDO) -> Int? {
        let query = "INSERT INTO Groups (name, creater_user_name) VALUES (?, ?);"
        do {
            try db.executeUpdate(query, values: [groupDO.groupName, groupDO.createrUsername])
            print("Group \(groupDO.groupName) Inserted Successfully!")
            return Int(db.lastInsertRowId)
        }
        catch {
            print("Error Inserting Group: \(error.localizedDescription)")
        }
        return nil
    }
    
    func deleteGroup(groupId : Int) {
        let query = "DELETE FROM Groups WHERE group_id = ?;"
        do {
            try db.executeQuery(query, values: [groupId])
            print("Group Deleted Successfully!")
        }
        catch {
            print("Error Deleting Group: \(error.localizedDescription)")
        }
    }
    
    func getGroup(groupId: Int) -> GroupsDO? {
        let query = "SELECT * FROM Groups WHERE group_id = ?;"

        do {
            let resultSet = try db.executeQuery(query, values: [groupId])

            if resultSet.next() {
                return GroupsDO(
                    groupId: groupId,
                    groupName: resultSet.string(forColumn: "group_name") ?? "",
                    createrUsername: resultSet.string(forColumn: "creater_user_name") ?? "",
                    date: resultSet.string(forColumn: "date") ?? ""
                )
            }
        } catch {
            print("Error fetching group: \(error)")
        }
        return nil
    }
    
    func isGroupIdExist(groupId: Int) -> Bool {
        let query = "SELECT * FROM Groups WHERE group_id = ?;"
        
        do {
            let resultSet = try db.executeQuery(query, values: [groupId])
            return resultSet.next()
        } catch {
            print("Error while checking group id: \(error)")
        }
        
        return false
    }
    
    func isGroupCreater(groupId: Int, username: String) -> Bool {
        let query = "SELECT * FROM Groups WHERE group_id = ? AND creater_user_name = ?;"
        
        do {
            let resultSet = try db.executeQuery(query, values: [groupId, username])
            return resultSet.next()
        } catch {
            print("Error while checking group id: \(error)")
        }
        
        return false
    }
}
