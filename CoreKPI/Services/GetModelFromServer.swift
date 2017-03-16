//
//  GetModelFromServer.swift
//  CoreKPI
//
//  Created by Семен on 23.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class GetModelFromServer: Request {
    
    func getModelFromServer(success: @escaping () -> (), failure: @escaping failure) {
        getJson(category: "/account/contactData", data: [:],
                success: { json in
                    self.createModel(json: json)
                    success()
        },
                failure: { (error) in
                    failure(error)
        })
    }
    
    func createModel(json: NSDictionary) {
        
        var profile: Profile!
        var userName: String!
        var firstName: String!
        var lastName: String!
        var position: String!
        var typeOfAccount: TypeOfAccount!
        var photo: String!
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSDictionary {
                    userName = dataKey["username"] as! String
                    firstName = dataKey["first_name"] as! String
                    lastName = dataKey["last_name"] as! String
                    position = dataKey["position"] as! String
                    photo = dataKey["photo"] as! String
                    let mode = dataKey["mode"] as! Int
                    typeOfAccount = (mode == 0) ? .Manager : .Admin
                    profile = Profile(userId: self.userID, userName: userName, firstName: firstName, lastName: lastName, position: position, photo: photo, phone: nil, nickname: nil, typeOfAccount: typeOfAccount)
                    
                   ModelCoreKPI.modelShared.register(profile: profile, token: token)

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
    }
}
