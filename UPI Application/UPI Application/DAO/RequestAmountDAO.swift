//
//  RequestAmountDAO.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation
import FMDB

class RequestAmountDAO {
    private let db: FMDatabase
    
    init() {
        self.db = DatabaseConnection.shared.database
    }
    
    func insertRequest(requestAmountDO: RequestAmountDO) -> Int? {
        let query = "INSERT INTO RequestAmount (sender_UPI_id, receiver_UPI_id, amount) VALUES (?, ?, ?)";
        
        do {
            try db.executeUpdate(query, values: [requestAmountDO.senderUPIId, requestAmountDO.receiverUPIId, requestAmountDO.amount])
            return Int(db.lastInsertRowId)
        }
        catch {
            print("Error while inserting request amount: \(error)")
            return nil
        }
    }
    
    func updateRequestStatus(requestId: Int, status: RequestStatus) -> Bool {
        let query = "UPDATE RequestAmount SET status = ? WHERE request_id = ?;"
        
        do {
            try db.executeUpdate(query, values: [status.rawValue, requestId])
            print("Request Updated Successfully!")
            return true
        } catch {
            print("Error updating request status: \(error)")
            return false
        }
    }
    
    func getRequestById(requestId: Int) -> RequestAmountDO? {
        let query = "SELECT * FROM RequestAmount WHERE request_id = ?;"
        
        do {
            let resultSet = try db.executeQuery(query, values: [requestId])
            
            if resultSet.next() {
                return RequestAmountDO(
                    requestId: requestId,
                    senderUPIId: resultSet.string(forColumn: "sender_UPI_id") ?? "",
                    receiverUPIId: resultSet.string(forColumn: "receiver_UPI_id") ?? "",
                    amount: resultSet.double(forColumn: "amount"),
                    status: RequestStatus(rawValue: resultSet.string(forColumn: "status") ?? "") ?? .pending
                )
            }
        } catch {
            print("Error fetching request: \(error)")
        }
        return nil
    }
    
    func getSentRequests(userDO: UserDO) -> [RequestAmountDO] {
        let query = """
            SELECT ra.request_id, ra.sender_UPI_id, ra.receiver_UPI_id, ra.amount, ra.status, u.user_name
            FROM RequestAmount ra
            JOIN UPI sender ON ra.sender_UPI_id = sender.UPI_id
            JOIN BankAccount ba ON sender.account_number = ba.account_number
            JOIN User u ON ba.user_name = u.user_name
            WHERE u.user_name = ?;
        """
        
        var results: [RequestAmountDO] = []
        
        do {
            let resultSet = try db.executeQuery(query, values: [userDO.username])
            
            while resultSet.next() {
                let requestId = Int(resultSet.int(forColumn: "request_id"))
                let senderUPIId = resultSet.string(forColumn: "sender_UPI_id") ?? ""
                let receiverUPIId = resultSet.string(forColumn: "receiver_UPI_id") ?? ""
                let amount = resultSet.double(forColumn: "amount")
                let statusString = resultSet.string(forColumn: "status") ?? "pending"

                let status = RequestStatus(rawValue: statusString) ?? .pending
                let request = RequestAmountDO(requestId: requestId, senderUPIId: senderUPIId, receiverUPIId: receiverUPIId, amount: amount, status: status)
                
                results.append(request)
            }
        } catch {
            print("Error fetching sent requests: \(error)")
        }
        
        return results
    }

    func getReceivedRequests(userDO: UserDO) -> [RequestAmountDO] {
        let query = """
            SELECT ra.request_id, ra.sender_UPI_id, ra.receiver_UPI_id, ra.amount, ra.status, u.user_name
            FROM RequestAmount ra
            JOIN UPI receiver ON ra.receiver_UPI_id = receiver.UPI_id
            JOIN BankAccount ba ON receiver.account_number = ba.account_number
            JOIN User u ON ba.user_name = u.user_name
            WHERE u.user_name = ?;

        """
        
        var results: [RequestAmountDO] = []
        
        do {
            let resultSet = try db.executeQuery(query, values: [userDO.username])
            
            while resultSet.next() {
                let requestId = Int(resultSet.int(forColumn: "request_id"))
                let senderUPIId = resultSet.string(forColumn: "sender_UPI_id") ?? ""
                let receiverUPIId = resultSet.string(forColumn: "receiver_UPI_id") ?? ""
                let amount = resultSet.double(forColumn: "amount")
                let statusString = resultSet.string(forColumn: "status") ?? "pending"

                let status = RequestStatus(rawValue: statusString) ?? .pending
                let request = RequestAmountDO(requestId: requestId, senderUPIId: senderUPIId, receiverUPIId: receiverUPIId, amount: amount, status: status)
                
                results.append(request)
            }
        } catch {
            print("Error fetching received requests: \(error)")
        }
        
        return results
    }
    

}
