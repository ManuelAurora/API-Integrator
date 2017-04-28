//
//  getInviteList.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 28.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class GetInviteList: Request {
    
    func inviteRequest(email: String, success: @escaping () -> (), failure: @escaping failure) {
        
        let data = [
            "email":   email,
            ]
        
        self.getJson(category: "/auth/getInviteList", data: data,
                     success: { json in
                        guard let success = json["success"] as? Int, success == 1 else {
                            if let errorMessage = json["message"] as? String
                            {
                                failure(errorMessage)
                            }
                            return
                        }
        },
                     failure: { (error) in
                        failure(error)
        })
    }
    
    func parsingJson(username: String,
                     firstname: String,
                     lastname: String,
                     position: String,
                     photo: String?,
                     email: String,
                     password: String,
                     json: NSDictionary) {
        
        var userId: Int
        var token: String
        var typeOfAccount: TypeOfAccount!
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSDictionary {
                    userId = dataKey["user_id"] as! Int
                    token = dataKey["token"] as! String
                    let mode = dataKey["mode"] as! Int
                    typeOfAccount = (mode == 0) ? .Manager : .Admin
                    let profile = Profile(userId: userId, userName: username, firstName: firstname, lastName: lastname, position: position, photo: photo, phone: nil, nickname: nil, typeOfAccount: typeOfAccount)
                    
                    ModelCoreKPI.modelShared.signedInUpWith(token: token, profile: profile)
                    UserStateMachine.shared.logInWith(email: email, password: password)
                    
                } else {
                    print("Json data is broken")
                }
            } else {
                self.errorMessage = json["message"] as? String
            }
        } else {
            print("Json file is broken!")
        }
    }
}
