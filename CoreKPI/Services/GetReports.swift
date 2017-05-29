//
//  GetReports.swift
//  CoreKPI
//
//  Created by Семен on 27.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

enum ReportPeriod
{
    case daily
    case weekly
    case monthly
}

typealias reportTuple = (date: Date, number: Double)

class GetReports: Request {
    
    func getReportForKPI(withID kpiID: Int,
                         period: AlertTimeInterval,
                         success: @escaping ([(date: Date, number: Double)]) -> (),
                         failure: @escaping failure) {
        
        var data: [String : Any] = ["kpi_id" : kpiID]
        let calendar = Calendar.current
        var startDate: Date!
        var endDate: Date!
        let formatter = DateFormatter()
        let date      = Date()
        let year = calendar.component(.year, from: date)
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //2017-04-01 09:21:03
        
        if period == .Daily
        {
            startDate = date.beginningOfMonth!
            endDate   = date.endOfMonth!
        }
        else
        {
            startDate = formatter.date(from: "\(year)-01-01 05:00:00")
            endDate   = formatter.date(from: "\(year)-12-31 23:59:59")
        }        
        
        data["start_date"] = formatter.string(from: startDate)
        data["end_date"]   = formatter.string(from: endDate)
        
        self.getJson(category: "/kpi/getKPIDetails", data: data,
                     success: { json in
                        if let reports = self.parsingJson(json: json) {
                            success(reports)
                        } else {
                            failure(self.errorMessage ?? "Wrong data from server")
                        }
        },
                     failure: { (error) in
                        failure(error)
        }
        )
    }
    
    private func parsingJson(json: NSDictionary) -> [(date: Date, number: Double)]? {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSArray {
                    var arrayOfReports: [(date: Date, number: Double)] = []
                    var ReportsEndParsing = false
                    var report = 0
                    while ReportsEndParsing == false {
                        
                        if dataKey.count > 0, let reportData = dataKey[report] as? NSDictionary {
                            
                            let dateString = reportData["submit_date"] as! String
                            let value = reportData["kpi_value"] as! Double
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let date = dateFormatter.date(from: dateString)
                            
                            arrayOfReports.append((date!, value))
                        } else {
                            return arrayOfReports
                        }
                        
                        report+=1
                        if dataKey.count == report {
                            ReportsEndParsing = true
                        }
                    }
                    let reports = arrayOfReports.sorted{$0.0 > $1.0}
                    
                    return reports
                } else {
                    print("Json data is broken")
                }
            } else {
                self.errorMessage = json["message"] as? String
            }
        } else {
            print("Json file is broken!")
        }
        return nil
    }
    
    func filterReports(kpi: KPI, reports: [reportTuple]) -> [reportTuple] {
        
        let reports = reports.reversed().map { r -> reportTuple in
            let report = reportTuple(date: r.date, number: r.number)
            return report
        }
        
        var filteredReports: [reportTuple] = []
        
        switch kpi.createdKPI!.timeInterval
        {
        case .Daily:   filteredReports.append(contentsOf: reports)
        case .Weekly:  filteredReports.append(contentsOf: weeklyFiltered(reports: reports))
        case .Monthly: filteredReports.append(contentsOf: weeklyFiltered(reports: reports))
        }
        
        return filteredReports
    }
    
    private func montlyFiltered(reports: [reportTuple]) -> [reportTuple] {
        
        var resultReport = [reportTuple]()
        let startOfCurrentMonth = Date().beginningOfMonth
        let endOfCurrentMonth   = Date().endOfMonth
        
        return resultReport
    }
    
    private func weeklyFiltered(reports: [reportTuple]) -> [reportTuple] {
        
        var resultReport = [reportTuple]()
        
        let calendar = Calendar.current
        let weeksToCalculate = 5
        let currentDate = Date()
        let weekComponents = calendar.dateComponents([.weekOfYear,.yearForWeekOfYear],
                                                     from: currentDate)
        let currentWeek = calendar.date(from: weekComponents)
        
        guard let startOfCurrentWeek = currentWeek else { return resultReport }
        
        for weekCounter in 0..<weeksToCalculate
        {
            let weekStart = calendar.date(byAdding: .weekOfYear,
                                          value: -weekCounter,
                                          to: startOfCurrentWeek)!
            
            let weekEnd = calendar.date(byAdding: .weekOfYear,
                                        value: 1,
                                        to: weekStart)!
            
            var intermediateResult = [reportTuple]()
            
            intermediateResult.append(contentsOf: reports.filter {
                $0.date >= weekStart && $0.date <= weekEnd
            })
            
            guard intermediateResult.count > 0 else { continue }
            
            let maximumWeekReportValue = intermediateResult.reduce(0) {
                (result, tuple) -> Double in
                if tuple.number > result
                {
                    return tuple.number
                }
                return result
            }
            
            let maximumWeekReport = intermediateResult.filter {
                $0.number == maximumWeekReportValue
            }.first
            
            if let result = maximumWeekReport { resultReport.append(result) }
        }
        return resultReport
    }
}




















