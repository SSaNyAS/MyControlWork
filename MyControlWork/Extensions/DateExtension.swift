//
//  DateExtension.swift
//  MyControlWork
//
//  Created by Александр Шандыба on 25.10.2022.
//

import Foundation
extension Date{
    // приводим дату к формату День.Месяц.Год
    func shortFormat() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: self)
    }
    // приводим дату к формату День.Месяц.Год часы(24формат): минуты
    func shortFormatWithTime() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.string(from: self)
    }
    // Получаем дату из строки по формату
    static func dateFromString(string: String) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.date(from: string)
    }
}
