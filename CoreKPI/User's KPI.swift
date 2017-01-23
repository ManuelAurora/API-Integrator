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
    var deadline: String
    var number: [(date: String,number: Double)]
    mutating func addReport(report: Double) {
        number.append(("Today", report))
    }
}
