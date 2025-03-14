//
//  SplitBillDO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation

class SplitBillDO {
    var splitBillID: Int?
    var groupID: Int
    var payerUsername: String
    var totalAmount: Double
    
    init(splitBillID: Int? = nil, groupID: Int, payerUsername: String, totalAmount: Double) {
        self.splitBillID = splitBillID
        self.groupID = groupID
        self.payerUsername = payerUsername
        self.totalAmount = totalAmount
    }
}
