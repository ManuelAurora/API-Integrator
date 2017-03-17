//
//  GetReports.swift
//  CoreKPI
//
//  Created by Семен on 27.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class GetReports: Request {
    
    func getReportForKPI(withID kpiID: Int, success: @escaping ([(date: Date, number: Double)]) -> (), failure: @escaping failure) {
        
        let data: [String : Any] = ["kpi_id" : kpiID]
        
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
    
    func filterReports(kpi: KPI, reports: [(date: Date, number: Double)]) -> [(date: Date, number: Double)] {
        
        let reports = reports.reversed()
        
        var filteredReports: [(date: Date, number: Double)] = []
        
        for report in reports {
            if filteredReports.count == 0 {
                let dateOfReport = deadlineDetector(kpi: kpi, report: report)
                let valueOfReport = report.number
                filteredReports.append((dateOfReport, valueOfReport))
            } else {
                let dateOfReport = deadlineDetector(kpi: kpi, report: report)
                let valueOfReport = report.number
                if filteredReports.last?.date == dateOfReport {
                    filteredReports.removeLast()
                    filteredReports.append((dateOfReport, valueOfReport))
                } else {
                    filteredReports.append((dateOfReport, valueOfReport))
                }
            }
        }
        return filteredReports.reversed()
    }
    
    private func deadlineDetector(kpi: KPI, report: (date: Date, number: Double)) -> Date {
        
        let deadlineInterval = kpi.createdKPI?.timeInterval
        let deadlineDay = kpi.createdKPI?.deadlineDay
        let deadlineTime = kpi.createdKPI?.deadlineTime
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        var deadlineTimeComponent = calendar.dateComponents([.hour, .minute, .second], from: deadlineTime!)
        let reportDayComponent = calendar.dateComponents([.year, .month, .day], from: report.date)
        
        deadlineTimeComponent.setValue(reportDayComponent.year, for: .year)
        deadlineTimeComponent.setValue(reportDayComponent.month, for: .month)
        deadlineTimeComponent.setValue(reportDayComponent.day, for: .day)
        
        var deadlineDate = calendar.date(from: deadlineTimeComponent)
        
        
        switch deadlineInterval! {
        case .Daily:
            if report.date > deadlineDate! {
                deadlineDate = calendar.date(byAdding: .day, value: 1, to: deadlineDate!)!
            }
        case .Weekly:
            
            guard var dayOfWeek = deadlineDay else {print("Error day of week");break}
            
            switch dayOfWeek {
            case 7:
                dayOfWeek = 1
            default:
                dayOfWeek += 1
            }
            
            var deadlineDateComponents = calendar.dateComponents([.weekday, .year, .month, .day, .hour, .minute, .second], from: deadlineDate!)
    
            while deadlineDateComponents.weekday != dayOfWeek {
                deadlineDate = calendar.date(byAdding: .weekday, value: 1, to: deadlineDate!)
                deadlineDateComponents = calendar.dateComponents([.weekday, .year, .month, .day, .hour, .minute, .second], from: deadlineDate!)
            }
            
            if report.date > deadlineDate! && calendar.isDate(report.date, inSameDayAs: deadlineDate!) {
                deadlineDate = calendar.date(byAdding: .weekOfYear, value: 1, to: deadlineDate!)!
            }
            
        case .Monthly:
            
            let lastDay = deadlineDate?.endOfMonth()
            let lastDayComponent = calendar.dateComponents([.day], from: lastDay!)
            
            var deadlineDayForCurrentMounth = 0
            
            if lastDayComponent.day! < deadlineDay! {
                deadlineDayForCurrentMounth = lastDayComponent.day!
            } else {
                deadlineDayForCurrentMounth = deadlineDay!
            }
            
            var deadlineDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: deadlineDate!)
            
            while deadlineDateComponents.day != deadlineDayForCurrentMounth {
                
                
                deadlineDate = calendar.date(byAdding: .day, value: 1, to: deadlineDate!)
                deadlineDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: deadlineDate!)
            }
            
            if report.date > deadlineDate! && calendar.isDate(report.date, inSameDayAs: deadlineDate!) {
                deadlineDate = calendar.date(byAdding: .month, value: 1, to: deadlineDate!)!
                var newDeadlineDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: deadlineDate!)
                if newDeadlineDateComponents.day! < deadlineDay! {
                    newDeadlineDateComponents.day = deadlineDay
                    deadlineDate = calendar.date(from: newDeadlineDateComponents)
                }
            }
            
        }
        
        return deadlineDate!
    }
    
}
