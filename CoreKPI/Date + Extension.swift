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
    var calendar: Calendar { return Calendar.current }
    var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'hh:mm:ssZ"
        return f
    }
    
    var beginningOfMonth: Date? {
        let startOfDay = calendar.startOfDay(for: self)
        let components = calendar.dateComponents([.year, .month], from: startOfDay)
        let startOfMonth = calendar.date(from: components)
        
        return startOfMonth
    }
    
    var endOfMonth: Date? {
        
        if let date = beginningOfMonth, let range = calendar.range(of: .day, in: .month, for: date)
        {
            return calendar.date(byAdding: DateComponents(day: range.upperBound - 2), to: date)
        }
        else { return nil }
    }
    
    private func formattedString() -> String
    {
        let formattedString = dateFormatter.string(from: self)
        
        return formattedString
    }
    
    func stringForSalesForceQuery() -> String {
                
        return formattedString()
    }
    
    func stringForQuickbooksQuery() -> String {
        
        return formattedString()
    }
}
