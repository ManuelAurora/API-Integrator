//
//  SendInvation.swift
//  CoreKPI
//
//  Created by Семен on 24.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class SendInvation: Request {
    
    func sendInvations(email: String, typeOfAccount: TypeOfAccount, success: @escaping (_ numberOfInvations: Int) -> (), failure: @escaping failure) {
        
        let data: [String : Any] = ["email" : email, "mode" : typeOfAccount == .Admin ? 1 : 0]
        
        self.getJson(category: "/account/invite", data: data,
                        success: { json in
                            if let number = self.parsingJson(json: json) {
                                success(number)
                            } else {
                                failure(self.errorMessage ?? "Wrong data from server")
                            }
        },
                        failure: { (error) in
                            failure(error)
        }
        )
    }
    
    func parsingJson(json: NSDictionary) -> Int? {
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let data = json["data"] as? NSDictionary {
                    let number = data["inv_count"] as? Int
                    return number
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
