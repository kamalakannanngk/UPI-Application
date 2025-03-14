//
//  UserDAO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import FMDB

class UserDAO {
    private let db: FMDatabase
    
    init() {
        self.db = DatabaseConnection.shared.database
    }
    
    func insertUser(user: UserDO) -> Bool {
        let query = "INSERT INTO User (user_name, phone_number, password) VALUES (?, ?, ?);"
        do {
            try db.executeUpdate(query, values: [user.username, user.phoneNumber, user.password])
            return true
        }
        catch {
            print("Failed to insert user. Error: \(error)")
            print("Username Already Exists! Please try with different username.")
        }
        return false
    }
    
    func getUser(username: String) -> UserDO? {
        let query = "SELECT * FROM User WHERE user_name = ?;"
        do {
            let resultSet = try db.executeQuery(query, values: [username])
            if resultSet.next() {
                let userDo = UserDO(
                    username: resultSet.string(forColumn: "user_name") ?? "",
                    phoneNumber: resultSet.string(forColumn: "phone_number") ?? "",
                    password: resultSet.string(forColumn: "password") ?? ""
                )
                return userDo
            }
        }
        catch {
            print("Failed to Fetch User! Error: \(error)")
        }
        return nil
    }
    
    func isUserNameUnique(name: String) -> Bool {
        let query = "SELECT * FROM User WHERE name = ?;"
        do {
            let resultSet = try db.executeQuery(query, values: [name])
            let count = resultSet.int(forColumnIndex: 0)
            return count == 0
        }
        catch {
            print("Failed to check user name uniqueness! Error: \(error)")
        }
        return false
    }
    
    func isUserExist(username: String) -> Bool {
        let query = "SELECT user_name FROM User WHERE user_name = ?;"
        do {
            let resultSet = try db.executeQuery(query, values: [username])
            return resultSet.next()
        } catch {
            print("Error while checking user existence: \(error)")
        }
        
        return false
    }
    
}
