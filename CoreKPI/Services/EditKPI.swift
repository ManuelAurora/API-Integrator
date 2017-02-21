//
//  EditKPI.swift
//  CoreKPI
//
//  Created by Семен on 27.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class EditKPI: Request {
    
    func editKPI(kpi: KPI, success: @escaping () -> (), failure: @escaping failure) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let deadlineTime = dateFormatter.string(from: (kpi.createdKPI?.deadlineTime)!)
        
        let abbreviaion = kpi.createdKPI?.timeZone.components(separatedBy: "(")[1].replacingOccurrences(of: ")", with: "")
        let timeZone = TimeZone(abbreviation: abbreviaion!)
        let timeZoneHoursFromGMT = (timeZone?.secondsFromGMT())!/3600
        
        var viewOne: String {
            if kpi.KPIViewOne == .Numbers {
                return TypeOfKPIView.Numbers.rawValue
            } else {
                return (kpi.KPIChartOne?.rawValue)!
            }
        }
        
        var viewTwo: String {
            if kpi.KPIViewTwo == .Numbers {
                return TypeOfKPIView.Numbers.rawValue
            } else {
                return (kpi.KPIChartTwo?.rawValue)!
            }
        }
        
        let data: [String : Any] = ["kpi_id" : kpi.id ,"name" : (kpi.createdKPI?.KPI)!, "description" : kpi.createdKPI?.descriptionOfKPI ?? "", "department" : (kpi.createdKPI?.department.rawValue)!, "responsible_id" : (kpi.createdKPI?.executant)!, "interval" : (kpi.createdKPI?.timeInterval.rawValue)!, "deadline" : deadlineTime, "delivery_day" : kpi.createdKPI?.deadlineDay ?? 1, "view1" : viewOne, "view2" : viewTwo, "color" : kpi.imageBacgroundColour.getHexString(), "timezone" : timeZoneHoursFromGMT]
        
        self.getJson(category: "/kpi/updateKPI", data: data,
                     success: { json in
                        if self.parsingJson(json: json) {
                            success()
                        } else {
                            failure(self.errorMessage ?? "Wrong data from server")
                        }
        },
                     failure: { (error) in
                        failure(error)
        }
        )
    }
    
    func parsingJson(json: NSDictionary) -> Bool {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                return true
            } else {
                self.errorMessage = json["message"] as? String
            }
        } else {
            print("Json file is broken!")
        }
        return false
    }
    
}
