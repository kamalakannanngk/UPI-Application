//
//  UPIManagerDO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation

class UPIManagerDO {
    var accountNumber: String
    var upiPin: Int
    var isPrimary: Bool
    
    init(accountNumber: String, upiPin: Int, isPrimary: Bool) {
        self.accountNumber = accountNumber
        self.upiPin = upiPin
        self.isPrimary = isPrimary
    }
}
