//
//  RequestAmountController.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 11/03/25.
//

import Foundation

class RequestAmountController {
    private let requestAmountDAO : RequestAmountDAO
    
    init() {
        requestAmountDAO = RequestAmountDAO()
    }
    
    func requestAmount(requestAmountDO: RequestAmountDO) -> RequestAmountDO? {
        if UPIDAO().isUPIExists(upiId: requestAmountDO.receiverUPIId) {
            guard let requestId = requestAmountDAO.insertRequest(requestAmountDO: requestAmountDO) else {
                print("Found Nil while getting Request Id!")
                return nil
            }
            
            guard let fetchedRequest = requestAmountDAO.getRequestById(requestId: requestId) else {
                print("Found Nil while getting Request Amount!")
                return nil
            }
            return fetchedRequest
        } else {
            print("UPI ID does not exist!")
        }
        return nil
    }
    
    func getSentRequestByUser(userDO: UserDO) -> [RequestAmountDO] {
        return requestAmountDAO.getSentRequests(userDO: userDO)
    }
    
    func getReceivedRequestByUser(userDO: UserDO) -> [RequestAmountDO] {
        return requestAmountDAO.getReceivedRequests(userDO: userDO)
    }
    
    func getRequestDOById(requestId: Int) -> RequestAmountDO? {
        return requestAmountDAO.getRequestById(requestId: requestId)
    }
    
    func updateRequestStatus(requestId: Int, status: RequestStatus) {
        if requestAmountDAO.updateRequestStatus(requestId: requestId, status: status) {
            print("Request status successfully changed to \(status.rawValue)")
        } else {
            print("Error while updating request status!")
        }
    }
}
