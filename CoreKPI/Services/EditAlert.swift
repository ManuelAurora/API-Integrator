//
//  EditAlert.swift
//  CoreKPI
//
//  Created by Семен on 17.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class EditAlert: Request {
    
    func editAlert(alert: Alert, success: @escaping () -> (), failure: @escaping failure) {
        
        var notificationArray: [String] = []
        if alert.emailNotificationIsActive {
            notificationArray.append("E-mail")
        }
        if alert.smsNotificationIsAcive {
            notificationArray.append("SMS")
        }
        if alert.pushNotificationIsActive {
            notificationArray.append("Push")
        }
        
        let timeZone = TimeZone.current.abbreviation()
        let timeZoneNumber  = timeZone?.replacingOccurrences(of: "GMT", with: "")
        
        
        let data: [String : Any] = ["kpi_id" : alert.sourceID, "methods" : notificationArray, "condition" : alert.condition!, "condition_value" : alert.threshold, "days" : alert.onlyWorkHours ? 1 : 0, "timezone" : timeZoneNumber!]
        
        self.getJson(category: "/alerts/editAlert", data: data,
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
