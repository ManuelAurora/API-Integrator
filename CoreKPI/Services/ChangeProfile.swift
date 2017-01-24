//
//  ChangeProfile.swift
//  CoreKPI
//
//  Created by Семен on 24.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class ChangeProfile: Request {
    
    func changeProfile(params : [String : String?], success: @escaping () -> (), failure: @escaping failure) {
        
        let data: [String : Any] = ["user_id" : userID, "data" : params]
        
        self.getJson(category: "/account/changeProfile", data: data,
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
                if (json["data"] as? NSDictionary) != nil {
                    return true
                } else {
                    self.errorMessage = json["message"] as? String
                }
            } else {
                print("Json file is broken!")
            }
        }
        return false
    }
    
}
