//
//  RequestServise.swift
//  CoreKPI
//
//  Created by Семен on 13.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import Foundation
import Alamofire
import UIKit


enum RequestError: Error {
    case loadFailed
    case jsonFileIsBroken
}

class Request {
    
    let serverIp = "http://192.168.0.118:8888"
    
    var userID: Int!
    var token: String!
    
    init(userID: Int, token: String) {
        self.userID = userID
        self.token = token
    }
    
    init(){}
    
    func getJson(category: String, data: [String : Any]) {
        
        let http = "\(serverIp)\(category)"
        
        let tokenLocal = token ?? ""
        let params: [String : Any]!
        
        if userID == nil {
            params = ["user_id" : "", "token" : tokenLocal, "data" : data]
        } else {
            params = ["user_id" : userID, "token" : tokenLocal, "data" : data]

        }

        request(http, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            if let data = response.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print("Error convert data to Json")
                }
            }
        }
    }
    
}

