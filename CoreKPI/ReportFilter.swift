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
    case lastThirtyDays
    
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
        case .daily:               return dailyOrderedReport()
        case .weekly(let weekday): return weeklyReportWith(reportDay: weekday)
        case .monthly(let day):    return monthlyReportWith(reportDay: day)
        case .lastThirtyDays:      return lastThirtyDaysReport()
        }
    }
    
    private func lastThirtyDaysReport() -> [reportTuple] {
        
        let startPeriod = Date()
        let endPeriod   = calendar.date(byAdding: .day,
                                        value: -30,
                                        to: startPeriod)!
        
        return dailyOrderedReport().filter {
            $0.date <= startPeriod && $0.date >= endPeriod
        }
    }
    
    private func dailyOrderedReport() -> [reportTuple] {
        
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
    
    private func weeklyReportWith(reportDay: Int) -> [reportTuple] {
        
        let weeksToCalculate = 5
        let currentWeek      = startDateFrom(components: [.weekOfYear,.yearForWeekOfYear],
                                             reportDay: reportDay)
    
        return reportDataFrom(currentWeek,
                              periodCounter: weeksToCalculate,
                              periodComponent: .weekOfMonth)
    }
    
    private func monthlyReportWith(reportDay: Int) -> [reportTuple] {
        
        let monthsToCalculate   = 12
        let startOfCurrentMonth = startDateFrom(components: [.month,.year],
                                                reportDay: reportDay)

        return reportDataFrom(startOfCurrentMonth,
                              periodCounter: monthsToCalculate,
                              periodComponent: .month)
    }
    
    private func startDateFrom(components: Set<Calendar.Component>, reportDay: Int) -> Date {
        
        var dateComponents = calendar.dateComponents(components,
                                                     from: Date())
        
        let isWeekday = components.contains(.weekOfYear) // + Monday
        
        dateComponents.weekday = isWeekday ? reportDay + 1 : reportDay
        dateComponents.hour    = 23
        dateComponents.minute  = 59
        dateComponents.second  = 59
        
        return calendar.date(from: dateComponents)!
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
   
