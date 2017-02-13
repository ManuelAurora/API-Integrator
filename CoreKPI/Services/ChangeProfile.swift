//
//  ChangeProfile.swift
//  CoreKPI
//
//  Created by Семен on 24.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class ChangeProfile: Request {
    
    func changeProfile(userID: Int, params : [String : String?], success: @escaping (_ photoLink: String?) -> (), failure: @escaping failure) {
        
        let data: [String : Any] = ["user_id" : userID, "properties" : params]
        
        self.getJson(category: "/account/changeProfile", data: data,
                     success: { json in
                        if self.parsingJson(json: json) != nil, let link = self.parsingJson(json: json) {
                            success(link == "nil" ? nil : "http://192.168.0.118:8888/avatars/" + link)
                        } else {
                            failure(self.errorMessage ?? "Wrong data from server")
                        }
        },
                     failure: { (error) in
                        failure(error)
        }
        )
    }
    
    func parsingJson(json: NSDictionary) -> String? {
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let data = json["data"] as? NSDictionary {
                    if let photoLink = data["photo"] as? String {
                        return photoLink
                    } else {
                        return "nil"
                    }
                } else {
                    print("No photo link")
                }
            } else {
                self.errorMessage = json["message"] as? String
            }
        }
        return nil
    }
    
}
