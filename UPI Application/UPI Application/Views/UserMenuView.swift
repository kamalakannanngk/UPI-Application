//
//  UserMenuView.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 08/03/25.
//

import Foundation

class UserMenuView {
    
    static func displayMenu(userDO: UserDO) {
        while true {
            print("""
    ----------------------------------
    Welcome, \(userDO.username)!
    1. Link Bank Account
    2. View Linked Bank Accounts
    3. Set Bank Account as Primary  
    4. Add UPI ID to the Bank Account
    5. Set UPI ID as Primary
    6. Send Money
    7. Request Money
    8. View Requests
    9. View Transaction History
    10. Check Balance
    11. Subscription
    12. Mobile Recharge
    13. Pay Bill
    14. View AutoRenewals
    15. Create Group
    16. View Groups
    17. View Your Profile
    18. Logout
    ----------------------------------
    """)
            
            if let input = readLine(), let option = Int(input), let action = UserMenu(rawValue: option) {
                switch action {
                case .linkBankAccount:
                    BankAccountView.linkBankAccount(userDO: userDO)
                    
                case .viewLinkedBankAccounts:
                    _ = BankAccountView.viewLinkedBankAccounts(userDO: userDO)
                    
                case .setPrimaryBankAccount:
                    BankAccountView.getAccount(userDO: userDO)
                    
                case .addUPI:
                    UPIView.addUPI(userDO: userDO)
                    
                case .setPrimaryUPI:
                    UPIView.setUPIPrimary(userDO: userDO)
                    
                case .sendMoney:
                    UPIView.sendMoney(userDO: userDO)
                    
                case .requestMoney:
                    RequestAmountView.requestAmount(userDO: userDO)
                    
                case .viewRequests:
                    RequestAmountView.displayRequests(userDO: userDO)
                    
                case .viewTransactions:
                    TransactionHistoryView.viewAllTransactions(userDO: userDO)
                    
                case .checkBalance:
                    BankAccountView.viewBalance(userDO: userDO)
                    
                case .subscription:
                    ServiceTransactionView.subscription(userDO: userDO)
                    
                case .mobileRecharge:
                    ServiceTransactionView.mobileRecharge(userDO: userDO)
                    
                case .payBill:
                    ServiceTransactionView.payBills(userDO: userDO)
                    
                case .viewAutoRenewals:
                    AutoRenewalView.showAutoRenewalsForUser(userDO: userDO)
                    
                case .createGroup:
                    GroupView.createGroup(userDO: userDO)
                    
                case .viewGruops:
                    GroupView.viewGroups(userDO: userDO)
                    
                case .viewYourProfile:
                    viewYourProfile(userDO: userDO)
                    
                case .logout:
                    return
                }
            }
            else {
                print("Invalid Option! Please try again.")
            }
        }
    }
    
    static func registerUser() {
        var username: String
        repeat {
            print("Enter Username: ")
            print("""
            Username Constraints:
            1. Must not be empty
            2. Must not contains spaces
            3. Must contains lowercase characters and numbers
            4. Uppercase characters and special characters are not allowed
            """)
            if let input = readLine(), !input.isEmpty, isValidUsername(username: input) {
                username = input
                break
            }
            else {
                print("Please enter a valid username!")
            }
        } while true
        
        var phoneNumber: String
        repeat {
            print("Enter Phone Number: ")
            if let input = readLine(), !input.isEmpty {
                phoneNumber = input
                break
            }
            else {
                print("Phone Number cannot be empty!")
            }
        } while true
                    
        var password: String
        repeat {
            print("Enter Password: ")
            print("Note: Password should contains atleast 1 uppercase, 1 lowercase, 1 special character, 1 number with minimum length of 8")
            if let input = readLine(), PasswordManager.isValidPassword(input) {
                password = PasswordManager.encrypt(input)
                break
            }
            else {
                print("Must meet the password requirements. Try again!")
            }
        } while true
        
        let userDO = UserDO(username: username, phoneNumber: phoneNumber, password: password)
        
        if UserController().registerUser(userOD: userDO) {
            print("Registeration Successful!")
            viewYourProfile(userDO: userDO)
            displayMenu(userDO: userDO)
        }
    }
    
    static func loginUser() {
        var username: String
        var password: String = ""
        
        repeat {
            print("Enter Username: ")
            if let input = readLine() {
                username = input
                break
            }
            else {
                print("Please enter a valid username!")
            }
        } while true

        print("Enter the Password: ")
        if let input = readLine() {
            password = input
        }

        if let userDO = UserController().loginUser(username: username, password: password) {
            print("Logged in successfully!")
            viewYourProfile(userDO: userDO)
            displayMenu(userDO: userDO)
        }
    }
    
    static func viewYourProfile(userDO: UserDO) {

            print("""
        ----------------------------------
        User Name: \(userDO.username)
        Phone Number: \(userDO.phoneNumber)
        ----------------------------------
        """)
        
    }
    
    // Username must not contains spaces, must contains only lowercase characters and numbers. Uppercase characters and special characters are not allowed
    private static func isValidUsername(username: String) -> Bool {
        for character in username {
            if !("a"..."z").contains(character) && !("0"..."9").contains(character) {
                return false
            }
        }
        
        if username.isEmpty {
            return false
        }
        
        return true
    }
}
