//
//  RequestAmountView.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 12/03/25.
//

import Foundation

enum ViewRequests: Int {
    case receivedRequests = 1
    case sentRequests = 2
}

class RequestAmountView {
    
    static func requestAmount(userDO: UserDO) {
        print("""
        ----------------------------------
        Enter the Option to Request Money
        1. UPI ID
        2. Phone Number
        ----------------------------------
        """)
        
        if let input = readLine(), let choice = Int(input), let action = MoneyOptions(rawValue: choice) {
            switch action {
            case .sendViaUPI:
                requestViaUPI(userDO: userDO)
            case .sendViaPhoneNumber:
                requestViaPhoneNumber(userDO: userDO)
            }
        }
    }
    
    static func requestViaUPI(userDO: UserDO) {
        var senderUPIID: String
        var receiverUPIID: String
        var amount: Double

        print("Enter the UPI ID to Request Money:")
        guard let input = readLine(), !input.isEmpty else {
            print("Invalid UPI ID")
            return
        }
        receiverUPIID = input
        
        print("Enter the Amount:")
        guard let input = readLine(), let amountValue = Double(input) else {
            print("Invalid Amount")
            return
        }
        
        amount = amountValue
        guard let input = UPIController().getUPIByUserName(userDO: userDO) else {
            print("Invalid UPI ID")
            return
        }
        
        senderUPIID = input
        
        
        if RequestAmountController().requestAmount(requestAmountDO: RequestAmountDO(senderUPIId: senderUPIID, receiverUPIId: receiverUPIID, amount: amount)) != nil {
            print("Request Sent Successfully")
            displaySentRequest(userDO: userDO)
        }
        
    }
    
    static func requestViaPhoneNumber(userDO: UserDO) {
        var phoneNumber: String
        var amount: Double
        var senderUPIID: String
        
        print("Enter the Mobile Number to Request Money:")
        guard let input = readLine(), input.count == 10 else {
            print("Invalid Mobile Number")
            return
        }
        phoneNumber = input
        
        print("Enter the Amount:")
        guard let input = readLine(), let amountValue = Double(input) else {
            print("Invalid Amount")
            return
        }
        amount = amountValue
        
        guard let input = UPIController().getUPIByUserName(userDO: userDO) else {
            print("Invalid UPI ID")
            return
        }
        senderUPIID = input

        guard let receiverUPIID = UPIDAO().getPrimaryUPI(phoneNumber: phoneNumber) else {
            print("Receiver UPI ID is nil")
            return
        }
        
        if RequestAmountController().requestAmount(requestAmountDO: RequestAmountDO(senderUPIId: senderUPIID, receiverUPIId: receiverUPIID, amount: amount)) != nil {
            print("Request Sent Successfully")
            displaySentRequest(userDO: userDO)
        }
    }
    
    
    
    static func displayReceivedRequests(userDO: UserDO) -> [RequestAmountDO] {
        let requestAmountData : [RequestAmountDO] = RequestAmountController().getReceivedRequestByUser(userDO: userDO)
        
        for requestAmountDO in requestAmountData {
            
            if let requestId = requestAmountDO.requestId {
                if let status = requestAmountDO.status {
                    
                    print("""
                ----------------------------------
                Request Id: \(requestId)
                Sender UPI ID: \(requestAmountDO.senderUPIId)
                Status: \(status)
                ----------------------------------
                """)
                    
                } else {
                    print("Found nil while fetching request status")
                }
            } else {
                print("Found nil while fetching request id")
            }
        }
        
        return requestAmountData
    }
    
    static func displaySentRequest(userDO: UserDO) {
        let requestAmountData : [RequestAmountDO] = RequestAmountController().getSentRequestByUser(userDO: userDO)
        
        for requestAmountDO in requestAmountData {
            
            if let requestId = requestAmountDO.requestId {
                if let status = requestAmountDO.status {
                    
                    print("""
                ----------------------------------
                Request Id: \(requestId)
                Your UPI ID: \(requestAmountDO.senderUPIId)
                Receiver UPI ID: \(requestAmountDO.receiverUPIId)
                Status: \(status)
                ----------------------------------
                """)
                    
                } else {
                    print("Found nil while fetching request status")
                }
            } else {
                print("Found nil while fetching request id")
            }
        }
    }
    
    static func displayRequests(userDO: UserDO) {
        print("""
        ----------------------------------
        1. Received Requests
        2. Sent Requests
        ----------------------------------        
        """)
        
        if let input = readLine(), let choice = Int(input), let action = ViewRequests(rawValue: choice) {
            switch action {
            case .receivedRequests:
                _ = displayReceivedRequests(userDO: userDO)
                
                whileLoop: while true {
                    print("""
                    ----------------------------------
                    1. Action on Requests
                    2. Exit
                    ----------------------------------        
                    """)
                    if let input = readLine(), let choice = Int(input), choice >= 1, choice <= 2 {
                        
                        switch choice {
                        case 1:
                            print("""
                            ----------------------------------
                            1. Pay Money
                            2. Decline Request
                            ----------------------------------        
                            """)
                            if let input = readLine(), let choice = Int(input), choice >= 1, choice <= 2 {
                                switch choice {
                                case 1:
                                    _ = displayReceivedRequests(userDO: userDO)
                                    print("Enter the Request Id to pay:")
                                    if let input = readLine(), let requestId = Int(input) {
                                        if let requestAmountDO = RequestAmountController().getRequestDOById(requestId: requestId) {
                                            
                                            if requestAmountDO.status == .paid {
                                                print("Amount is Already Paid!")
                                                break whileLoop
                                            }
                                            
                                            if requestAmountDO.status == .declined {
                                                print("Request is Declined!")
                                                break whileLoop
                                            }
                                            
                                            print("Choose the Bank Account to Send Money: ")
                                            let bankAccounts = BankAccountView.viewLinkedBankAccounts(userDO: userDO)
                                            
                                            if let input = readLine(), let choice = Int(input), choice >= 1 && choice <= bankAccounts.count {
                                                let bankAccountDO = bankAccounts[choice - 1]
                                                
                                                print("Enter your 6 digit UPI-PIN:")
                                                if let input = readLine(), let pin = Int(input), input.count == 6 {
                                                    print("Enter the message to send with the UPI transaction: (Optional) (Press Enter to skip)")
                                                    let messageInput = readLine()
                                                    let message = messageInput?.isEmpty == true ? nil : messageInput
                                                    
                                                    UPIController().sendMoneyViaUPI(senderBankAccountDO: bankAccountDO, receiverUPIID: requestAmountDO.senderUPIId, amount: requestAmountDO.amount, UPIPIN: pin, message: message)
                                                    
                                                    RequestAmountController().updateRequestStatus(requestId: requestId, status: .paid)
                                                    
                                                } else {
                                                    print("Invalid UPI PIN!")
                                                }
                                                
                                            }
                                            
                                        } else {
                                            print("Request not found!")
                                        }
                                    } else {
                                        print("Invalid input!")
                                    }
                                case 2:
                                    _ = displayReceivedRequests(userDO: userDO)
                                    print("Enter the Request ID to Decline the Request:")
                                    if let input = readLine(), let requestId = Int(input) {
                                        
                                        if let requestAmountDO = RequestAmountController().getRequestDOById(requestId: requestId) {
                                            if requestAmountDO.status == .paid {
                                                print("Amount is Already Paid!")
                                                break whileLoop
                                            }
                                            
                                            if requestAmountDO.status == .declined {
                                                print("Request is Already Declined!")
                                                break whileLoop
                                            }
                                            
                                            RequestAmountController().updateRequestStatus(requestId: requestId, status: .declined)
                                            
                                        }
                                        
                                    }
                                default:
                                    print("Invalid Choice")
                                    break
                                }
                            }
                            
                        case 2:
                            break whileLoop
                        default:
                            print("Invalid choice. Please try again.")
                        }
                    }
                }
                
            case .sentRequests:
                displaySentRequest(userDO: userDO)
            }
        }
        
    }
}
