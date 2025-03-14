//
//  SplitBillController.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 13/03/25.
//

import Foundation

class SplitBillController {
    private let splitBillDAO = SplitBillDAO()
    
    func insertIntoSplitBill(splitBillParticipantsDOList: [SplitBillParticipantsDO]) {
        for splitBillParticipantDO in splitBillParticipantsDOList {
            splitBillDAO.insertIntoSplitBill(splitBillParticipantsDO: splitBillParticipantDO)
        }
    }
    
    func createSplitBill(splitBillDO: SplitBillDO) -> Int? {
        return splitBillDAO.createSplitBill(splitBillDO: splitBillDO)
    }
    
    func getSplitBillForUserInGroup(userDO: UserDO, groupId: Int) -> [SplitBillDO] {
        return splitBillDAO.getSplitBillForUserInGroup(userDO: userDO, groupId: groupId)
    }
    
    func isUserInSplit(splitBillId: Int, userDO: UserDO) -> Bool {
        return splitBillDAO.isUserInSplit(splitBillId: splitBillId, userDO: userDO)
    }
    
    func getSplitBillParticipants(splitBillId: Int) -> [SplitBillParticipantsDO] {
        return splitBillDAO.getSplitBillParticipants(splitBillId: splitBillId)
    }
    
    func getPayerUsernameForSplitBill(splitBillId: Int) -> String? {
        return splitBillDAO.getPayerUsernameForSplitBill(splitBillId: splitBillId)
    }
    
    func updateSplitBillStatus(splitBillId: Int, payeeUsername: String) -> Bool {
        return splitBillDAO.updateSplitBillStatus(splitBillId: splitBillId, payeeUsername: payeeUsername)
    }
    
    func isSplitBillPaid(splitBillId: Int, payeeUsername: String) -> Bool {
        return splitBillDAO.isSplitBillPaid(splitBillId: splitBillId, payeeUsername: payeeUsername)
    }
    
    func isPayerOfSplitBill(splitBillId: Int, payerUsername: String) -> Bool {
        return splitBillDAO.isPayerOfSplitBill(splitBillId: splitBillId, payerUsername: payerUsername)
    }
}
