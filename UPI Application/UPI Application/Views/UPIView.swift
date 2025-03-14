//
//  UPIView.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 10/03/25.
//

import Foundation

enum MoneyOptions : Int {
    case sendViaUPI = 1
    case sendViaPhoneNumber = 2
}

class UPIView {
    static func sendMoney(userDO: UserDO) {
        if BankController().isLinkedWithBankAccount(userDO: userDO) {
            
            print("Choose the Bank Account to Send Money: ")
            let bankAccounts = BankAccountView.viewLinkedBankAccounts(userDO: userDO)
            
            if let input = readLine(), let choice = Int(input), choice >= 1 && choice <= bankAccounts.count {
                let bankAccountDO = bankAccounts[choice - 1]
                print("""
        ----------------------------------
        Enter the Option to Send Money
        1. UPI ID
        2. Phone Number
        ----------------------------------
        """)
                
                if let input = readLine(), let choice = Int(input), let action = MoneyOptions(rawValue: choice) {
                    switch action {
                    case .sendViaUPI:
                        sendViaUPI(userDO: userDO, senderBankAccountDO: bankAccountDO)
                    case .sendViaPhoneNumber:
                        sendViaPhoneNumber(userDO: userDO, senderBankAccountDO: bankAccountDO)
                    }
                } else {
                    print("Invalid Option Selected.")
                }
            } else {
                print("Invalid Choice!")
            }
            
        } else {
            print("Please link with the bank account for payments!")
        }
        
    }
    
    static func sendViaUPI(userDO: UserDO, senderBankAccountDO: BankAccountDO) {
        print("Enter the Receiver's UPI ID to send money:")
        if let receiverUPIID = readLine(), !receiverUPIID.isEmpty {
            let (amount, pin, message) = getInputForTransactions()
                    
            UPIController().sendMoneyViaUPI(
                senderBankAccountDO: senderBankAccountDO,
                receiverUPIID: receiverUPIID,
                amount: amount,
                UPIPIN: pin,
                message: message
            )
        } else {
            print("Receiver UPI ID should not be empty!")
        }
                
    }
    
    static func sendViaPhoneNumber(userDO: UserDO, senderBankAccountDO: BankAccountDO) {
        print("Enter the Phone Number to send money: ")
        if let input = readLine(), !input.isEmpty {
            let (amount, UPIPIN, message) = getInputForTransactions()
            UPIController().sendMoneyViaMobileNumber(
                senderBankAccountDO: senderBankAccountDO,
                receiverMobileNumber: input,
                amount: amount,
                UPIPIN: UPIPIN,
                message: message
            )
        } else {
            print("Input should not be empty.")
        }
    }
    
    static func getInputForTransactions() -> (amount: Double, UPIPIN: Int, message: String?) {
        var amount: Double = 0.0
        var UPIPIN: Int = 0
        var message: String?
        
        print("Enter the Amount to send:")
        if let input = readLine(), let integerInput = Double(input) {
            amount = integerInput
            
            print("Enter your 6 digit UPI PIN:")
            if let input = readLine(), let pin = Int(input) {
                UPIPIN = pin
                
                print("Enter the message to send with the UPI transaction: (Optional) (Press Enter to skip)")
                let messageInput = readLine()
                let _message = messageInput?.isEmpty == true ? nil : messageInput
                message = _message
                
            } else {
                print("Invalid PIN!")
            }
        } else {
            print("Invalid Amount!")
        }
        
        return (amount, UPIPIN, message)
    }
    
    static func viewLinkedUPIs(bankAccountDO: BankAccountDO) -> [UPIDO] {
        let UPIs = UPIController().getLinkedUPIs(bankAccountDO: bankAccountDO)
        
        for (index, UPI) in UPIs.enumerated() {
            print("""
            ----------------------------------
            UPI \(index + 1).
            UPI ID: \(UPI.upiId)
            Account Number: \(UPI.accountNumber)
            ----------------------------------
            """)
        }
        
        return UPIs
    }
    
    static func addUPI(userDO: UserDO) {
        let bankAccounts = BankAccountView.viewLinkedBankAccounts(userDO: userDO)
        print("Choose the Linked Bank Account to add the UPI ID:")
        if let input = readLine(), let choice = Int(input), choice >= 1 && choice <= bankAccounts.count {
            UPIController().addUPI(userDO: userDO, bankAccountDO: bankAccounts[choice - 1])
        }
        else {
            print("Invalid Choice.")
        }
    }
    
    static func setUPIPrimary(userDO: UserDO) {
        let bankAccounts = BankAccountView.viewLinkedBankAccounts(userDO: userDO)
        print("Choose the Linked Bank Account to set the Primary UPI ID:")
        if let input = readLine(), let choice = Int(input), choice >= 1 && choice <= bankAccounts.count {
            let bankAccountDO = bankAccounts[choice - 1]
            let UPIIDs = UPIController().getLinkedUPIs(bankAccountDO: bankAccountDO)
            print("Choose the UPI to set the UPI ID as Primary")
            if let input = readLine(), let choice = Int(input), choice >= 1 && choice <= UPIIDs.count {
                UPIController().setUPIPrimary(UPIID: UPIIDs[choice - 1].upiId)
            }
        }
    }
}
