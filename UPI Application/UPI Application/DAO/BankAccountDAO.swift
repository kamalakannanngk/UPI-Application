//
//  BankDAO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation
import FMDB

class BankAccountDAO {
    private let db: FMDatabase
    private let upiDAO : UPIDAO
    let bankNames = ["hdfc", "icici", "sbi", "axis", "dbs", "kvb", "iob"]
    
    init() {
        self.db = DatabaseConnection.shared.database
        upiDAO = UPIDAO()
    }
    
    func addBankAccounts() {
        addNormalBankAccounts()
        addBusinessBankAccounts()
        addBankAccountLimits()
    }
    
    private func generate(bankName: String) -> (accountNumber: String, ifscCode: String, phoneNumber: String) {
        var accountNumber: String
        var ifscCode: String
        
        repeat {
            accountNumber = String(Int.random(in: 1000000000...9999999999))
        } while !isAccountNumberUnique(accountNumber: accountNumber)
        
        let bankCode = bankName.uppercased()
        repeat {
            let branchCode = String(format: "%04d", Int.random(in: 0...9999))
            ifscCode = "\(bankCode)000\(branchCode)"
        } while !isIFCSCCodeUnique(ifscCode: ifscCode)
        
        let phoneNumber = String(Int.random(in: 1000000000...9999999999))
        
        return (accountNumber, ifscCode, phoneNumber)
    }
    
    private func addNormalBankAccounts() {
        do {
            for bank in bankNames {
                let (accountNumber, ifscCode, phoneNumber) = generate(bankName: bank)
                let insertBankQuery = """
                INSERT OR IGNORE INTO BankAccount (account_number, name, ifsc, balance, phone_number, account_type)
                VALUES (?, ?, ?, ?, ?, ?)
                """
                
                try db.executeUpdate(insertBankQuery, values: [
                    accountNumber, bank, ifscCode, 1000.0, phoneNumber, "Normal"
                ])
                
                let insertUPIManagerQuery = """
                INSERT INTO UPIManager (account_number)
                VALUES (?)
                """
                
                try db.executeUpdate(insertUPIManagerQuery, values: [accountNumber])
                
                print("Normal Bank Account (\(bank)) added successfully!")
            }
        } catch {
            print("Error while adding normal bank accounts: \(error)")
        }
    }
    
    private func addBusinessBankAccounts() {
        do {
            for bank in bankNames {
                let (accountNumber, ifscCode, phoneNumber) = generate(bankName: bank)
                let insertBankQuery = """
                INSERT OR IGNORE INTO BankAccount (account_number, name, ifsc, balance, phone_number, account_type)
                VALUES (?, ?, ?, ?, ?, ?)
                """
                
                try db.executeUpdate(insertBankQuery, values: [
                    accountNumber, bank, ifscCode, 10000.0, phoneNumber, "Business"
                ])
                
                let insertUPIManagerQuery = """
                INSERT OR IGNORE INTO UPIManager (account_number)
                VALUES (?)
                """
                
                try db.executeUpdate(insertUPIManagerQuery, values: [accountNumber])
                
                print("Business Bank Account (\(bank)) added successfully!")
            }
        } catch {
            print("Error while adding normal bank accounts: \(error)")
        }
    }
    
    private func addBankAccountLimits() {
        do {
            let query = """
                INSERT OR IGNORE INTO BankAccountLimits (account_type, transaction_limit_per_day, transaction_limit_per_transaction, minimum_balance)
                VALUES 
                ('Normal', 50000.0, 10000.0, 500.0),
                ('Business', 200000.0, 50000.0, 5000.0);
                """
            
            try db.executeUpdate(query, values: [])
            print("Inserted Bank Account Limits")
        } catch {
            print("Error occurred while adding account limits \(error.localizedDescription)")
        }
    }
    

    private func isAccountNumberUnique(accountNumber: String) -> Bool {
        let query = "SELECT EXISTS (SELECT 1 FROM BankAccount WHERE account_number = ?);"

        do {
            let resultSet = try db.executeQuery(query, values: [accountNumber])
            if resultSet.next() {
                let count = resultSet.int(forColumnIndex: 0)
                return count == 0
            }
        }
        catch {
            print("Error occurred while checking account number uniqueness \(error.localizedDescription)")
        }
        return false
    }
    
    private func isIFCSCCodeUnique(ifscCode: String) -> Bool {
        let query = "SELECT EXISTS (SELECT 1 FROM BankAccount WHERE ifsc = ?);"
        do {
            let resultSet = try db.executeQuery(query, values: [ifscCode])
            if resultSet.next() {
                let count = resultSet.int(forColumnIndex: 0)
                return count == 0
            }
        }
        catch {
            print("Error occurred while checking account number uniqueness \(error.localizedDescription)")
        }
        return false
    }
    
    func verifyBankAccount(bankName: BankName, accountNumber: String, userDO: UserDO) -> Bool {
        let query = "SELECT name, account_number, phone_number FROM BankAccount WHERE name = ? AND account_number = ? AND phone_number = ?"
        do {
            let resultSet = try db.executeQuery(query, values: [bankName.rawValue, accountNumber, userDO.phoneNumber])
            if resultSet.next() {
                print("Bank Account Verification Successful")
                return true
            }
            
        }
        catch {
            print("Error while verifying bank account \(error.localizedDescription)")
        }
        return false
    }
    
    func linkBankAccount(username: String, bankName: BankName, accountNumber: String, UPIPin: Int) {
        do {
            let updateBankQuery = "UPDATE BankAccount SET user_name = ? WHERE account_number = ?"
            try db.executeUpdate(updateBankQuery, values: [username, accountNumber])
            let upiCount = upiDAO.getUPIIDCount(accountNumber: accountNumber)
            
            let checkLinkedAccountsQuery = """
            SELECT COUNT(UPI.account_number) AS account_count
            FROM BankAccount
            LEFT JOIN UPI ON BankAccount.account_number = UPI.account_number
            WHERE BankAccount.user_name = ?
            """
            let resultSet = try db.executeQuery(checkLinkedAccountsQuery, values: [username])
            
            var isPrimary = false
            
            if resultSet.next() {
                let accountCount = resultSet.int(forColumn: "account_count")
                if accountCount == 0 {
                    isPrimary = true
                }
            }

            let updateUPIManagerQuery = "UPDATE UPIManager SET UPI_pin = ?, is_primary = ? WHERE account_number = ?"
            try db.executeUpdate(updateUPIManagerQuery, values: [UPIPin, isPrimary ? 1 : 0, accountNumber])

            let upiID = "\(username)\(upiCount)@ok\(bankName)"
            let insertUPIQuery = "INSERT INTO UPI (UPI_id, account_number, is_primary) VALUES (?, ?, ?)"
            try db.executeUpdate(insertUPIQuery, values: [upiID, accountNumber, 1])

            print("Bank account linked successfully with UPI ID: \(upiID)")
        } catch {
            print("Error linking bank account: \(error.localizedDescription)")
        }
    }

    
    
    func getBankAccount(_ accountNumber: String) -> BankAccountDO? {
        let query = "SELECT * FROM BankAccount WHERE account_number = ?;"
        do {
            let resultSet = try db.executeQuery(query, values: [accountNumber])
            if resultSet.next() {
                return mapBankAccount(resultSet)
            }
        }
        catch {
            print("Error Fetching Bank Account")
        }
        return nil
    }
    
    private func mapBankAccount(_ resultSet: FMResultSet) -> BankAccountDO? {
        let accountNumber = resultSet.string(forColumn: "account_number") ?? ""
        let username = resultSet.string(forColumn: "user_name")
        let name = resultSet.string(forColumn: "name") ?? ""
        let ifscCode = resultSet.string(forColumn: "ifsc") ?? ""
        let balance = resultSet.double(forColumn: "balance")
        let phoneNumber = resultSet.string(forColumn: "phone_number") ?? ""
        let accountTypeString = resultSet.string(forColumn: "account_type") ?? "Normal"
    
        let accountType: AccountType = accountTypeString.lowercased() == "business" ? .business : .normal
        
        return BankAccountDO(
            accountNumber: accountNumber,
            username: username,
            name: name,
            ifscCode: ifscCode,
            balance: balance,
            phoneNumber: phoneNumber,
            accountType: accountType
        )
    }
    
    func getBankAccountsForUser(username: String) -> [BankAccountDO] {
        let query = "SELECT * FROM BankAccount WHERE user_name = ?;"
        var accounts : [BankAccountDO] = []
        
        do {
            let resultSet = try db.executeQuery(query, values: [username])
            while resultSet.next() {
                if let account = mapBankAccount(resultSet) {
                    accounts.append(account)
                }
            }
        }
        catch {
            print("Error getting bank accounts for user: \(error.localizedDescription)")
        }
        
        return accounts
    }
    
    func setBankAccountAsPrimary(accountNumber: String) {
        let query = "UPDATE UPIManager SET is_primary = 0 WHERE is_primary = 1"
        do {
            try db.executeUpdate(query, values: [])
        } catch {
            print("Error while setting previous primary bank account as non-primary: \(error.localizedDescription)")
        }
        
        let updatedQuery = "UPDATE UPIManager SET is_primary = 1 WHERE account_number = ?"
        do {
            try db.executeUpdate(updatedQuery, values: [accountNumber])
            print("Bank with account number \(accountNumber) set as primary")
        } catch {
            print("Error setting bank account as primary: \(error.localizedDescription)")
        }
    }
    
    func verifyBankAccountWithUser(accountNumber: String, username: String) -> Bool {
        let query = "SELECT * FROM BankAccount WHERE user_name = ? AND account_number = ?;"
        
        do {
            let resultSet = try db.executeQuery(query, values: [username, accountNumber])
            if resultSet.next() {
                return true
            }
        }
        catch {
            print("Error occured while verifying bank account with the user")
        }
        
        return false
    }
    
    func hasReachedTransactionLimit(accountType: AccountType, amount: Double) -> Bool {
        let query = "SELECT transaction_limit_per_transaction FROM BankAccountLimits WHERE account_type = ?"
        do {
            let resultSet = try db.executeQuery(query, values: [accountType.rawValue])
            if resultSet.next() {
                return amount > resultSet.double(forColumnIndex: 0)
            }
        }
        catch {
            print("Error checking transaction limit per transaction: \(error)")
        }
        
        return false
    }
    
    func updateBalance(accountNumber: String, amount: Double, isAddition: Bool) {
        let query = "UPDATE BankAccount SET balance = balance \(isAddition ? "+" : "-") ? WHERE account_number = ?"
        do {
            try db.executeUpdate(query, values: [amount, accountNumber])
        }
        catch {
            print("Error updating balance: \(error)")
        }
    }
    
    func getMinimumBalance(accountType: AccountType) -> Double? {
        let query = "SELECT minimum_balance FROM BankAccountLimits WHERE account_type = ?"
        do {
            let resultSet = try db.executeQuery(query, values: [accountType.rawValue])
            if resultSet.next() {
                return Double(resultSet.double(forColumnIndex: 0))
            }
        }
        catch {
            print("Error getting minimum balance: \(error)")
        }
        return nil
    }
    
    func checkBalance(bankAccountDO: BankAccountDO, amount: Double) -> Bool {
        if let minimumBalance = getMinimumBalance(accountType: bankAccountDO.accountType) {
            let query = "SELECT balance FROM BankAccount WHERE account_number = ?"
            do {
                let resultSet = try db.executeQuery(query, values: [bankAccountDO.accountNumber])
                if resultSet.next() {
                    let currentBalance = resultSet.double(forColumnIndex: 0)
                    return (currentBalance - amount) >= minimumBalance
                }
            } catch {
                print("Error checking balance: \(error)")
            }
        }
        return false
    }
}
