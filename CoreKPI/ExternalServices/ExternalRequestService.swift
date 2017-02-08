//
//  ExternalRequestService.swift
//  CoreKPI
//
//  Created by Семен on 07.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import Alamofire
//import OAuthSwift

class ExternalRequest {
    
    var errorMessage: String?
    
    let oauthToken: String
    let oauthRefreshToken: String
    let oauthTokenExpiresAt: Date
    
    init(oauthToken: String, oauthRefreshToken: String, oauthTokenExpiresAt: Date) {
        self.oauthToken = oauthToken
        self.oauthRefreshToken = oauthRefreshToken
        self.oauthTokenExpiresAt = oauthTokenExpiresAt
    }
    
    typealias success = (_ json: NSDictionary) -> ()
    typealias failure = (_ error: String) -> ()
    
    //MARK: - Send request
    func getJson(url: String, header: [String : String]?, params: [String: Any]?, method: HTTPMethod, success: @escaping success, failure: @escaping failure) {
        
        request(url, method: method, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
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
                        if let error = error, (error as NSError).code != NSURLErrorCancelled {
                            let requestError = error.localizedDescription
                            failure(requestError)
                        }
                        return
                    }
                }
            }
        }
    }
    
    func updateAccessToken(servise: IntegratedServices, success: @escaping (_ accessToken: String) -> (), failure: @escaping failure) {
        var clientID = ""
        var clientSecret = ""
        var accessTokenURL = ""
        var grantType = ""
        var headers: [String:String] = [:]
        
        switch servise {
        case .GoogleAnalytics:
            clientID = "988266735713-9ruvi1tjo1bk6gckjuiqnncuq6otn0ko.apps.googleusercontent.com"
            accessTokenURL = "https://www.googleapis.com/oauth2/v4/token"
            grantType = "refresh_token"
            headers = ["Content-Type" : "application/x-www-form-urlencoded"]
        default:
            break
        }
        
        let params = ["refresh_token" : oauthRefreshToken, "client_id" : clientID, "client_secret" : clientSecret, "grant_type" : grantType]
        
        request(accessTokenURL, method: .post, parameters: params, headers: headers).responseJSON { response in
            if let data = response.data {
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                    if let jsonDictionary = json {
                        if let token = jsonDictionary["access_token"] as? String {
                            success(token)
                        } else {
                            failure("Error refreshing!")
                        }
                    } else {
                        failure("")
                    }
                    
                } catch {
                    guard response.result.isSuccess else {
                        let error = response.result.error
                        if let error = error, (error as NSError).code != NSURLErrorCancelled {
                            let requestError = error.localizedDescription
                            failure(requestError)
                        }
                        return
                    }
                }
            }
        }    }
    
}
