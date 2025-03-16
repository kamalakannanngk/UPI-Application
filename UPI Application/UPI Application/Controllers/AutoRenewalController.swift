//
//  AutoRenewalController.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 12/03/25.
//



import Foundation

actor AutoRenewalController {
    private let autoRenewalDAO = AutoRenewalDAO()
    private let bankAccountDAO = BankAccountDAO()
    private let upiDAO = UPIDAO()
    private var autoRenewalTimer: DispatchSourceTimer?
    
    init() {
        Task {
            await self.startAutoRenewalProcessing()
        }
    }
    
    func getAutoRenewalsForUser(userDO: UserDO) async -> ([AutoRenewalDO], [String], [Double]) {
        var autoRenewalDOs: [AutoRenewalDO] = []
        var serviceNames: [String] = []
        var amounts: [Double] = []
        let upiDOs = UPIController().getUPIIdsForUser(userDO: userDO)
        
        for upiDO in upiDOs {
            let (renewals, names, amount) = await autoRenewalDAO.getAutoRenewalByUser(upiId: upiDO.upiId)
            autoRenewalDOs += renewals
            serviceNames += names
            amounts += amount
        }
        
        return (autoRenewalDOs, serviceNames, amounts)
    }
    
    func processAutoRenewals() async {
        let (dueRenewals, amounts) = await autoRenewalDAO.getDueAutoRenewals()
        
        for (index, renewal) in dueRenewals.enumerated() {
            let upiID = renewal.UPIID
            let amount = amounts[index]
            
            guard let bankAccountDO = upiDAO.getBankAccountDOByUPI(upiId: upiID) else {
                print("Found nil while retrieving BankAccountDO")
                continue
            }
            
            if !(bankAccountDAO.checkBalance(bankAccountDO: bankAccountDO, amount: amount)) {
                print("Insufficient balance for auto-renewal of UPI: \(upiID)")
                continue
            }
            
            bankAccountDAO.updateBalance(accountNumber: bankAccountDO.accountNumber, amount: amount, isAddition: false)
            
            if let autoRenewalId = renewal.autoRenewalId {
                await autoRenewalDAO.updateNextRenewalDate(autoRenewalID: autoRenewalId)
            }
            
            print("Auto-renewal successful for UPI: \(upiID), Amount: ₹\(amount)")
        }
    }
    
    func isAutoRenewalExist(autoRenewalID: Int) async -> Bool {
        return await autoRenewalDAO.isAutoRenewalExist(autoRenewalID: autoRenewalID)
    }
    
    func cancelAutoRenewal(autoRenewalId: Int) async -> Bool {
        if await autoRenewalDAO.isAutoRenewalExist(autoRenewalID: autoRenewalId) {
            return await autoRenewalDAO.cancelAutoRenewal(autoRenewalID: autoRenewalId)
        } else {
            print("Auto Renewal not found")
        }
        return false
    }
    
    func startAutoRenewalProcessing() {
        let queue = DispatchQueue.global(qos: .background)
        self.autoRenewalTimer = DispatchSource.makeTimerSource(queue: queue)
        
        self.autoRenewalTimer?.schedule(deadline: .now(), repeating: 5.0)

        self.autoRenewalTimer?.setEventHandler {
            print("Checking for due auto-renewals...")
            Task {
                await self.processAutoRenewals()
            }
        }
        
        self.autoRenewalTimer?.resume()
    }
}

