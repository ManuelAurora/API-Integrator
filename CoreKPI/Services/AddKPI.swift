//
//  AddKPI.swift
//  CoreKPI
//
//  Created by Семен on 26.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class AddKPI: Request
{
    var type: Int = 0
    var kpiIDs = [Int]()
    
    func addKPI(kpi: KPI, success: @escaping (_ KPIid: Int) -> (), failure: @escaping failure) {
        
        var data: [String : Any] = [:]
        var category = ""
        
        switch kpi.typeOfKPI
        {
        case .createdKPI:
            category = "/kpi/addKPI"
            
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
            
            category = "/kpi/addIntegratedKPI"
            
            let extKPI = kpi.integratedKPI
            var token: String?
            var refreshToken: String?
            var ttl: Int?
            var date: NSDate?
            
            iterateEnum(IntegratedServices.self).forEach {
                if $0.rawValue == extKPI?.serviceName
                {
                    switch $0.rawValue
                    {
                    case IntegratedServices.GoogleAnalytics.rawValue:
                        date = extKPI?.googleAnalyticsKPI?.oAuthTokenExpiresAt
                        token = extKPI?.googleAnalyticsKPI?.oAuthToken
                        refreshToken = extKPI?.googleAnalyticsKPI?.oAuthRefreshToken
                        
                    case IntegratedServices.HubSpotCRM.rawValue,
                         IntegratedServices.HubSpotMarketing.rawValue:
                        date = extKPI?.hubspotKPI?.validationDate
                        token = extKPI?.hubspotKPI?.oauthToken
                        refreshToken = extKPI?.hubspotKPI?.refreshToken
                                               
                    case IntegratedServices.Quickbooks.rawValue:
                        token = extKPI?.quickbooksKPI?.oAuthToken
                        refreshToken = extKPI?.quickbooksKPI?.oAuthRefreshToken
                        date = extKPI?.quickbooksKPI?.oAuthTokenExpiresAt
                        
                    case IntegratedServices.SalesForce.rawValue:
                        token = extKPI?.saleForceKPI?.oAuthToken
                        refreshToken = extKPI?.saleForceKPI?.oAuthRefreshToken
                        date = extKPI?.saleForceKPI?.oAuthTokenExpiresAt
                        
                    default: break
                    }
                }
            }
            
            ttl = getSecondsFrom(date: date)
            
            data = ["token": token ?? "",
                    "refresh_token": refreshToken ?? "",
                    "ttl": ttl ?? 0,
                    "token_type": type,
                    "items": kpiIDs
            ]
        }
        //token, token_type, refresh_token, ttl, items[ kpi_id_1, kpi_id_2….]
        self.getJson(category: category, data: data,
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
    
    private func getSecondsFrom(date: NSDate?) -> Int {
        
        let calendar = Calendar.current
        
        let currentDate = Date()
        
        guard let ttlDate = date else { return 0 }
        
        let components = calendar.dateComponents([.second],
                                              from: currentDate,
                                              to: ttlDate as Date)
        
        return components.second!
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
