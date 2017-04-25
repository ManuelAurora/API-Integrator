//
//  LoginRequest.swift
//  CoreKPI
//
//  Created by Семен on 23.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class LoginRequest: Request {
    
    func loginRequest(username: String, password: String, success: @escaping (_ data: (userID: Int, token: String, typeOfAccount: TypeOfAccount)) -> (), failure: @escaping failure) {
        UserStateMachine.shared.setTryingToLogin(true)
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
    
    func checkToken(success: @escaping (_ data: (userID: Int, token: String, typeOfAccount: TypeOfAccount)) -> (), failure: @escaping failure) {
        UserStateMachine.shared.setTryingToLogin(true)
        let data: [String : Any] = [:]
        
        self.getJson(category: "/auth/auth", data: data, success: { json in
            if let tokenUserID = self.parsingJson(json: json) {
                success(tokenUserID)
            } else {
                failure(self.errorMessage ?? "Wrong data from server")
            }
        }, failure: { error in
            failure(error)
        }
        )
    }
    
    func parsingJson(json: NSDictionary) -> (userID: Int, token: String, typeOfAccount: TypeOfAccount)? {
        var userId: Int
        var token: String
        var typeOfAccount: TypeOfAccount!
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? jsonDict {
                    userId = dataKey["user_id"] as! Int
                    token = dataKey["token"] as! String
                    let mode = dataKey["mode"] as! Int
                    typeOfAccount = (mode == 0) ? .Manager : .Admin
                    return(userID: userId, token: token, typeOfAccount: typeOfAccount)
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
