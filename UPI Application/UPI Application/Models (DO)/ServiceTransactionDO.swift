//
//  ServiceTransaction.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation

enum ServiceType: String {
    case subscription = "Subscription"
    case mobileRecharge = "Mobile Recharge"
    case billPayment = "Bill Payment"
}

class ServiceTransactionDO {
    var transactionId: Int
    var serviceType: ServiceType
    var serviceName: String
    
    init(transactionId: Int, serviceType: ServiceType, serviceName: String) {
        self.transactionId = transactionId
        self.serviceType = serviceType
        self.serviceName = serviceName
    }
}
