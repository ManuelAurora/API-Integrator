//
//  GetReminders.swift
//  CoreKPI
//
//  Created by Семен on 15.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

class GetReminders: Request {
    
    func getReminders(success: @escaping ([Reminder]) -> (), failure: @escaping failure) {
        
        let data: [String : Any] = [:]
        
        self.getJson(category: "/reminders/getReminders", data: data,
                     success: { json in
                        if let reminderArray = self.parsingJson(json: json) {
                            success(reminderArray)
                        } else {
                            failure(self.errorMessage ?? "Wrong data from server")
                        }
        },
                     failure: { (error) in
                        failure(error)
        }
        )
    }
    
    func parsingJson(json: NSDictionary) -> [Reminder]?  {
        
        let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSDictionary {
                    if let reminders = dataKey["items"] as? NSArray, reminders.count > 0 {
                        var reminderArray: [Reminder] = []
                        for i in 0..<reminders.count {
                            if let reminder = reminders[i] as? NSDictionary {
                                let newReminder = Reminder(context: context)
                                newReminder.reminderID = reminder["id"] as! Int64
                                newReminder.sourceID = reminder["kpi_id"] as! Int64
                                newReminder.timeInterval = reminder["type"] as? String
                                newReminder.deliveryDay = reminder["delivery_day"] as! Int64
                                let timeString = reminder["delivery_time"] as! String
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "HH:mm:ss"
                                newReminder.deliveryTime = dateFormatter.date(from: timeString) as NSDate?
                                let timeZoneNumber = reminder["timezone"] as! String
                                let seconds = Int(timeZoneNumber)!*3600
                                let timeZone = TimeZone(secondsFromGMT: seconds)
                            
                                newReminder.timeZone = timeZone?.identifier
                                if let notifications = reminder["methods"] as? NSArray, notifications.count>0 {
                                    
                                    newReminder.emailNotificationIsActive = false
                                    newReminder.smsNotificationIsActive = false
                                    newReminder.pushNotificationIsActive = false
                                    
                                    for notification in 0..<notifications.count {
                                        switch notifications[notification] as! String {
                                        case "E-mail":
                                            newReminder.emailNotificationIsActive = true
                                        case "SMS":
                                            newReminder.smsNotificationIsActive = true
                                        case "Push":
                                            newReminder.pushNotificationIsActive = true
                                        default:
                                            break
                                        }
                                    }
                                    reminderArray.append(newReminder)
                                } else {
                                    print("Alert with id: \(newReminder.reminderID) has not notification!")
                                }
                            } else {
                                print("Json file is broken!")
                            }
                        }
                        return reminderArray
                    } else {
                        print("Reminder list is empty")
                        return []
                    }
                } else {
                    print("Json file is broken!")
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
