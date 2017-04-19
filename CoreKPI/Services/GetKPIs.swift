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
    
    func getUserKPI(userID: Int, success: @escaping (_ arrayOfKPI: [KPI]) -> (), failure: @escaping failure) {
        let data: [String : Any] = ["user_id" : userID]
        
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
                        var id = 0
                        let typeOfKPI = TypeOfKPI.createdKPI
                        let source = Source.User
                        var department: String
                        var kpi_name: String
                        var descriptionOfKPI: String?
                        var executant: Int
                        let timeInterval: String
                        var timeZone: String
                        var deadlineTime: Date
                        var number: [(Date, Double)]
                        var imageBacgroundColour: UIColor
                        var deadlineDay: Int
                        
                        
                        if dataKey.count > 0, let kpiData = dataKey[kpi] as? NSDictionary {
                            
                            if let active = kpiData["active"] as? Int, active == 1 {
                                id = kpiData["id"] as! Int
                                kpi_name = (kpiData["name"] as! String)
                                department = (kpiData["department"] as? String) ?? "Sales"
                                let kpiDescription = kpiData["desc"] as? String
                                descriptionOfKPI = (kpiDescription == "nil") ? nil : kpiDescription
                                executant = kpiData["responsive_id"] as! Int
                                
                                let timeZoneString = kpiData["timezone"] as! String
                                timeZone = timeZoneString //TODO: parsing timeZones
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "HH:mm:ss"
                                let dateStr = kpiData["deadline"] as! String
                                deadlineTime = dateFormatter.date(from: dateStr)!
                                
                                timeInterval = kpiData["interval"] as! String
                                if let imageBacgroundColourString = kpiData["color"] as? String {
                                    imageBacgroundColour = UIColor(hex: imageBacgroundColourString.hex!)
                                } else {
                                    imageBacgroundColour = UIColor.clear
                                }
                                
                                deadlineDay = kpiData["delivery_day"] as! Int
                                number = []
                                
                                let createdKPI = CreatedKPI(source: source, department: Departments(rawValue: department) ?? Departments.none , KPI: kpi_name, descriptionOfKPI: descriptionOfKPI, executant: executant, timeInterval: AlertTimeInterval(rawValue: timeInterval)!,deadlineDay: deadlineDay, timeZone: timeZone, deadlineTime: deadlineTime, number: number)
                                let kpi = KPI(kpiID: id, typeOfKPI: typeOfKPI, integratedKPI: nil, createdKPI: createdKPI, imageBacgroundColour: imageBacgroundColour)
                                
                                let kpiViewOne = kpiData["view1"] as? String
                                let kpiViewTwo = kpiData["view2"] as? String
                                //TODO: Bug finded!!
                                if kpiViewOne == "Numbers" {
                                    kpi.KPIViewOne = .Numbers
                                    kpi.KPIChartOne = nil
                                } else {
                                    kpi.KPIViewOne = .Graph
                                    kpi.KPIChartOne = TypeOfChart(rawValue: kpiViewOne!)
                                }
                                
                                if kpiViewTwo == "Numbers" {
                                    kpi.KPIViewTwo = .Numbers
                                    kpi.KPIChartTwo = nil
                                } else {
                                    kpi.KPIViewTwo = .Graph
                                    kpi.KPIChartTwo = TypeOfChart(rawValue: kpiViewTwo!)
                                }
                
                                arrayOfKPI.append(kpi)
                            }
                        } else {
                            print("KPI list is empty")
                            arrayOfKPI.removeAll()
                            return arrayOfKPI
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
