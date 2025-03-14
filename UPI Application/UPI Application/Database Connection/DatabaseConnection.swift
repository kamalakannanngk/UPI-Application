import Foundation
import FMDB

class DatabaseConnection {
    static let shared = DatabaseConnection()
    var database: FMDatabase
    
    init() {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("UPI.sqlite")
            database = FMDatabase(path: fileURL.path)
        } else {
            print("Failed to locate the document directory.")
            exit(1)
        }
    }
    
    func openDatabase() -> Bool {
        return database.open()
    }
    
    func createTables() {
        let createUserTable = """
        CREATE TABLE IF NOT EXISTS User (
            user_name TEXT PRIMARY KEY,
            phone_number TEXT NOT NULL,
            password TEXT NOT NULL
        );
        """
        
        let createBankAccountTable = """
        CREATE TABLE IF NOT EXISTS BankAccount (
            account_number TEXT PRIMARY KEY,
            user_name TEXT DEFAULT NULL,
            name TEXT CHECK(name IN ('hdfc', 'icici', 'sbi', 'axis', 'dbs', 'kvb', 'iob')),
            ifsc TEXT NOT NULL,
            balance DECIMAL(10, 2),
            phone_number TEXT NOT NULL,
            account_type TEXT CHECK(account_type IN ('Normal', 'Business')),
            FOREIGN KEY (user_name) REFERENCES User(user_name)
        );
        """
        
        let createAccountLimitsTable = """
        CREATE TABLE IF NOT EXISTS BankAccountLimits (
            account_type TEXT PRIMARY KEY CHECK(account_type IN ('Normal', 'Business')),
            transaction_limit_per_day DECIMAL(10, 2) NOT NULL,
            transaction_limit_per_transaction DECIMAL(10, 2) NOT NULL,
            minimum_balance DECIMAL(10, 2) NOT NULL
        );
        """
        
        let createUPIManagerTable = """
        CREATE TABLE IF NOT EXISTS UPIManager (
            account_number TEXT PRIMARY KEY NOT NULL,
            UPI_pin INTEGER DEFAULT NULL,
            is_primary BOOLEAN DEFAULT FALSE,
            FOREIGN KEY (account_number) REFERENCES BankAccount(account_number)
        );
        """
        
        let createUPITable = """
        CREATE TABLE IF NOT EXISTS UPI (
            UPI_id TEXT PRIMARY KEY,
            account_number TEXT NOT NULL,
            is_primary BOOLEAN DEFAULT FALSE,
            FOREIGN KEY (account_number) REFERENCES BankAccount(account_number)
        );
        """
        
        let createTransactionTable = """
        CREATE TABLE IF NOT EXISTS "Transaction" (
            transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount DECIMAL(10, 2) NOT NULL,
            date DATETIME DEFAULT CURRENT_TIMESTAMP,
            transaction_type TEXT CHECK(transaction_type IN ('Account', 'Service', 'Split Bill')),
            sender_UPI_id TEXT NOT NULL,
            message TEXT,
            FOREIGN KEY (sender_UPI_id) REFERENCES UPI(UPI_id)
        );
        """
        
        let createAccountTransactionTable = """
        CREATE TABLE IF NOT EXISTS AccountTransaction (
            transaction_id INTEGER PRIMARY KEY,
            receiver_UPI_id TEXT NOT NULL,
            FOREIGN KEY (transaction_id) REFERENCES "Transaction"(transaction_id)
        );
        """
        
        let createServiceTransactionTable = """
        CREATE TABLE IF NOT EXISTS ServiceTransaction (
            transaction_id INTEGER PRIMARY KEY,
            service_type TEXT CHECK(service_type IN ('Mobile Recharge', 'Subscription', 'Bill')),
            service_name TEXT NOT NULL,
            FOREIGN KEY (transaction_id) REFERENCES "Transaction"(transaction_id)
        );
        """

        let createSplitBillTable = """
        CREATE TABLE IF NOT EXISTS SplitBill (
            split_bill_id INTEGER PRIMARY KEY AUTOINCREMENT,
            group_id INTEGER NOT NULL,
            payer_user_name TEXT NOT NULL,
            total_amount DECIMAL(10,2) NOT NULL,
            FOREIGN KEY (group_id) REFERENCES Groups(group_id) ON DELETE CASCADE,
            FOREIGN KEY (payer_user_name) REFERENCES User(user_name) ON DELETE CASCADE
        );
        """
        
        let createSplitBillParticipantsTable = """
        CREATE TABLE IF NOT EXISTS SplitBillParticipants (
            split_bill_id INTEGER NOT NULL,
            payee_user_name TEXT NOT NULL,
            amount_to_pay DECIMAL(10,2) NOT NULL,
            status TEXT CHECK(status IN ('Pending', 'Paid')) DEFAULT 'Pending',
            PRIMARY KEY (split_bill_id, payee_user_name),
            FOREIGN KEY (split_bill_id) REFERENCES SplitBill(split_bill_id) ON DELETE CASCADE,
            FOREIGN KEY (payee_user_name) REFERENCES User(user_name) ON DELETE CASCADE
        );
        """
        
        let createRequestAmountTable = """
        CREATE TABLE IF NOT EXISTS RequestAmount (
            request_id INTEGER PRIMARY KEY AUTOINCREMENT,
            sender_UPI_id TEXT NOT NULL,
            receiver_UPI_id TEXT NOT NULL,
            amount DECIMAL(10, 2) NOT NULL,
            status TEXT CHECK(status IN ('Pending', 'Paid', 'Declined')) DEFAULT 'Pending',
            FOREIGN KEY (sender_UPI_id) REFERENCES UPI(UPI_id),
            FOREIGN KEY (receiver_UPI_id) REFERENCES UPI(UPI_id)
        );
        """
        
        let createAutoRenewalTable = """
        CREATE TABLE IF NOT EXISTS AutoRenewal (
            auto_renewal_id INTEGER PRIMARY KEY AUTOINCREMENT,
            UPI_id INTEGER NOT NULL,
            transaction_id INTEGER NOT NULL,
            next_renewal_date DATETIME NOT NULL,
            FOREIGN KEY (UPI_id) REFERENCES UPI(UPI_id),
            FOREIGN KEY (transaction_id) REFERENCES ServiceTransaction(transaction_id)
        );
        """
        
        let createGroupsTable = """
        CREATE TABLE IF NOT EXISTS Groups (
            group_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            creater_user_name TEXT NOT NULL,
            date DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (creater_user_name) REFERENCES User(user_name)
        );
        """
        
        let createGroupMembersTable = """
        CREATE TABLE IF NOT EXISTS GroupMembers (
            group_id INTEGER NOT NULL,
            member_user_name TEXT NOT NULL,
            added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (group_id) REFERENCES Groups(group_id),
            FOREIGN KEY (member_user_name) REFERENCES User(user_name)
        );
        """
        
        let queries = [
            createUserTable,
            createBankAccountTable,
            createAccountLimitsTable,
            createUPIManagerTable,
            createUPITable,
            createTransactionTable,
            createAccountTransactionTable,
            createServiceTransactionTable,
            createSplitBillTable,
            createSplitBillParticipantsTable,
            createRequestAmountTable,
            createAutoRenewalTable,
            createGroupsTable,
            createGroupMembersTable
        ]
        
        for query in queries {
            if database.executeUpdate(query, withArgumentsIn: []) == true {
                print("Table Created Successfully!")
            }
            else {
                print("Failed to create table!")
            }
        }
    }
    
    func closeDatabase() {
        if database.isOpen {
            database.close()
            print("Database closed successfully!")
        } else {
            print("Error closing the database!")
        }
    }
}
