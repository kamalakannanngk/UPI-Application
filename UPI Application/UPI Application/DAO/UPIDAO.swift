//
//  UPIDAO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation
import FMDB

class UPIDAO {
    private let db: FMDatabase

    init() {
        self.db = DatabaseConnection.shared.database
    }

    func insertUPI(userDO: UserDO, bankAccountDO: BankAccountDO) {
        let upiCount = getUPIIDCount(accountNumber: bankAccountDO.accountNumber)
        let upi = "\(userDO.username)\(upiCount)@ok\(bankAccountDO.name)"
        
        let query = "INSERT INTO UPI (UPI_id, account_number) VALUES (?, ?);"
        do {
            try db.executeUpdate(query, values: [upi, bankAccountDO.accountNumber])
            
        } catch {
            print("Error inserting UPI ID: \(error.localizedDescription)")
        }
    }
    
    func getUPIIDCount(accountNumber: String) -> Int {
        let query = "SELECT COUNT(UPI_id) AS upi_count FROM UPI WHERE account_number = ?"
        do {
            let resultSet = try db.executeQuery(query, values: [accountNumber])
            
            if resultSet.next() {
                let upiCount = resultSet.int(forColumn: "upi_count")
                return Int(upiCount)
            }
        } catch {
            print("Error occurred while fetching UPI count")
        }
        return 0
    }

    func isUPIExists(upiId: String) -> Bool {
        let query = "SELECT COUNT(*) FROM UPI WHERE UPI_id = ?;"
        do {
            let resultSet = try db.executeQuery(query, values: [upiId])
            if resultSet.next() {
                let count = resultSet.int(forColumnIndex: 0)
                return count > 0
            }
        } catch {
            print("Error checking if UPI ID exists: \(error.localizedDescription)")
        }
        return false
    }
    
    func getLinkedUPIs(bankAccountDO: BankAccountDO) -> [UPIDO] {
        var upiList: [UPIDO] = []
        let query = "SELECT * FROM UPI WHERE account_number = ?"
        do {
            let resultSet = try db.executeQuery(query, values: [bankAccountDO.accountNumber])
            while resultSet.next() {
                upiList.append(UPIDO(
                    upiId: resultSet.string(forColumn: "UPI_id") ?? "",
                    accountNumber: resultSet.string(forColumn: "account_number") ?? "",
                    isPrimary: resultSet.bool(forColumn: "is_primary")
                ))
            }
        } catch {
            print("Error fetching linked UPI IDs: \(error.localizedDescription)")
        }
        
        return upiList
    }
    
    func setUPIPrimary(upiId: String) {
        let query = "UPDATE UPI SET is_primary = 0 WHERE is_primary = 1;"
        do {
            try db.executeUpdate(query, values: [])
        } catch {
            print("Error setting UPI as primary: \(error.localizedDescription)")
        }
        
        let updateQuery = "UPDATE UPI SET is_primary = 1 WHERE UPI_id = ?;"
        do {
            try db.executeUpdate(updateQuery, values: [])
        } catch {
            print("Error setting UPI as primary: \(error.localizedDescription)")
        }
    }
    
    func getPrimaryUPI(accountNumber: String) -> String? {
        let query = "SELECT UPI_id FROM UPI WHERE account_number = ? AND is_primary = ?"
        do {
            let resultSet = try db.executeQuery(query, values: [accountNumber, 1])
            if resultSet.next() {
                return resultSet.string(forColumn: "UPI_id")
            } else {
                print("Primary UPI ID for Account Number: \(accountNumber) not found")
            }
        } catch {
            print("Error fetching primary UPI: \(error.localizedDescription)")
        }
        return nil
    }
    
    func getPrimaryUPI(phoneNumber: String) -> String? {
        let query = """
            SELECT U.UPI_id
            FROM UPI U
            JOIN UPIManager UM ON U.account_number = UM.account_number
            JOIN BankAccount BA ON UM.account_number = BA.account_number
            WHERE BA.phone_number = ? 
            AND UM.is_primary = 1 
            AND U.is_primary = 1;
            """
        
        do {
            let resultSet = try db.executeQuery(query, values: [phoneNumber])
            if resultSet.next() {
                return resultSet.string(forColumn: "UPI_id")
            }
        } catch {
            print("Error while fetching primary UPI: \(error.localizedDescription)")
        }
        return nil
    }
    
    func getAccountNumber(upiId: String) -> String? {
        let query = "SELECT account_number FROM UPI WHERE UPI_id = ?"
        do {
            let resultSet = try db.executeQuery(query, values: [upiId])
            if resultSet.next() {
                return resultSet.string(forColumn: "account_number")
            } else {
                print("Account Number does not exist for UPI ID: \(upiId)")
                
            }
        } catch {
            print("Error fetching Account Number in the UPI Table: \(error.localizedDescription)")
        }
        return nil
    }
    
    func getUPIID(phoneNumber: String) -> String? {
        let query = """
                SELECT UPI.UPI_id
                FROM UPI
                INNER JOIN BankAccount ON UPI.account_number = BankAccount.account_number
                WHERE BankAccount.phone_number = ?;
            """
        do {
            let resultSet = try db.executeQuery(query, values: [phoneNumber])
            if resultSet.next() {
                return resultSet.string(forColumn: "UPI_id")
            }
        } catch {
            print("Error fetching UPI ID for phone number \(phoneNumber): \(error)")
        }
        return nil

    }
    
    func getUserNameByUPI(upiId: String) -> String? {
        let query = """
            SELECT BankAccount.username
            FROM BankAccount
            INNER JOIN UPI on BankAccount.account_number = UPI.account_number
            WHERE UPI.UPI_id = ?
            """
        do {
            let resultSet = try db.executeQuery(query, values: [upiId])
            if resultSet.next() {
                return resultSet.string(forColumn: "username")
            }
        } catch {
            print("Error fetching username for UPI \(upiId): \(error)")
        }
        return nil
    }
    
    func getBankAccountDOByUPI(upiId: String) -> BankAccountDO? {
        let query = """
            SELECT BankAccount.account_number, BankAccount.user_name, 
                   BankAccount.name, BankAccount.ifsc, 
                   BankAccount.balance, BankAccount.phone_number, 
                   BankAccount.account_type
                   FROM BankAccount
                   JOIN UPI ON BankAccount.account_number = UPI.account_number
                   WHERE UPI.UPI_id = ?
        """

        do {
            let resultSet = try db.executeQuery(query, values: [upiId])
            
            if resultSet.next() {
                return BankAccountDO(
                    accountNumber: resultSet.string(forColumn: "account_number") ?? "",
                    username: resultSet.string(forColumn: "user_name"),
                    name: resultSet.string(forColumn: "name") ?? "",
                    ifscCode: resultSet.string(forColumn: "ifsc") ?? "",
                    balance: resultSet.double(forColumn: "balance"),
                    phoneNumber: resultSet.string(forColumn: "phone_number") ?? "",
                    accountType: AccountType(rawValue: resultSet.string(forColumn: "account_type") ?? "") ?? .normal
                )
            }
        } catch {
            print("Error retrieving bank account by UPI ID: \(error.localizedDescription)")
        }
        
        return nil
    }

    
}

