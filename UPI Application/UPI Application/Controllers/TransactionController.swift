//
//  TransactionController.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 13/03/25.
//

import Foundation

class TransactionController {
    private let bankAccountDAO = BankAccountDAO()
    private let upiDAO = UPIDAO()
    private let transactionDAO = TransactionDAO()
    
    func getAllTransactionHistory(userDO: UserDO) -> [TransactionHistoryDO] {
        var transactions : [TransactionHistoryDO] = []
        let upiDOs: [UPIDO] = UPIController().getUPIIdsForUser(userDO: userDO)
        
        for upiDO in upiDOs {
            transactions += transactionDAO.getAllTransactionHistory(upiDO: upiDO)
        }
        
        return transactions
    }
    
}
