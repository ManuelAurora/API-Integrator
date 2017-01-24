//
//  RecoveryPassword.swift
//  CoreKPI
//
//  Created by Семен on 24.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class RecoveryPassword: Request {
    func recoveryPassword(email: String, success: @escaping () -> (), failure: @escaping failure ) {
        let data: [String : Any] = ["email" : email]
        
        self.getJson(category: "/auth/recovery", data: data, //debug!
            success: { json in
                if self.parsingJson(json: json) == true {
                    success()
                } else {
                    failure(self.errorMessage ?? "Wrong data from server")
                }
                
        },
            failure: { (error) in
                failure(error)
        })
    }
    
    func parsingJson(json: NSDictionary) -> Bool {
        if let successKey = json["success"] as? Int {
            if successKey == 0 {
                self.errorMessage = json["message"] as? String
                return false
            } else {
                return true
            }
        } else {
            print("Json file is broken!")
            return false
        }
    }
    
}
