//
//  User's KPI.swift
//  CoreKPI
//
//  Created by Семен on 20.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

//MARK: - Structs for KPIs

struct CreatedKPI
{    
    var department: Departments
    var KPI: String
    var descriptionOfKPI: String?
    var executant: Int
    var timeInterval: AlertTimeInterval
    var deadlineDay: Int //Daily : 1, Weekly : 1-7, Mounthly : 1-31
    var timeZone: String
    var deadlineTime: Date    
    var number: [(date: Date, number: Double)]
    mutating func addReport(date: Date, report: Double) {
        
        let calendar   = Calendar.current
        let currentDay = calendar.component(.day, from: Date())
        let reportDay  = calendar.component(.day, from: date)
        
        if currentDay == reportDay
        {
            if number.count > 0 { number.remove(at: 0) }
            number.insert((date, report), at: 0)
        }
    }
}
