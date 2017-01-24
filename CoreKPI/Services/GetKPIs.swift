//
//  GetKPIs.swift
//  CoreKPI
//
//  Created by Семен on 24.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

class GetKPIs: Request {
    
    func getKPIsFromServer(success: @escaping (_ arrayOfKPI: [KPI]) -> (), failure: @escaping failure) {
        
        let data: [String : Any] = [:]
        
        self.getJson(category: "/kpi/getKPIList", data: data,
                        success: { json in
                            if let arrayOfKPI = self.parsingJson(json: json) {
                                success(arrayOfKPI)
                            } else {
                                failure(self.errorMessage ?? "Wrong data from server")
                            }
        },
                        failure: { (error) in
                            failure(error)
        })
    }
    
    func parsingJson(json: NSDictionary) -> [KPI]? {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSArray {
                    var arrayOfKPI: [KPI] = []
                    var KPIListEndParsing = false
                    var kpi = 0
                    while KPIListEndParsing == false {
                        var active = 0
                        var id = 0
                        let typeOfKPI = TypeOfKPI.createdKPI
                        
                        //var image: ImageForKPIList!
                        
                        let source = Source.User
                        var department: String
                        var kpi_name: String
                        var descriptionOfKPI: String?
                        var executant: Int
                        let timeInterval = TimeInterval.Daily.rawValue
                        var timeZone: String
                        var deadline: String
                        var number: [(String, Double)]
                        
                        
                        if let kpiData = dataKey[kpi] as? NSDictionary {
                            active = (kpiData["active"] as? Int) ?? 0
                            id = (kpiData["id"] as? Int) ?? 0
                            kpi_name = (kpiData["name"] as? String) ?? "Error name"
                            department = (kpiData["department"] as? String) ?? "Error department"
                            descriptionOfKPI = kpiData["desc"] as? String
                            executant = (self.userID)! // debug!
                            timeZone = "no"
                            deadline = (kpiData["datetime"] as? String)!
                            number = []
                            //debug
                            //image = ImageForKPIList.Increases
                            
                            print("id: \(id); active: \(active)")
                            
                            let createdKPI = CreatedKPI(source: source, department: Departments(rawValue: department)!, KPI: kpi_name, descriptionOfKPI: descriptionOfKPI, executant: executant, timeInterval: TimeInterval(rawValue: timeInterval)!, timeZone: timeZone, deadline: deadline, number: number)
                            let kpi = KPI(typeOfKPI: typeOfKPI, integratedKPI: nil, createdKPI: createdKPI, imageBacgroundColour: UIColor.clear)
                            arrayOfKPI.append(kpi)
                        }
                        
                        kpi+=1
                        if dataKey.count == kpi {
                            KPIListEndParsing = true
                        }
                    }
                    return arrayOfKPI
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
