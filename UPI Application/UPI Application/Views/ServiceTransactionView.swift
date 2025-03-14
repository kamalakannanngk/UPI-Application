//
//  ServiceTransactionView.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 12/03/25.
//

import Foundation

enum SubscriptionType: String {
    case jioHotstar = "JIO Hotstar"
    case amazonPrime = "Amazon Prime"
    case netflix = "Netflix"
    
    static func from(number: Int) -> SubscriptionType? {
        switch number {
        case 1: return .jioHotstar
        case 2: return .amazonPrime
        case 3: return .netflix
        default: return nil
        }
    }
}

enum MobileRechargeType: String {
    case jio = "JIO"
    case bsnl = "BSNL"
    case airtel = "Airtel"
    
    static func from(number: Int) -> MobileRechargeType? {
        switch number {
        case 1: return .airtel
        case 2: return .jio
        case 3: return .bsnl
        default : return nil
        }
    }
}

enum PayBillsType: String {
    case electricityBill = "Electricity Bill"
    case internetBill = "Internet Bill"
    case gasBill = "Gas Bill"
    
    static func from(number: Int) -> PayBillsType? {
        switch number {
            case 1: return .electricityBill
            case 2: return .internetBill
            case 3: return .gasBill
            default : return nil
        }
    }
}

class ServiceTransactionView {
    
    static func subscription(userDO: UserDO) {
        var subscriptionType: SubscriptionType
        var amount: Double
        
        
        print("""
        ----------------------------------
        Choose the Subscription:
        1. Jio Hotstar
        2. Amazon Prime
        3. Netflix
        ----------------------------------
        """)
        
        if let input = readLine(), let choice = Int(input), let action = SubscriptionType.from(number: choice) {
            switch action {
            case .jioHotstar:
                print("Subscription Selected: Jio Hotstar")
                print("Amount to Pay Rs. 799.00")
                subscriptionType = .jioHotstar
                amount = 799.0
                
            case .amazonPrime:
                print("Subscription Selected: Amazon Prime")
                print("Amount to Pay Rs. 999.00")
                subscriptionType = .amazonPrime
                amount = 999.0
                
            case .netflix:
                print("Subscription Selected: Netflix")
                print("Amount to Pay Rs. 1299.00")
                subscriptionType = .netflix
                amount = 1299.0
            }
        } else {
            print("Invalid Choice!")
            return
        }
        
        if let (bankAccountDO, UPIId, UPIPIN, autoRenewal) = getInputForTransaction(userDO: userDO) {
            ServiceController().sendMoneyForService(bankAccountDO: bankAccountDO, UPIID: UPIId, UPIPIN: UPIPIN, amount: amount, serviceType: .subscription, serviceName: subscriptionType.rawValue, isAutoRenewal: autoRenewal)
        } else {
            print("Found Nil while getting user inputs for subscription")
        }
    }
    
    static func mobileRecharge(userDO: UserDO) {
        var mobileRechargeType: MobileRechargeType
        var amount: Double
        
        print("""
        ----------------------------------
        Choose the Sim:
        1. Airtel
        2. Jio
        3. BSNL
        ----------------------------------
        """)
        
        if let input = readLine(), let choice = Int(input), let action = MobileRechargeType.from(number: choice) {
            switch action {
            case .airtel:
                print("Sim Selected: Airtel")
                print("Amount to Pay: Rs. 899")
                mobileRechargeType = .airtel
                amount = 899.0
                
            case .jio:
                print("Sim Selected: Jio")
                print("Amount to Pay: Rs. 729")
                mobileRechargeType = .jio
                amount = 729.0
                
            case .bsnl:
                print("Sim Selected: BSNL")
                print("Amount to Pay: Rs. 525")
                mobileRechargeType = .bsnl
                amount = 525.0
            }
        } else {
            print("Invalid Choice")
            return
        }
        
        if let (bankAccountDO, UPIId, UPIPIN, autoRenewal) = getInputForTransaction(userDO: userDO) {
            ServiceController().sendMoneyForService(bankAccountDO: bankAccountDO, UPIID: UPIId, UPIPIN: UPIPIN, amount: amount, serviceType: .mobileRecharge, serviceName: mobileRechargeType.rawValue, isAutoRenewal: autoRenewal)
        } else {
            print("Found Nil while getting user inputs for subscription")
        }
        
    }
    
    static func payBills(userDO: UserDO) {
        var paybillsType: PayBillsType
        var amount: Double
        
        print("""
        ----------------------------------
        Choose the Sim:
        1. Electricity Bill
        2. Internet Bill
        3. Gas Bill
        ----------------------------------
        """)
        
        if let input = readLine(), let choice = Int(input), let action = PayBillsType.from(number: choice) {
            switch action {
            case .electricityBill:
                print("Bill Selected: Electricity")
                print("Amount to Pay: Rs. 395")
                paybillsType = .electricityBill
                amount = 395.0
                
            case .internetBill:
                print("Bill Selected: Internet")
                print("Amount to Pay: Rs. 710")
                paybillsType = .internetBill
                amount = 710.0
                
            case .gasBill:
                print("Bill Selected: Gas")
                print("Amount to Pay: Rs. 695")
                paybillsType = .gasBill
                amount = 695.0
            }
        } else {
            print("Invalid Choice")
            return
        }
        
        if let (bankAccountDO, UPIId, UPIPIN, autoRenewal) = getInputForTransaction(userDO: userDO) {
            ServiceController().sendMoneyForService(bankAccountDO: bankAccountDO, UPIID: UPIId, UPIPIN: UPIPIN, amount: amount, serviceType: .mobileRecharge, serviceName: paybillsType.rawValue, isAutoRenewal: autoRenewal)
        } else {
            print("Found Nil while getting user inputs for subscription")
        }
        
    }
    
    
    
    private static func getInputForTransaction(userDO: UserDO) -> (bankAccountDO: BankAccountDO, UPIID: String, UPIPIN: Int, autoRenewal: Bool)? {
        var autoRenewal: Bool?
        var bankAccountDO: BankAccountDO?
        var upiId: String?
        var upiPin: Int?
        
        
        if BankController().isLinkedWithBankAccount(userDO: userDO) {
            print("Choose the Bank Account to Send Money: ")
            let bankAccounts = BankAccountView.viewLinkedBankAccounts(userDO: userDO)
            
            if let input = readLine(), let choice = Int(input), choice >= 1, choice <= bankAccounts.count {
                bankAccountDO = bankAccounts[choice - 1]
                
                if let bankAccountDO = bankAccountDO {
                    upiId = UPIController().getPrimaryUPI(accountNumber: bankAccountDO.accountNumber)
                }
                
                
                print("Enter your 6 digit UPI PIN:")
                guard let input = readLine(), let UPIPIN = Int(input), input.count == 6 else {
                    print("Invalid PIN!")
                    return nil
                }
                
                print("Do you want to set auto renewal? (y/n)")
                guard let input = readLine(), (input == "y" || input == "n") else {
                    print("Invalid Input!")
                    return nil
                }
                
                upiPin = UPIPIN
                autoRenewal = input == "y"
            }
        } else {
            print("Link your bank account first!")
            return nil
        }
        
        if let autoRenewal = autoRenewal {
            if let bankAccountDO = bankAccountDO {
                if let upiId = upiId {
                    if let upiPin = upiPin {
                        return (bankAccountDO, upiId, upiPin, autoRenewal)
                    }
                }
            }
        }
        
        return nil
    }
    
}
