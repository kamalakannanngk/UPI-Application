//
//  SplitBillDAO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 13/03/25.
//

import Foundation

class SplitBillDAO {
    private let db = DatabaseConnection.shared.database
    
    func insertIntoSplitBill(splitBillParticipantsDO: SplitBillParticipantsDO) {
        let query = "INSERT INTO SplitBillParticipants (split_bill_id, payee_user_name, amount_to_pay) VALUES (?, ?, ?)"
        
        do {
            try db.executeUpdate(query, values: [splitBillParticipantsDO.splitBillId, splitBillParticipantsDO.payeeUsername, splitBillParticipantsDO.amount])
        } catch {
            print("Error while inserting data into SplitBillParticipants table: \(error)")
        }
    }
    
    func createSplitBill(splitBillDO: SplitBillDO) -> Int? {
        let query = "INSERT INTO SplitBill (group_id, payer_user_name, total_amount) VALUES (?, ?, ?)"
        
        do {
            try db.executeUpdate(query, values: [splitBillDO.groupID, splitBillDO.payerUsername, splitBillDO.totalAmount])
            return Int(db.lastInsertRowId)
        } catch {
            print("Error while creating split bill \(error)")
        }
        
        return nil
    }
    
    func getSplitBillForUserInGroup(userDO: UserDO, groupId: Int) -> [SplitBillDO] {
        var splitBillDOs: [SplitBillDO] = []
        let query = """
        SELECT DISTINCT sb.split_bill_id, sb.group_id, sb.payer_user_name, sb.total_amount
        FROM SplitBill sb
        JOIN SplitBillParticipants sbp
        ON sb.split_bill_id = sbp.split_bill_id
        WHERE sb.group_id = ? 
        AND (sb.payer_user_name = ? OR sbp.payee_user_name = ?);
        """
        
        do {
            let resultSet = try db.executeQuery(query, values: [groupId, userDO.username, userDO.username])
            while resultSet.next() {
                let splitBillDO = SplitBillDO(splitBillID: Int(resultSet.int(forColumn: "split_bill_id")),
                                              groupID: Int(resultSet.int(forColumn: "group_id")),
                                              payerUsername: resultSet.string(forColumn: "payer_user_name") ?? "",
                                              totalAmount: Double(resultSet.double(forColumn: "total_amount")))
                splitBillDOs.append(splitBillDO)
            }
            
        } catch {
            print("Error while fetching split bill for user \(error)")
        }
        
        return splitBillDOs
    }
    
    func isUserInSplit(splitBillId: Int, userDO: UserDO) -> Bool {
        let query = "SELECT * FROM SplitBillParticipants WHERE split_bill_id = ? AND payee_user_name = ?"
        
        do {
            let resultSet = try db.executeQuery(query, values: [splitBillId, userDO.username])
            return resultSet.next()
        } catch {
            print("Error while fetching split bill for user \(error)")
        }
        
        return false
    }
    
    func getSplitBillParticipants(splitBillId: Int) -> [SplitBillParticipantsDO] {
        var splitBillParticipants: [SplitBillParticipantsDO] = []
        let query = "SELECT * FROM SplitBillParticipants WHERE split_bill_id = ?"
        
        do {
            let resultSet = try db.executeQuery(query, values: [splitBillId])
            while resultSet.next() {
                let statusString = resultSet.string(forColumn: "status") ?? ""
                let status = SplitBillStatus(rawValue: statusString)
                let splitBillParticipantsDO = SplitBillParticipantsDO(splitBillId: Int(resultSet.int(forColumn: "split_bill_id")),
                                                                      payeeUsername: resultSet.string(forColumn: "payee_user_name") ?? "",
                                                                      amount: Double(resultSet.double(forColumn: "amount_to_pay")),
                                                                      status: status)
                splitBillParticipants.append(splitBillParticipantsDO)
            }
        } catch {
            print("Error while fetching split bill for user \(error)")
        }
        
        return splitBillParticipants
    }
    
    func getPayerUsernameForSplitBill(splitBillId: Int) -> String? {
        let query = "SELECT payer_user_name FROM SplitBill WHERE split_bill_id = ?;"
        
        do {
            let resultSet = try db.executeQuery(query, values: [splitBillId])
            if resultSet.next() {
                return resultSet.string(forColumn: "payer_user_name")
            }
        } catch {
            print("Error while querying for payer username: \(error)")
        }
        
        return nil
    }
    
    func updateSplitBillStatus(splitBillId: Int, payeeUsername: String) -> Bool {
        let query = """
        UPDATE SplitBillParticipants
        SET status = 'Paid'
        WHERE split_bill_id = ? AND payee_user_name = ?
        """
        
        do {
            try db.executeUpdate(query, values: [splitBillId, payeeUsername])
            return true
        } catch {
            print("Error while updating split bill status: \(error)")
        }
        
        return false
    }
    
    func isSplitBillPaid(splitBillId: Int, payeeUsername: String) -> Bool {
        let query = """
        SELECT * FROM SplitBillParticipants
        WHERE split_bill_id = ? AND payee_user_name = ? AND status = ?
        """
        
        do {
            let resultSet = try db.executeQuery(query, values: [splitBillId, payeeUsername, "Paid"])
            return resultSet.next()
        } catch {
            print("Error while checking split bill status: \(error)")
        }
        
        return false
    }
    
    func isPayerOfSplitBill(splitBillId: Int, payerUsername: String) -> Bool {
        let query = "SELECT * FROM SplitBill WHERE split_bill_id = ? AND payer_user_name = ?"
        
        do {
            let resultSet = try db.executeQuery(query, values: [splitBillId, payerUsername])
            return resultSet.next()
        } catch {
            print("Error while checking split bill status: \(error)")
        }
        
        return false
    }
}
