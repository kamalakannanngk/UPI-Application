//
//  BankAccountView.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 09/03/25.
//

import Foundation

enum BankName : String {
    case hdfc = "hdfc"
    case icici = "icici"
    case sbi = "sbi"
    case axis = "axis"
    case dbs = "dbs"
    case kvb = "kvb"
    case iob = "iob"
    
    static func from(number: Int) -> BankName? {
        switch number {
        case 1: return .hdfc
        case 2: return .icici
        case 3: return .sbi
        case 4: return .axis
        case 5: return .dbs
        case 6: return .kvb
        case 7: return .iob
        default: return nil
        }
    }
    
}

class BankAccountView {
    static func linkBankAccount(userDO: UserDO) {
        let bankName : BankName
        let accountNumber: String
        var UPIPIN: Int
        
        repeat {
            print("""
        ----------------------------------
        Choose the Bank:
        1. HDFC
        2. ICICI
        3. SBI
        4. AXIS
        5. DBS
        6. KVB
        7. IOB
        ----------------------------------
        """)
            
            if let input = readLine(), let choice = Int(input), choice >= 1 && choice <= 7, let action = BankName.from(number: choice) {
                switch action {
                case .hdfc:
                    bankName = .hdfc
                case .icici:
                    bankName = .icici
                case .sbi:
                    bankName = .sbi
                case .axis:
                    bankName = .axis
                case .dbs:
                    bankName = .dbs
                case .kvb:
                    bankName = .kvb
                case .iob:
                    bankName = .iob
                }
                break
            } else {
                print("Invalid Choice!")
            }
        } while true
        
        repeat {
            print("Enter Your Account Number:")
            if let input = readLine(), input.range(of: "^[0-9]{9,18}$", options: .regularExpression) != nil {
                accountNumber = input
                break
            } else {
                print("Invalid Account Number!")
            }
        } while true
        
        if BankController().verifyBankAccount(bankName: bankName, accountNumber: accountNumber, userDO: userDO) {
            print("Bank Account Found!")
            UPIPIN = setUPIPin()
            
            BankController().linkBankAccount(username: userDO.username, bankName: bankName, accountNumber: accountNumber, UPIPin: UPIPIN)
            
        }
        else {
            print("Incorrect Bank Details! Try Again!")
        }
        
    }
    
    static func viewLinkedBankAccounts(userDO: UserDO) -> [BankAccountDO] {
        let bankAccounts : [BankAccountDO] = BankController().getBankAccountsForUser(username: userDO.username)
        
        if bankAccounts.isEmpty {
            print("No Bank Accounts Linked Yet!")
        } else {
            for (index, bankAccount) in bankAccounts.enumerated() {
                print("""
            ----------------------------------
            Account \(index + 1)
            Bank Name: \(bankAccount.name)
            Account Number: \(bankAccount.accountNumber)
            ----------------------------------\n
            """)
            }
        }
        
        return bankAccounts
        
    }
    
    static func setUPIPin() -> Int {
        var UPIPin: Int
        repeat {
            print("Set the 6 digit UPI PIN")
            if let input = readLine(), let pin = Int(input), input.count == 6 {
                UPIPin = pin
                break
            } else {
                print("Please enter a valid 6 digit PIN!")
            }
            
        } while true
        
        return UPIPin
    }
    
    static func getAccount(userDO: UserDO) {
        let bankAccounts = viewLinkedBankAccounts(userDO: userDO)
        if let input = readLine(), let choice = Int(input), choice >= 1 && choice <= bankAccounts.count {
            BankController().setBankAccountAsPrimary(accountNumber: bankAccounts[choice - 1].accountNumber, username: userDO.username)
        } else {
            print("Invalid choice!")
        }
    }
    
    static func viewBalance(userDO: UserDO) {
        print("Choose the Account Number to Check Balance:")
        let bankAccounts = viewLinkedBankAccounts(userDO: userDO)
        if let input = readLine(), let choice = Int(input), choice >= 1 && choice <= bankAccounts.count {
            let bankAccountDO = bankAccounts[choice - 1]
            
            print("Enter your 6 digit UPI PIN:")
            if let input = readLine(), let pin = Int(input), input.count == 6 {
                if BankController().verifyUPIPin(bankAccountDO: bankAccountDO, UPIPin: pin) {
                    print("Balance: \(bankAccountDO.balance)")
                } else {
                    print("Incorrect PIN!")
                }
            } else {
                print("Invalid PIN!")
            }
        } else {
            print("Invalid choice!")
        }
    }
}
