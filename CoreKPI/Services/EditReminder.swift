//
//  EditReminder.swift
//  CoreKPI
//
//  Created by Семен on 17.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class EditReminder: Request {
    
    func editReminder(reminder: Reminder, success: @escaping () -> (), failure: @escaping failure) {
        
        var notificationArray: [String] = []
        if reminder.emailNotificationIsActive {
            notificationArray.append("E-mail")
        }
        if reminder.smsNotificationIsActive {
            notificationArray.append("SMS")
        }
        if reminder.pushNotificationIsActive {
            notificationArray.append("Push")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let deliveryTime = dateFormatter.string(from: reminder.deliveryTime as! Date)
        
        let abbreviaion = reminder.timeZone?.components(separatedBy: "(")[1].replacingOccurrences(of: ")", with: "")
        print(abbreviaion ?? "nil")
        let timeZone = TimeZone(abbreviation: abbreviaion!)
        let timeZoneHoursFromGMT = (timeZone?.secondsFromGMT())!/3600
        
        
        let data: [String : Any] = ["kpi_id" : reminder.sourceID, "methods" : notificationArray, "delivery_day" : reminder.deliveryDay, "delivery_time" : deliveryTime, "interval_type" : reminder.timeInterval ?? "Daily", "timezone" : timeZoneHoursFromGMT]
        
        self.getJson(category: "/reminders/editReminder", data: data,
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
