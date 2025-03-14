//
//  main.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 06/03/25.
//

import Foundation

enum MainMenu : Int {
    case createUser = 1
    case loginUser = 2
    case exit = 3
}

class Main {
    
    init() {
        if DatabaseConnection.shared.openDatabase() {
            print("Database opened successfully!")
            DatabaseConnection.shared.createTables()
            BankAccountDAO().addBankAccounts()
        } else {
            print("Failed to open database connection.")
            exit(1)
        }
    }
    
    func userInput() {
        while true {
            print("""
        ----------------------------------
        Welcome to Zoho Pay!!!
        1. Create User
        2. Login User
        3. Close
        ----------------------------------
        """)
            
            if let input = readLine(), let choice = Int(input), let action = MainMenu(rawValue: choice) {
                switch action {
                case .createUser:
                    UserMenuView.registerUser()
                case .loginUser:
                    UserMenuView.loginUser()
                case .exit:
                    print("Closing...")
                    DatabaseConnection.shared.closeDatabase()
                    break
                }
            }
            else {
                print("Invalid input. Please try again.")
            }
            
        }
    }
}

let main = Main()
main.userInput()
_ = AutoRenewalController()
