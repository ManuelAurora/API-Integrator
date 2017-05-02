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
                        self.parsingJson(json: json)
        },
                     failure: { (error) in
                        failure(error)
        })
    }
    
    func parsingJson(json: NSDictionary) {
        
        var userId: Int
        var token: String
        var typeOfAccount: TypeOfAccount!
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSDictionary {
                    print("Json file is broken!")
                }
            }
        }
    }
}

