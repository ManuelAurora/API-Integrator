//
//  GetNumberOfInvations.swift
//  CoreKPI
//
//  Created by Семен on 24.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class GetNumberOfInvations: Request {
    
    func getNumberOfInvations(success: @escaping (_ numberOfInvations: Int) -> (), failure: @escaping failure) {
        
        let data: [String : Any] = [:]
        
        self.getJson(category: "/account/getInviteLimit", data: data,  //debug!
            success: { json in
                if let numberOfInvations = self.parsingJson(json: json) {
                    success(numberOfInvations)
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
                    if let numberOfInvations = data["limit"] as? Int {
                        return numberOfInvations
                    }
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
