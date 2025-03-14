//
//  UPIDO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation

class UPIDO {
    var upiId: String
    var accountNumber: String
    var isPrimary: Bool
    
    init(upiId: String, accountNumber: String, isPrimary: Bool = false) {
        self.upiId = upiId
        self.accountNumber = accountNumber
        self.isPrimary = isPrimary
    }
}
