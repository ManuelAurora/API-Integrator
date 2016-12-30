//
//  RequestServise.swift
//  CoreKPI
//
//  Created by Семен on 13.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import Foundation
import Alamofire


enum RequestError: Error {
    case loadFailed
    case jsonFileIsBroken
}

class Request {
    
    typealias success = (_ json: NSDictionary) -> ()
    typealias failure = (_ error: String) -> ()
    
    let serverIp = "http://dashmob.smichrissoft.com:8888"
    //debug!
    //let serverIp = "http://192.168.0.118:8888"
    
    var userID: Int!
    var token: String!
    
    init(userId: Int, token: String) {
        self.userID = userId
        self.token = token
    }
    
    init(model: ModelCoreKPI) {
        self.token = model.token
        self.userID = model.profile?.userId
    }
    
    init(){}
    
    func getJson(category: String, data: [String : Any], success: @escaping success, failure: @escaping failure) {
        
        let http = "\(serverIp)\(category)"
        
        let tokenLocal = token ?? ""
        var params: [String : Any]!
        
        if userID == nil {
            params = ["user_id" : "", "token" : tokenLocal, "data" : data]
        } else {
            params = ["user_id" : userID, "token" : tokenLocal, "data" : data]
            
        }
        
        request(http, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            if let data = response.data {
            
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                    if let jsonDictionary = json {
                        success(jsonDictionary)
                    } else {
                        failure("Load failed")
                    }
                    
                } catch {
                    failure("Server not found")
                }
            }
        }
    }
    
}

