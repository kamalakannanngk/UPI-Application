//
//  TransactionDAO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation
import FMDB

class TransactionDAO {
    private let db: FMDatabase
    
    init() {
        self.db = DatabaseConnection.shared.database
    }
    
    func insertTransaction(transactionDO: TransactionDO) -> Int? {
        let query = "INSERT INTO \"Transaction\" (amount, transaction_type, sender_UPI_ID, message) VALUES (?, ?, ?, ?);"
        
        do {
            try db.executeUpdate(query, values:[transactionDO.amount, transactionDO.transactionType.rawValue, transactionDO.senderUPIID, transactionDO.message ?? NSNull()])
            return Int(db.lastInsertRowId)
        }
        catch {
            print("Error while inserting transaction! Error: \(error)")
            return nil
        }
    }
    
    func insertAccountTransaction(accountTransactionDO: AccountTransactionDO) {
        let query = "INSERT INTO AccountTransaction (transaction_id, receiver_UPI_ID) VALUES (?, ?);"
        
        do {
            try db.executeUpdate(query, values:[accountTransactionDO.transactionId, accountTransactionDO.receiverUPIID])
        }
        catch {
            print("Error while inserting account transaction!\n Error: \(error)")
        }
    }
    
    func insertServiceTransaction(serviceTransactionDO: ServiceTransactionDO) -> Int? {
        let query = "INSERT INTO ServiceTransaction (transaction_id, service_type, service_name) VALUES (?, ?, ?);"
        
        do {
            try db.executeUpdate(query, values: [serviceTransactionDO.transactionId, serviceTransactionDO.serviceType.rawValue, serviceTransactionDO.serviceName])
            return Int(db.lastInsertRowId)
        }
        catch {
            print("Error while inserting service transaction! Error: \(error)")
            return nil
        }
    }
    
    func getAllTransactionHistory(upiDO: UPIDO) -> [TransactionHistoryDO] {
        let query = """
        SELECT 
            t.transaction_id,
            t.amount,
            t.date,
            t.transaction_type,
            t.sender_UPI_id,
            t.message,
            at.receiver_UPI_id,
            st.service_type,
            st.service_name
        FROM "Transaction" t
        LEFT JOIN AccountTransaction at ON t.transaction_id = at.transaction_id
        LEFT JOIN ServiceTransaction st ON t.transaction_id = st.transaction_id
        WHERE t.sender_UPI_id = ? OR at.receiver_UPI_id = ?;
        """

        var transactions: [TransactionHistoryDO] = []

        do {
            let resultSet = try db.executeQuery(query, values: [upiDO.upiId, upiDO.upiId])
            while resultSet.next() {
                let transaction = TransactionHistoryDO(
                    transactionID: Int(resultSet.int(forColumn: "transaction_id")),
                    amount: resultSet.double(forColumn: "amount"),
                    date: resultSet.string(forColumn: "date") ?? "",
                    transactionType: resultSet.string(forColumn: "transaction_type") ?? "",
                    senderUPIID: resultSet.string(forColumn: "sender_UPI_id") ?? "",
                    message: resultSet.string(forColumn: "message"),
                    receiverUPIID: resultSet.string(forColumn: "receiver_UPI_id"),
                    serviceType: resultSet.string(forColumn: "service_type"),
                    serviceName: resultSet.string(forColumn: "service_name")
                )
                transactions.append(transaction)
            }
        } catch {
            print("Error fetching transaction history: \(error)")
        }

        return transactions
    }


    func getFilteredTransactions(transactionType: TransactionType) -> [TransactionDO] {
        var transactions: [TransactionDO] = []
        let query = "SELECT * FROM \"Transaction\" WHERE transaction_type = ?;"

        do {
            let resultSet = try db.executeQuery(query, values: [transactionType])

            while resultSet.next() {
                let transactionDO = TransactionDO(
                    transactionId: Int(resultSet.int(forColumn: "transaction_id")),
                    amount: resultSet.double(forColumn: "amount"),
                    date: resultSet.string(forColumn: "date") ?? "",
                    transactionType: TransactionType(rawValue: transactionType.rawValue) ?? .account,
                    senderUPIID: resultSet.string(forColumn: "sender_UPI_ID") ?? "",
                    message: resultSet.string(forColumn: "message")
                )

                transactions.append(transactionDO)
            }
        } catch {
            print("Error fetching transactions for type \(transactionType.rawValue): \(error)")
        }
        
        return transactions
    }
    
    func hasReachedDailyTransactionLimit(bankAccountDO: BankAccountDO, amount: Double) -> Bool {
        let query = """
        SELECT COALESCE(SUM(t.amount), 0)
        FROM "Transaction" t
        JOIN UPI u ON t.sender_UPI_id = u.UPI_id
        WHERE u.account_number = ?
        AND DATE(t.date) >= DATE('now', 'start of day');
        """
        var dailyTransactionLimit: Double?
        
        let fetchDailyTransactionLimitQuery = "SELECT transaction_limit_per_day FROM BankAccountLimits WHERE account_type = ?"
        
        do {
            let resultSet1 = try db.executeQuery(fetchDailyTransactionLimitQuery, values: [bankAccountDO.accountType.rawValue])
            if resultSet1.next() {
                dailyTransactionLimit = resultSet1.double(forColumnIndex: 0)
            }
            
            let resultSet2 = try db.executeQuery(query, values: [bankAccountDO.accountNumber])
            
            if let limit = dailyTransactionLimit {
                if resultSet2.next() {
                    let totalSentToday = resultSet2.double(forColumnIndex: 0)
                    return (totalSentToday + amount) > limit
                }
            }
        } catch {
            print("Error checking daily transaction limit: \(error.localizedDescription)")
        }
        
        return true 
    }
    
    
}
