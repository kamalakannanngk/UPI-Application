//
//  SplitBillParticipantsDO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 13/03/25.
//

import Foundation

enum SplitBillStatus: String {
    case pending = "Pending"
    case paid = "Paid"
}

class SplitBillParticipantsDO {
    var splitBillId: Int
    var payeeUsername: String
    var amount: Double
    var status: SplitBillStatus?
    
    init(splitBillId: Int, payeeUsername: String, amount: Double, status: SplitBillStatus? = nil) {
        self.splitBillId = splitBillId
        self.payeeUsername = payeeUsername
        self.amount = amount
        self.status = status
    }
    
}
