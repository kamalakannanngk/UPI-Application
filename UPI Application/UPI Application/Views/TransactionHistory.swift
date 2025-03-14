//
//  TransactionHistoryView.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 13/03/25.
//

import Foundation

enum TransactionFilters: Int {
    case paymentType = 1
    case amountRange = 2
    case dateRange = 3
}

enum PaymentType: Int {
    case sent = 1
    case received = 2
}

enum AmountRange: Int {
    case upto200 = 1
    case range200to500 = 2
    case range500to2000 = 3
    case above2000 = 4
}

enum DateRange: Int {
    case thisMonth = 1
    case last30Days = 2
    case last90Days = 3
}

class TransactionHistoryView {
    
    static func viewAllTransactions(userDO: UserDO) {
        let transactionHistory = TransactionController().getAllTransactionHistory(userDO: userDO)

        print("=======================================")
        print("ALL TRANSACTIONS")
        printTransactions(transactions: transactionHistory)
        print("=======================================")
        
        while true {
            print("Do you need to filter transactions? (y/n)")
            if let input = readLine() {
                switch input.lowercased() {
                case "y":
                    getInputForFilteredTransaction(userDO: userDO, transactions: transactionHistory)
                    return
                case "n":
                    return
                default:
                    print("Invalid input. Please try again.")
                }
            }
        }
    }
    
    static func getInputForFilteredTransaction(userDO: UserDO, transactions: [TransactionHistoryDO]) {
        print("""
        ---------------------------------------
        Choose the Filter Type:
        1. Payment Type
        2. Amount Range
        3. Date Range
        ---------------------------------------
        """)
        
        if let input = readLine(), let choice = Int(input), let filterType = TransactionFilters(rawValue: choice) {
            switch filterType {
            case .paymentType:
                applyPaymentTypeFilter(userDO: userDO, transactions: transactions)
            case .amountRange:
                applyAmountRangeFilter(transactions: transactions)
            case .dateRange:
                applyDateRangeFilter(transactions: transactions)
            }
        } else {
            print("Invalid choice. Please try again.")
            getInputForFilteredTransaction(userDO: userDO, transactions: transactions)
        }
    }
    
    static func applyPaymentTypeFilter(userDO: UserDO, transactions: [TransactionHistoryDO]) {
        print("""
        ---------------------------------------
        Choose the Payment Type:
        1. Sent
        2. Received
        ---------------------------------------
        """)
        
        if let input = readLine(), let choice = Int(input), let type = PaymentType(rawValue: choice) {
            let filteredTransactions = filterTransactionByPaymentType(transactions: transactions, userDO: userDO, type: type)
            printFilteredTransactions(transactions: filteredTransactions)
        } else {
            print("Invalid input. Please try again.")
            applyPaymentTypeFilter(userDO: userDO, transactions: transactions)
        }
    }
    
    static func applyAmountRangeFilter(transactions: [TransactionHistoryDO]) {
        print("""
        ---------------------------------------
        Choose the Amount Range:
        1. Upto 200
        2. 200 to 500
        3. 500 to 2000
        4. Above 2000
        ---------------------------------------
        """)
        
        if let input = readLine(), let choice = Int(input), let range = AmountRange(rawValue: choice) {
            let filteredTransactions = filterTransactionByAmount(transactions: transactions, range: range)
            printFilteredTransactions(transactions: filteredTransactions)
        } else {
            print("Invalid input. Please try again.")
            applyAmountRangeFilter(transactions: transactions)
        }
    }
    
    static func applyDateRangeFilter(transactions: [TransactionHistoryDO]) {
        print("""
        ---------------------------------------
        Choose the Date Range:
        1. This Month
        2. Last 30 Days
        3. Last 90 Days
        ---------------------------------------
        """)
        
        if let input = readLine(), let choice = Int(input), let range = DateRange(rawValue: choice) {
            let filteredTransactions = filterTransactionByDate(transactions: transactions, range: range)
            printFilteredTransactions(transactions: filteredTransactions)
        } else {
            print("Invalid input. Please try again.")
            applyDateRangeFilter(transactions: transactions)
        }
    }
    
    static func filterTransactionByPaymentType(transactions: [TransactionHistoryDO], userDO: UserDO, type: PaymentType) -> [TransactionHistoryDO] {
        let userUPIIds = UPIController().getUPIIdsForUser(userDO: userDO).map { $0.upiId }

        return transactions.filter { transaction in
            if type == .sent {
                return userUPIIds.contains(transaction.senderUPIID)
            } else {
                return userUPIIds.contains(transaction.receiverUPIID ?? "")
            }
        }
    }
    
    static func filterTransactionByAmount(transactions: [TransactionHistoryDO], range: AmountRange) -> [TransactionHistoryDO] {
        return transactions.filter { transaction in
            switch range {
            case .upto200:
                return transaction.amount <= 200
            case .range200to500:
                return transaction.amount > 200 && transaction.amount <= 500
            case .range500to2000:
                return transaction.amount > 500 && transaction.amount <= 2000
            case .above2000:
                return transaction.amount > 2000
            }
        }
    }
    
    static func getDateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Matches SQLite format
        formatter.timeZone = TimeZone(abbreviation: "UTC") // SQLite default is UTC
        return formatter.date(from: dateString)
    }

    static func filterTransactionByDate(transactions: [TransactionHistoryDO], range: DateRange) -> [TransactionHistoryDO] {
        let currentDate = Date()
        let calendar = Calendar.current

        return transactions.filter { transaction in
            guard let transactionDate = getDateFromString(transaction.date) else {
                return false
            }

            switch range {
            case .thisMonth:
                return calendar.isDate(transactionDate, equalTo: currentDate, toGranularity: .month) &&
                       calendar.isDate(transactionDate, equalTo: currentDate, toGranularity: .year)

            case .last30Days:
                if let pastDate = calendar.date(byAdding: .day, value: -30, to: currentDate) {
                    return transactionDate >= pastDate
                }
                return false

            case .last90Days:
                if let pastDate = calendar.date(byAdding: .day, value: -90, to: currentDate) {
                    return transactionDate >= pastDate
                }
                return false
            }
        }
    }

    static func printFilteredTransactions(transactions: [TransactionHistoryDO]) {
        print("=======================================")
        print("FILTERED TRANSACTIONS")
        printTransactions(transactions: transactions)
        print("=======================================")
    }
    
    static func printTransactions(transactions: [TransactionHistoryDO]) {
        if transactions.isEmpty {
            print("No transactions found.\n")
            return
        }

        for transaction in transactions {
            print("---------------------------------------")
            print("Transaction ID: \(transaction.transactionID)")
            print("Amount: \(transaction.amount)")
            print("Date: \(transaction.date)")
            print("Transaction Type: \(transaction.transactionType)")
            print("Sender UPI ID: \(transaction.senderUPIID)")
            
            if let message = transaction.message {
                print("Message: \(message)")
            }

            if let receiverUPIID = transaction.receiverUPIID {
                print("Receiver UPI ID: \(receiverUPIID)")
            }

            if let serviceType = transaction.serviceType, let serviceName = transaction.serviceName {
                print("Service Type: \(serviceType)")
                print("Service Name: \(serviceName)")
            }

            print("---------------------------------------\n")
        }
    }
}
