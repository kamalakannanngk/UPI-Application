//
//  AutoRenewalDO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation

class AutoRenewalDO {
    var autoRenewalId: Int?
    var UPIID: String
    var transactionId: Int
    var nextRenewalDate: String?
    
    init(autoRenewalId: Int? = nil, UPIID: String, transactionId: Int, nextRenewalDate: String? = nil) {
        self.autoRenewalId = autoRenewalId
        self.UPIID = UPIID
        self.transactionId = transactionId
        self.nextRenewalDate = nextRenewalDate
    }
}
