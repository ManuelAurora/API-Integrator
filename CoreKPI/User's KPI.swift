//
//  User's KPI.swift
//  CoreKPI
//
//  Created by Семен on 20.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

//MARK: - Structs for KPIs

struct CreatedKPI {
    var source: Source
    var department: Departments
    var KPI: String
    var descriptionOfKPI: String?
    var executant: Int
    var timeInterval: TimeInterval
    var timeZone: String
    var deadline: Date
    var number: [(date: Date, number: Double)]
    mutating func addReport(date: Date, report: Double) {
        number.append((date, report))
    }
}
