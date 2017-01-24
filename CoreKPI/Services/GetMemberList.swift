//
//  GetMemberList.swift
//  CoreKPI
//
//  Created by Семен on 24.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

class GetMemberList: Request {
    
    func getMemberList(success: @escaping (_ teamArray: [Team]) -> (), failure: @escaping failure) {
        
        let data: [String : Any] = [ : ]
        
        self.getJson(category: "/team/getTeamList", data: data,
                        success: { json in
                            if let team = self.parsingJson(json: json) {
                                success(team)
                            } else {
                                failure(self.errorMessage ?? "Wrong data from server")
                            }
        },
                        failure: { (error) in
                            failure(error)
                            
        }
        )
    }
    
    func parsingJson(json: NSDictionary) -> [Team]? {
        
        let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSArray {
                    
                    //self.model.team.removeAll()
                    var teamArray: [Team] = []
                    
                    var teamListIsFull = false
                    var i = 0
                    while teamListIsFull == false {
                        
                        let profile = Team(context: context)
                        
                        if let userData = dataKey[i] as? NSDictionary {
                            profile.position = userData["position"] as? String
                            let mode = userData["mode"] as? Int
                            mode == 0 ? (profile.isAdmin = false) : (profile.isAdmin = true)
                            profile.nickname = userData["nickname"] as? String
                            profile.lastName = userData["last_name"] as? String
                            profile.username = userData["username"] as? String
                            profile.userID = Int64((userData["user_id"] as? Int)!)
                            if (userData["photo"] as? String) != "" {
                                profile.photoLink = userData["photo"] as? String
                            }
                            
                            profile.firstName = userData["first_name"] as? String
                            
//                            do {
//                                try context.save()
//                            } catch {
//                                print(error)
//                                return
//                            }
                            
                            teamArray.append(profile)
                            
                            i+=1
                            if dataKey.count == i {
                                teamListIsFull = true
                            }
                        }
                    }
                    return teamArray
                    //let profileDidChangeNotification = Notification.Name(rawValue:"profileDidChange")
                    //let nc = NotificationCenter.default
                    //nc.post(name:profileDidChangeNotification,
                            //object: nil,
                           // userInfo:["teamList": model.team])
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
