//
//  TransactionHistoryDO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 14/03/25.
//

import Foundation

class TransactionHistoryDO {
    var transactionID: Int
    var amount: Double
    var date: String
    var transactionType: String
    var senderUPIID: String
    var message: String?
    var receiverUPIID: String?  // Only for Account Transactions
    var serviceType: String?  // Only for Service Transactions
    var serviceName: String?  // Only for Service Transactions

    init(transactionID: Int, amount: Double, date: String, transactionType: String, senderUPIID: String, message: String?, receiverUPIID: String?, serviceType: String?, serviceName: String?) {
        self.transactionID = transactionID
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.senderUPIID = senderUPIID
        self.message = message
        self.receiverUPIID = receiverUPIID
        self.serviceType = serviceType
        self.serviceName = serviceName
    }
}

