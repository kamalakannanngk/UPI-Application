//
//  BankManager.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation

class BankController {
    private let bankAccountDAO: BankAccountDAO
    
    init() {
        bankAccountDAO = BankAccountDAO()
    }

    
    func getBankAccountDetails(accountNumber: String) -> BankAccountDO? {
        return bankAccountDAO.getBankAccount(accountNumber)
    }
    
    func verifyBankAccount(bankName: BankName, accountNumber: String, userDO: UserDO) -> Bool {
        return bankAccountDAO.verifyBankAccount(bankName: bankName, accountNumber: accountNumber, userDO: userDO)
    }
    
    func linkBankAccount(username: String, bankName: BankName, accountNumber: String, UPIPin: Int) {
        bankAccountDAO.linkBankAccount(username: username, bankName: bankName, accountNumber: accountNumber, UPIPin: UPIPin)
    }
    
    func isLinkedWithBankAccount(userDO: UserDO) -> Bool {
        let bankAccounts = bankAccountDAO.getBankAccountsForUser(username: userDO.username)
        return bankAccounts.count > 0
    }
    
    func getBankAccountsForUser(username: String) -> [BankAccountDO] {
        return bankAccountDAO.getBankAccountsForUser(username: username)
    }
    
    func setBankAccountAsPrimary(accountNumber: String, username: String) {
        if bankAccountDAO.verifyBankAccountWithUser(accountNumber: accountNumber, username: username) {
            bankAccountDAO.setBankAccountAsPrimary(accountNumber: accountNumber)
        }
        else {
            print("You do not have access to this account!")
        }
    }
    
    func verifyUPIPin(bankAccountDO: BankAccountDO, UPIPin: Int) -> Bool {
        return UPIManagerDAO().verifyUPIPin(bankAccountDO: bankAccountDO, UPIPin: UPIPin)
    }
}
