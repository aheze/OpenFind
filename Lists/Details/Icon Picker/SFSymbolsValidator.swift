//
//  SFSymbolsValidator.swift
//  
//
//  Created by Santoso, Michael Abadi on 1/1/2564 BE.
//

import Foundation

protocol SFSymbolsValidation {
    func validateSystemName<T: SFFinderConvertible>(for type: T) -> String
}


final class SFSymbolsValidator: SFSymbolsValidation {

    func validateSystemName<T>(for type: T) -> String where T : SFFinderConvertible {
        switch type {
        case let type as SFSymbolsEnum:
            if let objectType = type as? ObjectAndTools, objectType == .oneMagnifyingglass {
                return "1.magnifyingglass"
            } else if let objectType = type as? All, (objectType == .fourkTv || objectType == .fourkTvFill) {
                if objectType == .fourkTv {
                    return "4.k.tv"
                } else {
                    return "4.k.tv.fill"
                }
            } else {
                var finalName = ""
                var previousChar: Character = Character("-")
                type.enumRawValue.forEach { char in
                    if char.isUppercase {
                        finalName += ".\(char.lowercased())"
                    } else if char.isNumber {
                        if previousChar == "x" {
                            finalName += char.description
                        } else {
                            finalName += ".\(char)"
                        }
                    } else {
                        finalName += char.description
                    }
                    previousChar = char
                }
                return finalName
            }
        default:
            return ""
        }
    }
}
