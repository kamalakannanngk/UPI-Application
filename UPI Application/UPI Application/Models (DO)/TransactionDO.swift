//
//  TransactionDO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation

enum TransactionType : String {
    case account = "Account"
    case service = "Service"
    case splitBill = "Split Bill"
}

class TransactionDO {
    var transactionId: Int?
    var amount: Double
    var date: String?
    var transactionType : TransactionType
    var senderUPIID: String
    var message: String?
    
    init(transactionId: Int? = nil, amount: Double, date: String? = nil, transactionType: TransactionType, senderUPIID: String, message: String? = nil) {
        self.transactionId = transactionId
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.senderUPIID = senderUPIID
        self.message = message
    }
}
