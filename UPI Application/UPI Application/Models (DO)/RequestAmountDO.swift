//
//  RequestAmountDO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation

enum RequestStatus: String {
    case pending = "Pending"
    case paid = "Paid"
    case declined = "Declined"
}

class RequestAmountDO {
    var requestId: Int?
    var senderUPIId: String
    var receiverUPIId: String
    var amount: Double
    var status: RequestStatus?
    
    init(requestId: Int? = nil, senderUPIId: String, receiverUPIId: String, amount: Double, status: RequestStatus? = nil) {
        self.requestId = requestId
        self.senderUPIId = senderUPIId
        self.receiverUPIId = receiverUPIId
        self.amount = amount
        self.status = status
    }
}
