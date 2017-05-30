//
//  ReportFilter.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 30.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

enum ReportFilter
{
    case monthly(Int)
    case daily
    case weekly(Int)
    
    private static var reports = [reportTuple]()
    
    private var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 2
        return cal
    }
    
    func filter( _ reports: [reportTuple]) -> [reportTuple] {
        
        ReportFilter.reports = reports
        
        switch self
        {
        case .daily: return filterReportsByDays()
        case .weekly(let weekday): return weeklyReportsWith(reportDay: weekday)
        case .monthly(let day): return monthlyReportsWith(reportDay: day)
        }
    }
    
    private func filterReportsByDays() -> [reportTuple] {
        
        var filteredResult = [reportTuple]()
        
        ReportFilter.reports.forEach { report in
            guard let lastReport = filteredResult.last else {
                filteredResult.append(report)
                return
            }
            
            let isReportsInOneDay = calendar.isDate(report.date,
                                                    equalTo: lastReport.date,
                                                    toGranularity: .day)
            
            if isReportsInOneDay
            {
                if report.date > lastReport.date
                {
                    filteredResult.removeLast()
                    filteredResult.append(report)
                }
            }
            else { filteredResult.append(report) }
        }
        return filteredResult
    }
    
    private func weeklyReportsWith(reportDay: Int) -> [reportTuple] {
        
        let weeksToCalculate = 5
        let currentDate = Date()
        var weekComponents = calendar.dateComponents([.weekOfYear,.yearForWeekOfYear],
                                                     from: currentDate)
        weekComponents.weekday = reportDay + 1 // + Monday
        weekComponents.hour = 23
        weekComponents.minute = 59
        weekComponents.second = 59
        
        let currentWeek = calendar.date(from: weekComponents)!
        
        return reportDataFrom(currentWeek,
                              periodCounter: weeksToCalculate,
                              periodComponent: .weekOfMonth)
    }
    
    private func monthlyReportsWith(reportDay: Int) -> [reportTuple] {
        
        let startOfCurrentMonth = Date().beginningOfMonth!
        let monthsToCalculate   = 12
        
        return reportDataFrom(startOfCurrentMonth,
                              periodCounter: monthsToCalculate,
                              periodComponent: .month)
    }
    
    private func reportDataFrom(_ startDate: Date,
                                periodCounter: Int,
                                periodComponent: Calendar.Component) -> [reportTuple] {
        
        var resultReport = [reportTuple]()
        
        for counter in 0..<periodCounter
        {
            let prevReportDate = calendar.date(byAdding: periodComponent,
                                              value: -counter,
                                              to: startDate)!
            
            let nextReportDate = calendar.date(byAdding: periodComponent,
                                              value: 1,
                                              to: prevReportDate)!
            
            let filteredForPeriod = ReportFilter.reports.filter {
                $0.date >= prevReportDate && $0.date <= nextReportDate
            }
            
            guard filteredForPeriod.count > 0 else { continue }
            
            let sortedReports = filteredForPeriod.sorted { $0.date > $1.date }
            
            if let resultValue = sortedReports.first
            {
                resultReport.append(resultValue)
            }
        }
        return resultReport
    }
}
   
