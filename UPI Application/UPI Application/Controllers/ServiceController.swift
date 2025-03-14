//
//  ServiceController.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 12/03/25.
//

import Foundation

class ServiceController {
    private let bankAccountDAO: BankAccountDAO
    private let transactionDAO: TransactionDAO
    private let autoRenewalDAO: AutoRenewalDAO
    
    init() {
        bankAccountDAO = BankAccountDAO()
        transactionDAO = TransactionDAO()
        autoRenewalDAO = AutoRenewalDAO()
    }
    
    func sendMoneyForService(bankAccountDO: BankAccountDO, UPIID: String, UPIPIN: Int, amount: Double, serviceType: ServiceType, serviceName: String, isAutoRenewal: Bool) {
        
        if UPIController().verifyUPIPIN(UPIID: UPIID, UPIPIN: UPIPIN) {
            if bankAccountDAO.checkBalance(bankAccountDO: bankAccountDO, amount: amount) {
                if !transactionDAO.hasReachedDailyTransactionLimit(bankAccountDO: bankAccountDO, amount: amount) {
                    if !bankAccountDAO.hasReachedTransactionLimit(accountType: bankAccountDO.accountType, amount: amount) {
                        
                        // Insert Transaction
                        let transactionDO = TransactionDO(amount: amount, transactionType: .service, senderUPIID: UPIID)
                        guard let transactionId = transactionDAO.insertTransaction(transactionDO: transactionDO) else {
                            print("Found Transaction ID Nil!")
                            return
                        }
                        
                        // Insert Service Transaction
                        let serviceTransactionDO = ServiceTransactionDO(transactionId: transactionId, serviceType: serviceType, serviceName: serviceName)
                        _ = transactionDAO.insertServiceTransaction(serviceTransactionDO: serviceTransactionDO)
                        
                        // Update Balance
                        bankAccountDAO.updateBalance(accountNumber: bankAccountDO.accountNumber, amount: amount, isAddition: false)
                        
                        // Set Auto Renewal
                        if isAutoRenewal {
                            let autoRenewalDO = AutoRenewalDO(UPIID: UPIID, transactionId: transactionId)
                            if let autoRenewalId = autoRenewalDAO.insertAutoRenewal(autoRenewalDO: autoRenewalDO) {
                                print("Auto Renewal Set Successfully! Auto Renewal ID: \(autoRenewalId)")                                
                            }
                        }
                        
                        
                    } else {
                        print("Amount Exceeds Transaction Limit Per Transaction!")
                    }
                } else {
                    print("Reached daily transaction limit!")
                }
            } else {
                print("Insufficient balance!")
            }
        } else {
            print("Incorrect UPIPIN!")
        }
        
    }
}
