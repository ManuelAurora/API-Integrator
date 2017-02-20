//
//  RequestServise.swift
//  CoreKPI
//
//  Created by Семен on 13.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import Foundation
import Alamofire

protocol RequestDelegate {
    func showAlertWithError(title: String, message: String)
}

class Request {
    
    var errorMessage: String?
    
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
    
    typealias success = (_ json: NSDictionary) -> ()
    typealias failure = (_ error: String) -> ()
    
    //MARK: - Send request
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
                    guard response.result.isSuccess else {
                        let error = response.result.error
            
                        if let error = error {
                            let requestError = error.localizedDescription
                            
                            switch (error as NSError).code {
                            case NSURLErrorNotConnectedToInternet:
                                failure(requestError)
                            default:
                                print(requestError)
                            }
                        }
                        return
                    }
                }
            }
        }
    }
    
}
