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
        
        let reports = ReportFilter.reports
        var resultReport = [reportTuple]()
        
        let weeksToCalculate = 5
        let currentDate = Date()
        var weekComponents = calendar.dateComponents([.weekOfYear,.yearForWeekOfYear],
                                                     from: currentDate)
        weekComponents.weekday = reportDay + 1 // + Monday
        weekComponents.hour = 23
        weekComponents.minute = 59
        weekComponents.second = 59
        
        let currentWeek = calendar.date(from: weekComponents)
        
        guard let startOfCurrentWeek = currentWeek else { return resultReport }
        
        for weekCounter in 0..<weeksToCalculate
        {
            let prevReportDay = calendar.date(byAdding: .weekOfYear,
                                              value: -weekCounter,
                                              to: startOfCurrentWeek)!
            
            let nextReportDay = calendar.date(byAdding: .weekOfYear,
                                                value: 1,
                                                to: prevReportDay)!
            
            let weeklyReport = reports.filter {
                $0.date >= prevReportDay && $0.date <= nextReportDay
            }
            
            guard weeklyReport.count > 0 else { continue }
            
            resultReport.append(contentsOf: getValueFrom(reports: weeklyReport))
        }
        return resultReport
    }
    
    private func monthlyReportsWith(reportDay: Int) -> [reportTuple] {
        
        var resultReport        = [reportTuple]()
        let startOfCurrentMonth = Date().beginningOfMonth!
        let monthsToCalculate    = 12
        
        for monthCounter in 0..<monthsToCalculate
        {
            let monthStart = calendar.date(byAdding: .month,
                                           value: -monthCounter,
                                           to: startOfCurrentMonth)!
            
            let monthEnd = calendar.date(byAdding: .month,
                                         value: 1,
                                         to: monthStart)!
            
            let monthlyReport = ReportFilter.reports.filter {
                $0.date >= monthStart && $0.date <= monthEnd
            }
            
            guard monthlyReport.count > 0 else { continue }
            
            resultReport.append(contentsOf: getValueFrom(reports: monthlyReport))
        }
        return resultReport
    }
    
    private func getValueFrom(reports: [reportTuple]) -> [reportTuple] {
        
        var resultReport = [reportTuple]()
        
        let sortedReports = reports.sorted { $0.date > $1.date }
        
        if let resultValue = sortedReports.first
        {
            resultReport.append(resultValue)
        }
        
        return resultReport
    }
}
