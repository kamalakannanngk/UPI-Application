//
//  AccountTransaction.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation

class AccountTransactionDO {
    var transactionId: Int
    var receiverUPIID: String
    
    init(transactionId: Int, receiverUPIID: String) {
        self.transactionId = transactionId
        self.receiverUPIID = receiverUPIID
    }
}
