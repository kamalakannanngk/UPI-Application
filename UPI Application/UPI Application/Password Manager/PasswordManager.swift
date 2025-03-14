//
//  PasswordManager.swift
//  UPI Application
//
//  Created by Kamala Kannan N G on 07/03/25.
//

import Foundation

class PasswordManager {
    
    static func encrypt(_ password: String) -> String {
        var encryptedPassword = ""

        for character in password {
            if let asciiValue = character.asciiValue {
                let newCharacter = UnicodeScalar(asciiValue + 3)
                encryptedPassword.append(Character(newCharacter))
            } else {
                encryptedPassword.append(character)
            }
        }

        return encryptedPassword
    }

    
    static func decrypt(_ password: String) -> String {
        var encryptedPassword = ""

        for character in password {
            let newCharacter = Character(UnicodeScalar(character.asciiValue! - 3))
            encryptedPassword.append(newCharacter)
        }

        return encryptedPassword
    }
    
    // Atleast 1 uppercase, 1 lowercase, 1 special character, 1 number with minimum length of 8
    static func isValidPassword(_ password: String) -> Bool {
        if password.count < 8 {
            return false
        }
        
        var upperCaseCount = 0
        var lowerCaseCount = 0
        var specialCharacterCount = 0
        var numberCount = 0
        
        for character in password {
            if character.isUppercase {
                upperCaseCount += 1
            }
            else if character.isLowercase {
                lowerCaseCount += 1
            }
            else if character.isNumber {
                numberCount += 1
            }
            else {
                specialCharacterCount += 1
            }
        }
        
        return upperCaseCount > 0 && lowerCaseCount > 0 && specialCharacterCount > 0 && numberCount > 0
    }
    
}
