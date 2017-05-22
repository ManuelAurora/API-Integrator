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
    var kpi: KPI!
    var pipelineIds = [String]()
    
    func addKPI(success: @escaping (_ KPIid: [Int]) -> (), failure: @escaping failure) {
                
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
            var items: [jsonDict] = []
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
                        
                        var options = [String]()
                        
                        kpiIDs.forEach { id in
                            if let siteUrl = extKPI?.googleAnalyticsKPI?.siteURL,
                                let viewID = extKPI?.googleAnalyticsKPI?.viewID
                            {
                                options.append(siteUrl)
                                options.append(viewID)
                                
                                items.append(["kpi_id": id,
                                              "kpi_options": options
                                    ])
                            }
                        }
                        
                    case IntegratedServices.HubSpotCRM.rawValue,
                         IntegratedServices.HubSpotMarketing.rawValue:
                        date = extKPI?.hubspotKPI?.validationDate
                        token = extKPI?.hubspotKPI?.oauthToken
                        refreshToken = extKPI?.hubspotKPI?.refreshToken
                        
                        kpiIDs.forEach { id in
                            var item: jsonDict = ["kpi_id": id,
                                                  "kpi_options":[]
                            ]
                            
                            if id == 34 || id == 39
                            {
                                pipelineIds.forEach {
                                    item["kpi_id"] = id
                                    item["kpi_options"] = [$0]
                                    items.append(item)
                                }
                                return
                            }
                            
                            items.append(item)
                        }
                                               
                    case IntegratedServices.Quickbooks.rawValue:
                        let realmId = extKPI?.quickbooksKPI?.realmId!
                        let tSecret = extKPI?.quickbooksKPI?.oAuthTokenSecret!
                        
                        kpiIDs.forEach { id in
                            items.append(["kpi_id": id,
                                          "kpi_options": [realmId, tSecret]
                                ])
                        }
                        
                        token = extKPI?.quickbooksKPI?.oAuthToken
                        refreshToken = "NoToken"
                        date = Calendar.current.date(byAdding: .month,
                                                     value: 5,
                                                     to: Date()) as NSDate!
                        
                    case IntegratedServices.SalesForce.rawValue:
                        token = extKPI?.saleForceKPI?.oAuthToken
                        refreshToken = extKPI?.saleForceKPI?.oAuthRefreshToken
                        date = Calendar.current.date(byAdding: .hour,
                                                     value: 5,
                                                     to: Date()) as NSDate!
                        
                        kpiIDs.forEach { id in
                            var options = [String]()
                            
                            if let instUrl = kpi.integratedKPI.saleForceKPI?.instance_url
                            {
                                options.append(instUrl)
                            }
                            
                            items.append(["kpi_id": id,
                                          "kpi_options": options
                                ])
                        }
                        
                    case IntegratedServices.PayPal.rawValue:
                        let apiUserName = extKPI?.payPalKPI?.apiUsername ?? ""
                        let apiPassword = extKPI?.payPalKPI?.apiPassword ?? ""
                        let apiSignature = extKPI?.payPalKPI?.apiSignature ?? ""
                        
                        kpiIDs.forEach { id in
                            items.append(["kpi_id": id,
                                          "kpi_options": []
                                ])
                        }
                        token = "\(apiUserName) \(apiPassword)"
                        refreshToken = apiSignature
                        date = Calendar.current.date(byAdding: .month,
                                                     value: 5,
                                                     to: Date()) as NSDate!
                        
                    default: break
                    }
                }
            }
            
            ttl = AddKPI.getSecondsFrom(date: date)
            
            data = ["token": token ?? "",
                    "refresh_token": refreshToken ?? "",
                    "ttl": ttl ?? 0,
                    "token_type": type,
                    "items": items
            ]
        }
        
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
        })
    }
    
    class func getSecondsFrom(date: NSDate?) -> Int {
        
        let calendar = Calendar.current
        
        let currentDate = Date()
        
        guard let ttlDate = date else { return 0 }
        
        let components = calendar.dateComponents([.second],
                                              from: currentDate,
                                              to: ttlDate as Date)
        
        return components.second!
    }
    
    func parsingJson(json: NSDictionary) -> [Int]? {
        
        if let successKey = json["success"] as? Int, successKey == 1
        {
            if let data = json["data"] as? [Int]
            {
                return data
            }
            else if let data = json["data"] as? [String: Int], let id = data["id"]
            {
                return [id]
            }
            else
            {
                self.errorMessage = json["message"] as? String
            }
        } else {
            print("Json file is broken!")
        }
        return nil
    }
}
