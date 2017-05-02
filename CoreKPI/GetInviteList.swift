//
//  getInviteList.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 28.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

struct InviteTeam
{
    let id: Int
    let name: String
    let lastName: String
    
    func teamName() -> String {
        
        return name + " " + lastName
    }
}

class GetInviteList: Request {
    
    func inviteRequest(email: String, success: @escaping ([InviteTeam]) -> (), failure: @escaping failure) {
        
        let data = [
            "email":   email,
            ]
        
        self.getJson(category: "/auth/getInviteList", data: data,
                     success: { json in
                        guard let suc = json["success"] as? Int, suc == 1 else {
                            if let errorMessage = json["message"] as? String
                            {
                                failure(errorMessage)
                            }
                            return
                        }
                        success(self.parsingJson(json: json))
        },
                     failure: { (error) in
                        failure(error)
        })
    }
    
    func parsingJson(json: NSDictionary) -> [InviteTeam] {
        
        var result = [InviteTeam]()
        
        if let successKey = json["success"] as? Int,
             successKey == 1,
                 let data = json["data"] as? [jsonDict]
        {
            data.forEach { team in
                let id = team["inviter_team_id"] as! Int
                let name = team["first_name"] as! String
                let lastName = team["last_name"] as! String
                
                let inviteTeam = InviteTeam(id: id,
                                      name: name,
                                      lastName: lastName)
                result.append(inviteTeam)
            }
        }
        return result
    }
}

