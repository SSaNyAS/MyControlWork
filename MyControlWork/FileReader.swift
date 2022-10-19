//
//  FileReader.swift
//  MyControlWork
//
//  Created by Александр Шандыба on 18.10.2022.
//

import UIKit

enum BracketSymbol: String{
    case figureOpenTag = "{"
    case figureCloseTag = "}"
    
    case undefined
    init?(rawValue: String) {
        switch rawValue{
        case "{":
            self = .figureOpenTag
        case "}":
            self = .figureCloseTag
        default:
            self = .undefined
        }
    }
}

class SyntaxValidator{
    func validateStringRow(row: String, openSymbol: String, closeSymbol: String) -> [NSRange]{
        var errorRanges: [NSRange] = []
        let rowRange = NSRange(location: 0, length: row.count)
        var regex: NSRegularExpression?
        // check if symbols is escaping
        let openSymbolIsSpecial = openSymbol.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil
        let closeSymbolIsSpecial = closeSymbol.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil
        regex = try? NSRegularExpression(pattern: "((\(openSymbolIsSpecial ? "\\" + openSymbol : openSymbol))+([\\s\\S]*)(\(closeSymbolIsSpecial ? "\\" + closeSymbol : closeSymbol))+)+|(((\(openSymbolIsSpecial ? "\\" + openSymbol : openSymbol))))+|((\(closeSymbolIsSpecial ? "\\" + closeSymbol : closeSymbol)+))")
        
        guard let regexClosedSuccess = regex else {
            return errorRanges
        }
        
        let matches = regexClosedSuccess.matches(in: row, range: rowRange)
        if matches.count == 0 {
            return errorRanges
        }
        for match in matches {
            let range = match.range
            let rowStartIndex = row.index(row.startIndex, offsetBy: range.location)
            let rowEndIndex = row.index(rowStartIndex, offsetBy: range.length)
            let substring = String(row[rowStartIndex..<rowEndIndex])
            if substring.isEmpty || (substring.count == openSymbol.count || substring.count == closeSymbol.count) {
                errorRanges.append(range)
                continue
            }
            var openSymbolsId: [Int] = []
            var closeSymbolsId: [Int] = []
            for substringCharId in 0..<substring.count{
                let currentOffset = substring.index(substring.startIndex, offsetBy: substringCharId)
                let stringWithOffset = substring[currentOffset..<substring.endIndex]
                if stringWithOffset.hasPrefix(openSymbol){
                    openSymbolsId.append(substringCharId)
                }
                if stringWithOffset.hasPrefix(closeSymbol){
                    if openSymbolsId.count > 0{
                        openSymbolsId.removeLast()
                    } else {
                        closeSymbolsId.append(substringCharId)
                    }
                }
            }
            if openSymbolsId.isEmpty && closeSymbolsId.isEmpty{
                continue
            }
            if (substring.count == openSymbolsId.count) || (substring.count == closeSymbolsId.count) {
                for id in 0..<max(openSymbolsId.count, closeSymbolsId.count) {
                    if id < openSymbolsId.count{
                        let range = NSRange(location: range.location + openSymbolsId[id], length: openSymbol.count)
                        errorRanges.append(range)
                    }
                    if id < closeSymbolsId.count{
                        let range = NSRange(location: range.location + closeSymbolsId[id], length: closeSymbol.count)
                        errorRanges.append(range)
                    }
                }
                continue
            }
            
            // used to remove brackets
            var sendToHandleRow = substring
            if sendToHandleRow.count > 1{
                if sendToHandleRow.hasPrefix(openSymbol){
                    sendToHandleRow.removeFirst(openSymbol.count)
                }
                if sendToHandleRow.hasSuffix(closeSymbol){
                    sendToHandleRow.removeLast(closeSymbol.count)
                }
            }
            
            let errorRangeInSubString = validateStringRow(row: sendToHandleRow, openSymbol: openSymbol, closeSymbol: closeSymbol)
            if errorRangeInSubString.count > 0{
                for erroredRange in errorRangeInSubString {
                    if sendToHandleRow.count == substring.count{
                        errorRanges.append(NSRange(location: range.location + erroredRange.location, length: erroredRange.length))
                    } else {
                        errorRanges.append(NSRange(location: range.location + 1 + erroredRange.location, length: erroredRange.length))
                    }
                }
            }
        }
        
        return errorRanges
    }
}
