//
//  AddKPI.swift
//  CoreKPI
//
//  Created by Семен on 26.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class AddKPI: Request {
    
    func addKPI(kpi: KPI, success: @escaping (_ KPIid: Int) -> (), failure: @escaping failure) {
        
        var data: [String : Any] = [:]
        
        switch kpi.typeOfKPI
        {
        case .createdKPI:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            let deadlineTime = dateFormatter.string(from: (kpi.createdKPI?.deadlineTime)!)
            
            let abbreviaion = kpi.createdKPI?.timeZone.components(separatedBy: "(")[1].replacingOccurrences(of: ")", with: "")
            let timeZone = TimeZone(abbreviation: abbreviaion!)
            let timeZoneHoursFromGMT = (timeZone?.secondsFromGMT())!/3600
            let firstChart = kpi.KPIChartOne == nil ?
                "Numbers" : kpi.KPIChartOne!.rawValue
            
            let secondChart = kpi.KPIChartTwo == nil ?
                "Numbers" : kpi.KPIChartTwo!.rawValue
            
            let color = kpi.imageBacgroundColour.getHexString()
            
            guard let createdKPI = kpi.createdKPI else {
                fatalError("Created KPI is not createdKPI")
            }
            
            data = ["name":           createdKPI.KPI,
                    "description":    createdKPI.descriptionOfKPI ?? "",
                    "department":     createdKPI.department.rawValue,
                    "responsible_id": createdKPI.executant,
                    "interval":       createdKPI.timeInterval.rawValue,
                    "delivery_day":   createdKPI.deadlineDay,
                    "deadline":       deadlineTime,
                    "timezone":       timeZoneHoursFromGMT,
                    "view1":          firstChart,
                    "view2":          secondChart,
                    "color":          color
            ]
            
        case .IntegratedKPI:
            break
            //TODO: Add external KPI
        }
        
        self.getJson(category: "/kpi/addKPI", data: data,
                     success: { json in
                        if let id = self.parsingJson(json: json) {
                            success(id)
                        } else {
                            failure(self.errorMessage ?? "Wrong data from server")
                        }
        },
                     failure: { (error) in
                        failure(error)
        }
        )
    }
    
    func parsingJson(json: NSDictionary) -> Int? {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let data = json["data"] as? NSDictionary {
                    let id = data["id"] as! Int
                    return id
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
