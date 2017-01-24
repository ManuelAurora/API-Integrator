//
//  RegistrationRequest.swift
//  CoreKPI
//
//  Created by Семен on 24.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class RegistrationRequest: Request {
    
    func registrationRequest(email: String, password: String, firstname: String, lastname: String, position: String, photo: String?, success: @escaping (_ model: ModelCoreKPI) -> (), failure: @escaping failure) {
        
        var data: [String : Any]!
        
        if photo == nil {
            data = ["username" : email, "password" : password, "first_name" : firstname, "last_name" : lastname, "position" : position, "photo" : ""]
        } else {
            data = ["username" : email, "password" : password, "first_name" : firstname, "last_name" : lastname, "position" : position, "photo" : photo!]
        }
        
        self.getJson(category: "/auth/createAccount", data: data,
                        success: { json in
                            if let model = self.parsingJson(username: email, firstname: firstname, lastname: lastname, position: position, photo: photo, json: json)  {
                                success(model)
                            } else {
                                failure(self.errorMessage ?? "Wrong data from server")
                            }
        },
                        failure: { (error) in
                            failure(error)
        }
        )
    }
    
    func parsingJson(username: String, firstname: String, lastname: String, position: String, photo: String?, json: NSDictionary) -> ModelCoreKPI? {
        
        var userId: Int
        var token: String
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSDictionary {
                    userId = dataKey["user_id"] as! Int
                    token = dataKey["token"] as! String
                    let profile = Profile(userId: userId, userName: username, firstName: firstname, lastName: lastname, position: position, photo: photo, phone: nil, nickname: nil, typeOfAccount: .Admin)
                    let model = ModelCoreKPI(token: token, profile: profile)
                    return model
                    
                } else {
                    print("Json data is broken")
                    return nil
                }
            } else {
                self.errorMessage = json["message"] as? String
                return nil
            }
        } else {
            print("Json file is broken!")
            return nil
        }
    }
    
}
