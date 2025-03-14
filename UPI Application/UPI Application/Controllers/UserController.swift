//
//  UserManager.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 06/03/25.
//

import Foundation

enum UserMenu : Int {
    case linkBankAccount = 1
    case viewLinkedBankAccounts = 2
    case setPrimaryBankAccount = 3
    case addUPI = 4
    case setPrimaryUPI = 5
    case sendMoney = 6
    case requestMoney = 7
    case viewRequests = 8
    case viewTransactions = 9
    case checkBalance = 10
    case subscription = 11
    case mobileRecharge = 12
    case payBill = 13
    case viewAutoRenewals = 14
    case createGroup = 15
    case viewGruops = 16
    case viewYourProfile = 17
    case logout = 18
}

class UserController {
    private let userDAO: UserDAO
    private let requestDAO: RequestAmountDAO
    
    init() {
        self.userDAO = UserDAO()
        self.requestDAO = RequestAmountDAO()
    }
    
    func registerUser(userOD : UserDO) -> Bool {
                    
        if userDAO.insertUser(user: userOD) {
            print("User Registered Successfully!")
            return true
        }
        else {
            print("User Registration Failed!")
            return false
        }
        
    }
    
    func loginUser(username: String, password: String) -> UserDO? {
        if let userDO = userDAO.getUser(username: username) {
            if PasswordManager.decrypt(userDO.password) == password {
                return userDO
            }
            else {
                print("Invalid Password!")
            }
        }
        else {
            print("User not found!")
        }
        return nil
    }
    
    func getUser(username: String) -> UserDO? {
        if let userDO = userDAO.getUser(username: username) {
            return userDO
        }
        return nil
    }
}
