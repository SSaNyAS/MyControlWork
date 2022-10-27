//
//  DateExtension.swift
//  MyControlWork
//
//  Created by Александр Шандыба on 25.10.2022.
//

import Foundation
extension Date{
    func shortFormat() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: self)
    }
    func shortFormatWithTime() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.string(from: self)
    }
    
    static func dateFromString(string: String) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.date(from: string)
    }
}
