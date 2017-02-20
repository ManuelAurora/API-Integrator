//
//  GetMemberList.swift
//  CoreKPI
//
//  Created by Семен on 24.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit
import PhoneNumberKit

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
        let photoServer = "http://192.168.0.118:8888/avatars/"
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSArray {

                    var teamArray: [Team] = []
                    
                    var teamListIsFull = false
                    var i = 0
                    while teamListIsFull == false {
                        
                        let profile = Team(context: context)
                        
                        if dataKey.count > 0, let userData = dataKey[i] as? NSDictionary {
                            
                            profile.position = userData["position"] as? String
                            let mode = userData["mode"] as? Int
                            mode == 0 ? (profile.isAdmin = false) : (profile.isAdmin = true)
                            let nickname = userData["nickname"] as? String
                            profile.nickname = nickname == "" ? nil : nickname
                            profile.lastName = userData["last_name"] as? String
                            profile.username = userData["username"] as? String
                            profile.userID = Int64((userData["user_id"] as? Int)!)
                            
                            let phone = userData["phone"] as? String
                            if phone == "" {
                                profile.phoneNumber = nil
                            } else {
                                let phoneNumberKit = PhoneNumberKit()
                                
                                do {
                                    let phoneNumber = try phoneNumberKit.parse("+\(phone!)")
                                    profile.phoneNumber = phoneNumberKit.format(phoneNumber, toType: .international)
                                }
                                catch {
                                    print("\(profile.lastName!)'s phone number incorect")
                                }
                            }
                            
                            if (userData["photo"] as? String) != "" {
                                profile.photoLink = photoServer + (userData["photo"] as? String)!
                            } else {
                                profile.photoLink = nil
                            }
                            profile.firstName = userData["first_name"] as? String
                            teamArray.append(profile)
                            
                            i+=1
                            if dataKey.count == i {
                                teamListIsFull = true
                            }
                        } else {
                            print("Member list is empty")
                            teamArray.removeAll()
                            return teamArray
                        }
                    }
                    return teamArray

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
