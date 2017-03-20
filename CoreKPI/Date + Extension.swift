//
//  Date + Extension.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 17.03.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

extension Date
{
    var beginningOfMonth: Date? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: self)
        let components = calendar.dateComponents([.year, .month], from: startOfDay)
        let startOfMonth = calendar.date(from: components)
        
        return startOfMonth
    }
    
    var endOfMonth: Date? {
        let calendar = Calendar.current
        
        if let date = beginningOfMonth, let range = calendar.range(of: .day, in: .month, for: date)
        {
            return calendar.date(byAdding: DateComponents(day: range.upperBound - 2), to: date)
        }
        else { return nil }
    }
    
    func stringForQuickbooksQueryFrom(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "''yyyy-MM-dd'T'hh:mm:ssZZZZZ''"
        
        let formattedString = dateFormatter.string(from: date)
        
        return formattedString
    }
}
