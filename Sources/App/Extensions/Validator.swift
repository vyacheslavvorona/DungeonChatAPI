//
//  Validator.swift
//  App
//
//  Created by vorona.vyacheslav on 2020/01/06.
//

import Validation

extension Validator {
    
    static var letters: Validator<String> {
        return .characterSet(.letters)
    }
}

// MARK: - Custom .contains Validator

extension Validator where T == String {
    /// Validates whether a `String`contains any characters from the CharacterSet.
    ///
    ///     try validations.add(\.username, .contains(.letters))
    ///
    public static func contains(_ characterSet: CharacterSet) -> Validator<T> {
        return ContainsValidator(characterSet: characterSet).validator()
    }
}

/// Validates whether a string contains any characters from the CharacterSet.
fileprivate struct ContainsValidator: ValidatorType {
    /// `CharacterSet` to validate against.
    let characterSet: CharacterSet
    
    /// See `ValidatorType`.
    public var validatorReadable: String {
        if characterSet.traits.count > 0 {
            let string = characterSet.traits.joined(separator: ", ")
            return "in character set (\(string))"
        } else {
            return "in character set"
        }
    }

    /// See `Validator`.
    public func validate(_ s: String) throws {
        guard s.rangeOfCharacter(from: characterSet) != nil else {
            var reason = "should contain characters from:"
            if characterSet.traits.count > 0 {
                let string = characterSet.traits.joined(separator: ", ")
                reason += " (\(string))"
            }
            throw BasicValidationError(reason)
        }
    }
}

extension CharacterSet {
    /// Returns an array of strings describing the contents of this `CharacterSet`.
    fileprivate var traits: [String] {
        var desc: [String] = []
        if isSuperset(of: .newlines) {
            desc.append("newlines")
        }
        if isSuperset(of: .whitespaces) {
            desc.append("whitespace")
        }
        if isSuperset(of: .capitalizedLetters) {
            desc.append("A-Z")
        }
        if isSuperset(of: .lowercaseLetters) {
            desc.append("a-z")
        }
        if isSuperset(of: .decimalDigits) {
            desc.append("0-9")
        }
        return desc
    }
}

// MARK: - Custom .isPast Validator

extension Validator where T == Date {
    /// Validates whether a `Date`is in the Past.
    public static var past: Validator<T> {
        return IsPastValidator().validator()
    }
}

/// Validates whether a date is in the past.
fileprivate struct IsPastValidator: ValidatorType {
    /// See `ValidatorType`.
    public var validatorReadable: String {
        "date is in the past"
    }

    /// See `Validator`.
    public func validate(_ d: Date) throws {
        guard d < Date() else {
            throw BasicValidationError("date is not in the past")
        }
    }
}
