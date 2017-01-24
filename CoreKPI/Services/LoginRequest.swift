//
//  LoginRequest.swift
//  CoreKPI
//
//  Created by Семен on 23.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class LoginRequest: Request {
    
    func loginRequest(username: String, password: String, success: @escaping (_ data: (userID: Int, token: String)) -> (), failure: @escaping failure) {
        
        let data: [String : Any] = ["username" : username, "password" : password]
        
        self.getJson(category: "/auth/auth", data: data,
                        success: { json in
                            if let tokenUserID = self.parsingJson(json: json) {
                                success(tokenUserID)
                            } else {
                                failure(self.errorMessage ?? "Wrong data from server")
                            }
        },
                        failure: { (error) in
                            failure(error)
        })
    }
    
    func parsingJson(json: NSDictionary) -> (userID: Int, token: String)? {
        var userId: Int
        var token: String
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSDictionary {
                    userId = dataKey["user_id"] as! Int
                    token = dataKey["token"] as! String
                    return(userID: userId, token: token)
                } else {
                    print("Json data is broken")
                }
            } else {
                errorMessage = json["message"] as? String
                print("Json error message: \(errorMessage)")
            }
        } else {
            print("Json file is broken!")
        }
        return nil
    }
    
}
