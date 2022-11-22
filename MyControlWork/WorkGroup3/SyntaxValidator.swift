//
//  SyntaxValidator.swift
//  MyControlWork
//
//  Created by Александр Шандыба on 18.10.2022.
//

import UIKit
protocol SyntaxValidatorProtocol: AnyObject{
    func validateStringRow(row: String, openSymbol: String, closeSymbol: String) -> [NSRange]
}

class SyntaxValidator: SyntaxValidatorProtocol{
    // принимает открывающий и закрывающий тег и возвращает индексы в строке где есть ошибки
    func validateStringRow(row: String, openSymbol: String, closeSymbol: String) -> [NSRange]{
        var errorRanges: [NSRange] = []
        let rowRange = NSRange(location: 0, length: row.count)
        var regex: NSRegularExpression?
        
        // проверка что символ является системным и к нему необходимо добавить \
        let openSymbolIsSpecial = openSymbol.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil
        let closeSymbolIsSpecial = closeSymbol.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil
        regex = try? NSRegularExpression(pattern: "((\(openSymbolIsSpecial ? "\\" + openSymbol : openSymbol))+([\\s\\S]*)(\(closeSymbolIsSpecial ? "\\" + closeSymbol : closeSymbol))+)+|(((\(openSymbolIsSpecial ? "\\" + openSymbol : openSymbol))))+|((\(closeSymbolIsSpecial ? "\\" + closeSymbol : closeSymbol)+))")
        
        guard let regexClosedSuccess = regex else {
            return errorRanges
        }
        // c помощью регулярного выражения ищем совпадения в строке
        let matches = regexClosedSuccess.matches(in: row, range: rowRange)
        if matches.count == 0 {
            return errorRanges
        }
        for match in matches {
            let range = match.range
            let rowStartIndex = row.index(row.startIndex, offsetBy: range.location)
            let rowEndIndex = row.index(rowStartIndex, offsetBy: range.length)
            let substring = String(row[rowStartIndex..<rowEndIndex])
            // выше удалили лишние данные и сейчас строка вида -> (тут какието данные)
            if substring.isEmpty || (substring.count == openSymbol.count || substring.count == closeSymbol.count) {
                errorRanges.append(range)
                continue
            }
            // ниже считаем количество символов открывающих и закрывающих и записываем их индексы
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
            // если количество символов открывающих и закрывающих одинаково то мы переходим к следующему совпадению
            if openSymbolsId.isEmpty && closeSymbolsId.isEmpty{
                continue
            }
            // добавляем в возвращаемый массив индексы ошибочных мест
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
            
            // удаляем первую и последнюю скобку
            var sendToHandleRow = substring
            if sendToHandleRow.count > 1{
                if sendToHandleRow.hasPrefix(openSymbol){
                    sendToHandleRow.removeFirst(openSymbol.count)
                }
                if sendToHandleRow.hasSuffix(closeSymbol){
                    sendToHandleRow.removeLast(closeSymbol.count)
                }
            }
            // вызываем рекурсивно эту же функцию и передаем туда строку уже которая содержится между тегами
            let errorRangeInSubString = validateStringRow(row: sendToHandleRow, openSymbol: openSymbol, closeSymbol: closeSymbol)
            // если в ней есть ошибки то мы их добавляем к возращаемому результату с учетом смещения изза удаление открывающих или закрывающих тегов
            if errorRangeInSubString.count > 0{
                for erroredRange in errorRangeInSubString {
                    if sendToHandleRow.count == substring.count{
                        errorRanges.append(NSRange(location: range.location + erroredRange.location, length: erroredRange.length))
                    } else {
                        errorRanges.append(NSRange(location: range.location + openSymbol.count + erroredRange.location, length: erroredRange.length))
                    }
                }
            }
        }
        
        return errorRanges
    }
}
