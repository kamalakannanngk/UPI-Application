//
//  SplitBillView.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 13/03/25.
//

import Foundation

class SplitBillView {
    
    static func createSplitBill(userDO: UserDO, groupId: Int) {
        if !BankController().isLinkedWithBankAccount(userDO: userDO) {
            print("Link your Bank Account first to proceed!")
            return
        }
        
        print("Enter the Amount to split: ")
        if let input = readLine(), let amount = Double(input), amount > 0.0, !input.isEmpty {
            
            var splitBillDO = SplitBillDO(groupID: groupId, payerUsername: userDO.username, totalAmount: amount)
            
            if let splitBillId = SplitBillController().createSplitBill(splitBillDO: splitBillDO) {
                splitBillDO = SplitBillDO(splitBillID: splitBillId, groupID: groupId, payerUsername: userDO.username, totalAmount: amount)
                print("Split Bill Created Successfully with Split Bill Id: \(splitBillId)")
                
                GroupView.viewGroupMembers(groupId: groupId)
                
                var splitBillParticipants: [SplitBillParticipantsDO] = []
                var usernames : [String] = []
                
                whileLoop: while true {
                    print("""
                    ----------------------------------
                    1. Add Member to Split:
                    2. Finish
                    ----------------------------------
                    """)
                    
                    if let input = readLine(), let option = Int(input) {
                        switch option {
                        case 1:
                            print("Enter Username: ")
                            if let username = readLine(), !username.isEmpty {
                                if GroupController().isUserInGroup(username: username, groupId: groupId) {
                                    if !SplitBillController().isUserInSplit(splitBillId: splitBillId, userDO: userDO) {
                                        usernames.append(username)
                                        print("Member \(username) added successfully to the split!")
                                    } else {
                                        print("User already exists in the split!")
                                    }
                                } else {
                                    print("User not found in the group!")
                                }
                            } else {
                                print("Username cannot be empty!")
                            }
                            
                        case 2:
                            break whileLoop
                        default:
                            print("Invalid option selected. Please try again.")
                        }
                    }
                    
                }
                
                let splitAmount = amount / (Double(usernames.count) + 1)
                
                for username in usernames {
                    let participant = SplitBillParticipantsDO(splitBillId: splitBillId, payeeUsername: username, amount: splitAmount)
                    splitBillParticipants.append(participant)
                }
                
                SplitBillController().insertIntoSplitBill(splitBillParticipantsDOList: splitBillParticipants)
                print("Participants added successfully to the split bill!")
                
            } else {
                print("Split Bill Id is not generated! (NIL)")
            }
        } else {
            print("Amount cannot be empty/ non numeric/ less than or equal to zero")
        }
    }
    
    static func viewSplitBillForUserInGroup(userDO: UserDO, groupId: Int) {
        let splitBillDOs = SplitBillController().getSplitBillForUserInGroup(userDO: userDO, groupId: groupId)
        
        for splitBillDO in splitBillDOs {
            
            if let splitBillID = splitBillDO.splitBillID {
                print("""
            ----------------------------------
            Split Bill ID: \(splitBillID)
            Payer Username: \(splitBillDO.payerUsername)
            Total Amount: \(splitBillDO.totalAmount)
            ----------------------------------
            """)
                
            } else {
                print("Split Bill ID is nil!")
            }
            
        }
        
        selectSplitBillToPay(userDO: userDO, groupId: groupId)
        
    }
    
    static func displaySplitBillParticipants(splitBillID: Int, userDO: UserDO) -> Double? {
        var amount : Double?
        let splitBillParticipants = SplitBillController().getSplitBillParticipants(splitBillId: splitBillID)
        
        if splitBillParticipants.isEmpty {
            print("Split Bill Participants is Empty!")
        }
        
        for splitBillParticipant in splitBillParticipants {
            
            if let status = splitBillParticipant.status {
                
                print("""
            ----------------------------------
            Split Bill ID: \(splitBillParticipant.splitBillId)
            Payee Username: \(splitBillParticipant.payeeUsername)
            Amount: \(splitBillParticipant.amount)
            Status: \(status)
            ----------------------------------
            """)
                
                if splitBillParticipant.payeeUsername == userDO.username {
                    amount = splitBillParticipant.amount
                }
            }
        }
        
        return amount
    }
    
    static func selectSplitBillToPay(userDO: UserDO, groupId: Int) {
        print("Enter the Split Bill ID: ")
        if let input = readLine(), let splitBillID = Int(input), !input.isEmpty {
            
            if SplitBillController().isPayerOfSplitBill(splitBillId: splitBillID, payerUsername: userDO.username) {
                print("You are the Payer of this Split Bill!")
                return
            }
            
            guard let amount = displaySplitBillParticipants(splitBillID: splitBillID, userDO: userDO) else {
                print("Found Amount is nil!")
                return
            }
            
            guard let payerUsername = SplitBillController().getPayerUsernameForSplitBill(splitBillId: splitBillID) else {
                print("Found Payer Username is nil!")
                return
            }
            
            guard let receiverUserDO = UserController().getUser(username: payerUsername) else {
                print("Found Receiver UserDO is nil!")
                return
            }
            
            guard let receiverUPIID = UPIController().getUPIByUserName(userDO: receiverUserDO) else {
                print("Found Receiver UPI is nil!")
                return
            }
            
            if !SplitBillController().isUserInSplit(splitBillId: splitBillID, userDO: userDO) {
                print("You are not a part of this Split Bill")
            }
            var bankAccountDO: BankAccountDO?
            
            if SplitBillController().isSplitBillPaid(splitBillId: splitBillID, payeeUsername: userDO.username) {
                print("You have already paid this Split Bill!")
                return
            }
            
            print("Choose the Bank Account to send money: ")
            let bankAccounts = BankAccountView.viewLinkedBankAccounts(userDO: userDO)
            
            if let input = readLine(), let choice = Int(input), !input.isEmpty, choice >= 1 && choice <= bankAccounts.count {
                bankAccountDO = bankAccounts[choice - 1]
                
                print("Enter your 6 digit UPI PIN")
                if let input = readLine(), let upiPIN = Int(input), !input.isEmpty, input.count == 6 {
                    if UPIController().verifyUPIPIN(UPIID: receiverUPIID, UPIPIN: upiPIN) {
                        
                        if let bankAccountDO = bankAccountDO {
                            UPIController().sendMoneyViaUPI(senderBankAccountDO: bankAccountDO, receiverUPIID: receiverUPIID, amount: amount, UPIPIN: upiPIN, message: nil)
                            if !SplitBillController().updateSplitBillStatus(splitBillId: splitBillID, payeeUsername: userDO.username) {
                                print("Error Updating Split Bill Status after Payment!")
                            }
                        }
                        
                        
                    } else {
                        print("Incorrect UPI PIN!")
                    }
                        
                        
                } else {
                    print("Invalid UPI PIN!")
                }
            }
            
            
            
            
        } else {
            print("Split Bill ID is invalid. Please try again.")
        }
    }
    
}
