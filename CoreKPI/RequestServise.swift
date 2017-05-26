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

class Request
{
    var errorMessage: String?
    
    private let notificationCenter = NotificationCenter.default
    
    private lazy var sessionManager: SessionManager = {
        let config = URLSessionConfiguration.default
        
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 15
        
        return Alamofire.SessionManager(configuration: config)
    }()
    
    //let serverIp = "http://dashmob.smichrissoft.com:8888"
    //debug!
    let serverIp = "https://corekpi.gtwenty.com"
    static let avatarsLink = "https://corekpi.gtwenty.com/uploads/avatars/"
    
    var userID: Int!
    var token: String!
    
    init(userId: Int, token: String? = nil) {
        self.userID = userId
        self.token = token
    }
    
    init(model: ModelCoreKPI) {
        self.token = model.token
        self.userID = model.profile?.userId
    }
    
    init(){
        let model = ModelCoreKPI.modelShared
        
        self.token = model.token
        self.userID = model.profile?.userId
    }
    
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
        
        sessionManager.request(http, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            
            if let statusCode = response.response?.statusCode
            {
                switch statusCode
                {
                case 200..<300, 400..<500:
                    if let data = response.data,
                        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
                        let jsonDictionary = json
                    {
                        success(jsonDictionary)
                    }
                    else {  failure("Load failed") }
                    
                case 500..<600:
                    print(response.result.value ?? "Server error")
                    
                    if let res = response.result.value as? [String: Any],
                        let message = res["message"] as? String
                    {
                        if message.contains("Incorrect string value")
                        {
                            var reason = ""
                            
                            if message.contains("desc")
                            {
                                reason = "Description"
                            }
                            else if message.contains("name")
                            {
                                reason = "Name"
                            }
                            else
                            {
                                failure("Unknown error occured")
                            }
                            
                            failure("\(reason) of your KPI contains " +
                                "inacceptable symbols")
                        }
                    }
                    else { failure("Server error") }
                    
                default:
                    print("Request error")
                }
            } else {
                let error = response.result.error
                
                if let error = error {
                    let requestError = error.localizedDescription
                    
                    switch (error as NSError).code
                    {
                    case NSURLErrorNotConnectedToInternet:
                        self.notificationCenter.post(name: .internetConnectionLost,
                                                     object: nil)
                        failure(requestError)
                        
                    default:
                        self.notificationCenter.post(name: .internetConnectionLost,
                                                     object: nil)
                        failure(error.localizedDescription)
                    }
                }
                return
            }
        }
    }
    
}
