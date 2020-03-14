//
//  InputValidator.swift
//  Joeppie
//
//  Created by qa on 11/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import Foundation

class InputValidator {
    class func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    class func validatePassword(input: String) -> Bool {
        // Minimum eight characters, at least one letter, one number and one special character:
        let passRegEx = "^(?=.*[a-z])(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$"
        let trimmedString = input.trimmingCharacters(in: .whitespaces)
        let validatePassord = NSPredicate(format: "SELF MATCHES %@", passRegEx)
        let isvalidatePass = validatePassord.evaluate(with: trimmedString)
        return isvalidatePass
    }

    class func validateUsername(input: String) -> Bool {
        // Length can be 18 characters max and 3 characters minimum:
        let nameRegex = "^\\w{3,18}$"
        let trimmedString = input.trimmingCharacters(in: .whitespaces)
        let validateName = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        let isValidateName = validateName.evaluate(with: trimmedString)
        return isValidateName
    }

}
