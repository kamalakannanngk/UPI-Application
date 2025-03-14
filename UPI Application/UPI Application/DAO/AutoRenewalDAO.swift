//
//  AutoRenewalDAO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation
import FMDB

class AutoRenewalDAO {
    private let db: FMDatabase
    
    init() {
        self.db = DatabaseConnection.shared.database
    }
    
    func insertAutoRenewal(autoRenewalDO: AutoRenewalDO) -> Int? {
        let query = "INSERT INTO AutoRenewal (UPI_id, transaction_id, next_renewal_date) VALUES (?, ?, ?)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let nextYearDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) else {
            print("Error: Unable to calculate next renewal date.")
            return nil
        }
        
        let updatedNextRenewalDate = dateFormatter.string(from: nextYearDate)
        
        do {
            try db.executeUpdate(query, values: [autoRenewalDO.UPIID, autoRenewalDO.transactionId, updatedNextRenewalDate])
            return Int(db.lastInsertRowId)
        } catch {
            print("Error while inserting AutoRenewal: \(error.localizedDescription)")
            return nil
        }
    }

    
    func getAutoRenewalById(autoRenewalId: Int) -> AutoRenewalDO? {
        let query = "SELECT * FROM AutoRenewal WHERE auto_renewal_id = ?"
        do {
            let resultSet = try db.executeQuery(query, values: [autoRenewalId])
            if resultSet.next() {
                return AutoRenewalDO(
                    autoRenewalId: autoRenewalId,
                    UPIID: resultSet.string(forColumn: "UPI_id") ?? "",
                    transactionId: Int(resultSet.int(forColumn: "transaction_id")),
                    nextRenewalDate: resultSet.string(forColumn: "next_renewal_date") ?? ""
                )
            }
        }
        catch {
            print("Error while fetching AutoRenewal: \(error.localizedDescription)")
        }
        return nil
    }
    
    func getAutoRenewalByUser(upiId: String) async -> ([AutoRenewalDO], [String], [Double]) {
        var autoRenewals: [AutoRenewalDO] = []
        var serviceNames: [String] = []
        var amounts: [Double] = []
        
        let query = """
        SELECT ar.auto_renewal_id, ar.UPI_id, ar.transaction_id, ar.next_renewal_date, st.service_name, t.amount FROM 
        AutoRenewal ar
        JOIN ServiceTransaction st ON ar.transaction_id = st.transaction_id
        JOIN "Transaction" t ON ar.transaction_id = t.transaction_id
        WHERE ar.UPI_id = ?
        """
        
        do {
            let resultSet = try db.executeQuery(query, values: [upiId])
            while resultSet.next() {
                let autoRenewalDO = AutoRenewalDO(
                    autoRenewalId: Int(resultSet.int(forColumn: "auto_renewal_id")),
                    UPIID: resultSet.string(forColumn: "UPI_id") ?? "",
                    transactionId: Int(resultSet.int(forColumn: "transaction_id")),
                    nextRenewalDate: resultSet.string(forColumn: "next_renewal_date") ?? ""
                )
                let serviceName = resultSet.string(forColumn: "service_name") ?? ""
                let amount = resultSet.double(forColumn: "amount")
                
                autoRenewals.append(autoRenewalDO)
                serviceNames.append(serviceName)
                amounts.append(amount)
            }
        } catch {
            print("Error while fetching AutoRenewal: \(error.localizedDescription)")
        }
        
        return (autoRenewals, serviceNames, amounts)
    }
    
    func getDueAutoRenewals() async -> ([AutoRenewalDO], [Double]) {
        let query = """
        SELECT at.auto_renewal_id, at.UPI_id, at.next_renewal_date, t.amount
        FROM AutoRenewal at
        JOIN Transaction t
        ON at.transaction_id = t.transaction_id
        WHERE next_renewal_date <= datetime('now')
        """
        
        var (dueRenewals, amounts) : ([AutoRenewalDO], [Double]) = ([], [])
        
        do {
            let resultSet = try db.executeQuery(query, values: [])
            while resultSet.next() {
                let autoRenewal = AutoRenewalDO(
                    autoRenewalId: Int(resultSet.int(forColumn: "auto_renewal_id")),
                    UPIID: resultSet.string(forColumn: "UPI_id") ?? "",
                    transactionId: Int(resultSet.int(forColumn: "transaction_id")),
                    nextRenewalDate: resultSet.string(forColumn: "next_renewal_date") ?? ""
                )
                let amount = Double(resultSet.double(forColumn: "amount"))
                
                dueRenewals.append(autoRenewal)
                amounts.append(amount)
            }
        } catch {
            print("Error fetching due auto-renewals: \(error.localizedDescription)")
        }
        
        return (dueRenewals, amounts)
    }
    
    func updateNextRenewalDate(autoRenewalID: Int) async {
        let query = """
        UPDATE AutoRenewal 
        SET next_renewal_date = datetime(next_renewal_date, '+1 month') 
        WHERE auto_renewal_id = ?
        """

        do {
            try db.executeUpdate(query, values: [autoRenewalID])
        } catch {
            print("Error updating next renewal date: \(error.localizedDescription)")
        }
    }
    
    func cancelAutoRenewal(autoRenewalID: Int) async -> Bool {
        let query = "DELETE FROM AutoRenewal WHERE auto_renewal_id = ?"
        
        do {
            try db.executeUpdate(query, values: [autoRenewalID])
            return true
        } catch {
            print("Error canceling auto renewal: \(error.localizedDescription)")
        }
        
        return false
    }
    
    func isAutoRenewalExist(autoRenewalID: Int) async -> Bool {
        let query = "SELECT * FROM AutoRenewal WHERE auto_renewal_id = ?"
        
        do {
            let resultSet = try db.executeQuery(query, values: [autoRenewalID])
            return resultSet.next()
        } catch {
            print("Error checking auto renewal exist: \(error.localizedDescription)")
        }
        
        return false
    }
    
}
