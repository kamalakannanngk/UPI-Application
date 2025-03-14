//
//  AutoRenewalView.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 14/03/25.
//

import Foundation

class AutoRenewalView {
    
    static func showAutoRenewalsForUser(userDO: UserDO) {
        var (renewals, names, amount) : ([AutoRenewalDO], [String], [Double]) = ([], [], [])
        Task {
            await (renewals, names, amount) = AutoRenewalController().getAutoRenewalsForUser(userDO: userDO)
        }
        
        Thread.sleep(forTimeInterval: 1)
        
        if renewals.isEmpty {
            print("No Auto Renewals!")
        }
        
        for (index, renewal) in renewals.enumerated() {
          
            if let autoRenewalId = renewal.autoRenewalId, let nextRenewalDate = renewal.nextRenewalDate {
                
                print("""
        ----------------------------------
        Auto Renewal ID: \(autoRenewalId)
        Service Name: \(names[index])
        Transaction ID: \(renewal.transactionId)
        Amount: \(amount[index])
        Next Renewal Date: \(nextRenewalDate)
        ----------------------------------
        """)
                
            } else {
                print("Auto Renewal Id is Nil!")
            }
            
        }
        
        print("Do you want to cancel any auto renewal? (y/n)")
        if let input = readLine() {
            switch input {
            case "y":
                print("Enter the Auto Renewal ID to cancel:")
                
                if let input = readLine(), let autoRenewalId = Int(input) {
                    Task {
                        if await AutoRenewalController().cancelAutoRenewal(autoRenewalId: autoRenewalId) {
                            print("Auto Renewal Cancelled Successfully!")
                        }
                    }
                }
                
            case "n":
                break
                
            default:
                print("Invalid input. Please try again.")
            }
        }
        
        
    }
    
}
