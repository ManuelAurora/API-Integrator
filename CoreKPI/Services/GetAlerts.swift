//
//  LoadAlerts.swift
//  CoreKPI
//
//  Created by Семен on 01.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

class GetAlerts: Request {
    
    func getAlerts(success: @escaping ([Alert]) -> (), failure: @escaping failure) {
        
        let data: [String : Any] = [:]
        
        self.getJson(category: "/alerts/getAlerts", data: data,
                     success: { json in
                        if let alertArray = self.parsingJson(json: json) {
                            success(alertArray)
                        } else {
                            failure(self.errorMessage ?? "Wrong data from server")
                        }
        },
                     failure: { (error) in
                        failure(error)
        }
        )
    }
    
    func parsingJson(json: NSDictionary) -> [Alert]?  {
        
        let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                    if let items = json["data"] as? NSArray, items.count > 0 {
                        var alertArray: [Alert] = []
                        for i in 0..<items.count {
                            let alert = items[i] as! NSDictionary
                            let newAlert = Alert(context: context)
                            newAlert.sourceID = alert["kpi_id"] as! Int64
                            newAlert.condition = alert["condition"] as? String
                            newAlert.threshold = alert["condition_value"] as! Double
                            let days = alert["days"] as! Int64
                            newAlert.onlyWorkHours = days == 0 ? false : true
                            newAlert.alertID = alert["id"] as! Int64
                            
                         //   newAlert.timezone = timezoneTitleFrom(hoursFromGMT: <#T##String#>)
                            
                            if let typeOfNotifications = alert["methods"] as? NSArray, typeOfNotifications.count > 0 {
                                
                                newAlert.emailNotificationIsActive = false
                                newAlert.smsNotificationIsAcive = false
                                newAlert.pushNotificationIsActive = false
                                
                                for notification in 0..<typeOfNotifications.count {
                                    
                                    switch typeOfNotifications[notification] as! String {
                                    case "E-mail":
                                        newAlert.emailNotificationIsActive = true
                                    case "SMS":
                                        newAlert.smsNotificationIsAcive = true
                                    case "Push":
                                        newAlert.pushNotificationIsActive = true
                                    default:
                                        break
                                    }
                                }
                                alertArray.append(newAlert)
                            } else {
                                print("Alert with id: \(newAlert.alertID) has not notification!")
                            }
                        }
                        return alertArray
                    } else {
                        print("Alert list is empty")
                        return []
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
