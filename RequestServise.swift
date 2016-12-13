//
//  RequestServise.swift
//  CoreKPI
//
//  Created by Семен on 13.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import Foundation
import Alamofire
//import SwiftyJSON


enum RequestError: Error {
    case loadFailed
    case jsonFileIsBroken
}

class Request {
    
    typealias success = (_ json: NSDictionary) -> ()
    typealias failure = (_ error: String) -> ()
    
    let serverIp = "http://192.168.0.118:8888/ping" //!
    //var category = "category" //!
    //var method = "method" //!
    
    let userID = 123
    let token = "blablabla"
    let data: [String] = []
    
    func getJSON(success: @escaping success, failure: @escaping failure) {
        
        let params: [String : Any] = ["user_id" : userID, "token" : token, "data" : data]
        
        request(serverIp, method: .post, parameters: params).responseJSON { response in
            if let data = response.data {
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                if let jsonDictionary  = json {
                    success(jsonDictionary)
                } else {
                    failure("Load Failed")
                }
            }
        }
    }
    
    func getJsonTest(success: @escaping success, failure: @escaping failure) {
        
        let params: [String : Any] = ["user_id" : userID, "token" : token, "data" : data]
        
        request(serverIp, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON{ response in
            if let data = response.data {
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                if let jsonDictionary  = json {
                    success(jsonDictionary)
                } else {
                    failure("Load Failed")
                }
            }
        }
    }
    
}

