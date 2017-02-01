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
                        var deadline: Date
                        var number: [(Date, Double)]
                        var imageBacgroundColour: UIColor
                        
                        
                        if dataKey.count > 0, let kpiData = dataKey[kpi] as? NSDictionary {
                            id = kpiData["id"] as! Int
                            kpi_name = (kpiData["name"] as! String)
                            department = (kpiData["department"] as? String) ?? "Sales"
                            let kpiDescription = kpiData["desc"] as? String
                            descriptionOfKPI = (kpiDescription == "nil") ? nil : kpiDescription
                            executant = kpiData["responsive_id"] as! Int
                            timeZone = "no"
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-mm-dd hh:mm:ss"
                            let dateStr = kpiData["deadline"] as! String
                            deadline = dateFormatter.date(from: dateStr)!
                            number = []
                            timeInterval = kpiData["interval"] as! String
                            if let imageBacgroundColourString = kpiData["card_color"] as? String {
                                imageBacgroundColour = hexStringToUIColor(hex: imageBacgroundColourString)
                            } else {
                                imageBacgroundColour = UIColor.clear
                            }
                            
                            let createdKPI = CreatedKPI(source: source, department: Departments(rawValue: department) ?? Departments.none , KPI: kpi_name, descriptionOfKPI: descriptionOfKPI, executant: executant, timeInterval: TimeInterval(rawValue: timeInterval)!, timeZone: timeZone, deadline: deadline, number: number)
                            let kpi = KPI(kpiID: id, typeOfKPI: typeOfKPI, integratedKPI: nil, createdKPI: createdKPI, imageBacgroundColour: imageBacgroundColour)
                            arrayOfKPI.append(kpi)
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
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
