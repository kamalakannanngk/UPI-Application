//
//  BankAccountDO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation
enum AccountType: String {
    case normal = "Normal"
    case business = "Business"
    
    static func from(number: Int) -> AccountType? {
        switch number {
        case 1: return .normal
        case 2: return .business
        default: return nil
        }
    }
}

class BankAccountDO {
    var accountNumber: String
    var username: String?
    var name: String
    var ifscCode: String
    var balance: Double
    var phoneNumber: String
    var accountType: AccountType
    
    init(accountNumber: String, username: String? = nil, name: String, ifscCode: String, balance: Double, phoneNumber: String, accountType: AccountType) {
        self.accountNumber = accountNumber
        self.username = username
        self.name = name
        self.ifscCode = ifscCode
        self.balance = balance
        self.phoneNumber = phoneNumber
        self.accountType = accountType
    }
    
}
