//
//  GetReports.swift
//  CoreKPI
//
//  Created by Семен on 27.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class GetReports: Request {
    
    func getReportForKPI(withID kpiID: Int, success: @escaping ([String : Double]) -> (), failure: @escaping failure) {
        
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
    
    func parsingJson(json: NSDictionary) -> [String : Double]? {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSArray {
                    var dictionaryOfReports: [String : Double] = [:]
                    var ReportsEndParsing = false
                    var report = 0
                    while ReportsEndParsing == false {
                        
                        if dataKey.count > 0, let reportData = dataKey[report] as? NSDictionary {

                            let date = reportData["submit_date"] as! String
                            let value = reportData["kpi_value"] as! Double
                            
                            dictionaryOfReports[date] = value
                        } else {
                            return dictionaryOfReports
                        }
                        
                        report+=1
                        if dataKey.count == report {
                            ReportsEndParsing = true
                        }
                    }
                    return dictionaryOfReports
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
    
}
