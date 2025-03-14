//
//  UPIController.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 10/03/25.
//

import Foundation

class UPIController {
    private let bankAccountDAO : BankAccountDAO
    private let upiDAO : UPIDAO
    private let upiManagerDAO : UPIManagerDAO
    private let transactionDAO : TransactionDAO
    
    init() {
        bankAccountDAO = BankAccountDAO()
        upiDAO = UPIDAO()
        transactionDAO = TransactionDAO()
        upiManagerDAO = UPIManagerDAO()
    }
    
    func sendMoneyViaUPI(senderBankAccountDO: BankAccountDO, receiverUPIID: String, amount: Double, UPIPIN: Int, message: String?) {
        
        if bankAccountDAO.checkBalance(bankAccountDO: senderBankAccountDO, amount: amount) {
            if !bankAccountDAO.hasReachedTransactionLimit(accountType: senderBankAccountDO.accountType, amount: amount) {
                
                let senderUPIID = getPrimaryUPI(accountNumber: senderBankAccountDO.accountNumber)
                if isUPIExist(UPIID: receiverUPIID) {
                    if upiManagerDAO.verifyUPIPin(UPIID: senderUPIID, UPIPin: UPIPIN) {
                        
                        if !transactionDAO.hasReachedDailyTransactionLimit(bankAccountDO: senderBankAccountDO, amount: amount) {
                            
                            // Inserting Transactions
                            let transactionDO = TransactionDO(amount: amount, transactionType: .account, senderUPIID: senderUPIID, message: message)
                            
                            guard let transactionId = transactionDAO.insertTransaction(transactionDO: transactionDO) else {
                                print("Transaction ID is nil!")
                                return
                            }
                            
                            let accountTransactionDo = AccountTransactionDO(transactionId: transactionId, receiverUPIID: receiverUPIID)
                            transactionDAO.insertAccountTransaction(accountTransactionDO: accountTransactionDo)
                            
                            // Updating Balance
                            guard let receiverAccountNumber = upiDAO.getAccountNumber(upiId: receiverUPIID) else {
                                print("Receiver Account Number not found!")
                                return
                            }
                            
                            bankAccountDAO.updateBalance(accountNumber: senderBankAccountDO.accountNumber, amount: amount, isAddition: false)
                            bankAccountDAO.updateBalance(accountNumber: receiverAccountNumber, amount: amount, isAddition: true)
                            print("Amount Sent Successfully!")
                        
                        } else {
                            print("Amount exceeds daily transaction limit!")
                        }
                        
                    } else {
                        print("Incorrect UPI PIN!")
                    }
                } else {
                    print("UPI ID not exist")
                }
            } else {
                print("Amount exceeds transaction limit per transaction!")
            }
        } else {
            print("Insufficient Balance!")
        }
        
        
    }
    
    func verifyUPIPIN(UPIID: String, UPIPIN: Int) -> Bool {
        if isUPIExist(UPIID: UPIID) {
            if UPIManagerDAO().verifyUPIPin(UPIID: UPIID, UPIPin: UPIPIN) {
                return true
            } else {
                print("Incorrect UPI PIN!")
            }
        } else {
            print("UPI ID does not exist!")
        }
        
        return false
    }
    
    func sendMoneyViaMobileNumber(senderBankAccountDO: BankAccountDO, receiverMobileNumber: String, amount: Double, UPIPIN: Int, message: String?) {
        if let receiverUPIID = upiDAO.getUPIID(phoneNumber: receiverMobileNumber) {
            sendMoneyViaUPI(senderBankAccountDO: senderBankAccountDO, receiverUPIID: receiverUPIID, amount: amount, UPIPIN: UPIPIN, message: message)
        }
        else {
            print("Receiver UPI ID is nil!")
        }
    }
    
    func setUPIPrimary(UPIID: String) {
        upiDAO.setUPIPrimary(upiId: UPIID)
    }
    
    func getPrimaryUPI(accountNumber: String) -> String {
        if let primaryUPI = upiDAO.getPrimaryUPI(accountNumber: accountNumber) {
            return primaryUPI
        }
        return ""
    }
    
    func addUPI(userDO: UserDO, bankAccountDO: BankAccountDO) {
        upiDAO.insertUPI(userDO: userDO, bankAccountDO: bankAccountDO)
    }
    
    func isUPIExist(UPIID: String) -> Bool {
        upiDAO.isUPIExists(upiId: UPIID)
    }
    
    func getLinkedUPIs(bankAccountDO: BankAccountDO) -> [UPIDO] {
        return upiDAO.getLinkedUPIs(bankAccountDO: bankAccountDO)
    }
    
    func getUPIByUserName(userDO: UserDO) -> String? {
        if let upiId = upiDAO.getUPIID(phoneNumber: userDO.phoneNumber) {
            return upiId
        }
        return nil
    }
    
    func getUserNameByUPI(upiId: String) -> String? {
        if let username = upiDAO.getUserNameByUPI(upiId: upiId) {
            return username
        } else {
            print("User not found for UPI ID: \(upiId)")
        }
        return nil
    }
    
    func getUPIIdsForUser(userDO: UserDO) -> [UPIDO] {
        let bankAccounts: [BankAccountDO] = bankAccountDAO.getBankAccountsForUser(username: userDO.username)
        var upis: [UPIDO] = []
        
        for bankAccount in bankAccounts {
            let upiDO = upiDAO.getLinkedUPIs(bankAccountDO: bankAccount)
            upis += upiDO
        }
        
        return upis
    }
    
}
