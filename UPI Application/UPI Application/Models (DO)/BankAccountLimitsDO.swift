//
//  BankAccountLimitsDO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 12/03/25.
//

import Foundation

class BankAccountLimitsDO {
    var accountType: AccountType
    var transactionLimitPerday: Double
    var transactionLimitPerTransaction: Double
    var minimumBalance: Double
    
    init(accountType: AccountType, transactionLimitPerday: Double, transactionLimitPerTransaction: Double, minimumBalance: Double) {
        self.accountType = accountType
        self.transactionLimitPerday = transactionLimitPerday
        self.transactionLimitPerTransaction = transactionLimitPerTransaction
        self.minimumBalance = minimumBalance
    }
}
