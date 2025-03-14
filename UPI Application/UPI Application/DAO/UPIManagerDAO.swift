//
//  UPIManagerDAO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation
import FMDB

class UPIManagerDAO {
    private let db: FMDatabase
    
    init() {
        self.db = DatabaseConnection.shared.database
    }
    
    func verifyUPIPin(UPIID: String, UPIPin: Int) -> Bool {
        let queryAccountNumber = "SELECT account_number FROM UPI WHERE UPI_id = ?"
        var accountNumber : String
        do {
            let resultSet = try db.executeQuery(queryAccountNumber, values: [UPIID])
            if resultSet.next() {
                accountNumber = resultSet.string(forColumn: "account_number") ?? ""
            } else {
                return false
            }
        }
        catch {
            print("Error while fetching account number: \(error)")
            return false
        }
        
        let query = "SELECT * FROM UPIManager WHERE account_number = ? AND UPI_pin = ?"
        do {
            let resultSet = try db.executeQuery(query, values: [accountNumber, UPIPin])
            return resultSet.next()
        }
        catch {
            print("Error while fetching UPI Pin")
        }
        return false
    }
    
    func verifyUPIPin(bankAccountDO: BankAccountDO, UPIPin: Int) -> Bool {
        let query = "SELECT UPI_pin FROM UPIManager WHERE account_number = ?"
        do {
            let resultSet = try db.executeQuery(query, values: [bankAccountDO.accountNumber])
            if resultSet.next() {
                return resultSet.int(forColumn: "UPI_pin") == UPIPin
            }
        } catch {
            print("Error while fetching UPI Pin: \(error)")
        }
        
        return false
    }
    
    
    func insertUPIManager(_ upiManagerDO : UPIManagerDO) -> Bool {
        let query = "INSERT INTO UPIManager (account_Number, UPI_pin, is_primary) VALUES (?, ?, ?)"
        do {
            try db.executeQuery(query, values: [upiManagerDO.accountNumber, upiManagerDO.upiPin, upiManagerDO.isPrimary])
            return true
        }
        catch {
            print("Error while inserting UPI Manager: \(error.localizedDescription)")
            return false
        }
    }
    
    func getUPIManager(_ accountNumber: String) -> UPIManagerDO? {
        let query = "SELECT * FROM UPIManager WHERE account_Number = ?"
        do {
            let resultSet = try db.executeQuery(query, values: [accountNumber])
            if resultSet.next() {
                return UPIManagerDO(
                    accountNumber: resultSet.string(forColumn: "account_number") ?? "",
                    upiPin: Int(resultSet.int(forColumn: "UPI_pin")),
                    isPrimary: resultSet.bool(forColumn: "is_primary")
                )
            }
        }
        catch {
            print("Error while fetching UPI Manager: \(error.localizedDescription)")
        }
        return nil
    }
    
    func deleteUPIManager(_ accountNumber: String) -> Bool {
        let query = "DELETE FROM UPIManager WHERE account_Number = ?"
        do {
            try db.executeQuery(query, values: [accountNumber])
            return true
        }
        catch {
            print("Error while deleting UPI Manager: \(error.localizedDescription)")
            return false
        }
    }
}
