//
//  ExternalRequestService.swift
//  CoreKPI
//
//  Created by Семен on 07.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import Alamofire
import OAuthSwift

class ExternalRequest {
    
    var errorMessage: String?
    
    var oauthToken: String
    let oauthRefreshToken: String
    var oauthTokenExpiresAt: Date
    
    init(oauthToken: String, oauthRefreshToken: String, oauthTokenExpiresAt: Date) {
        self.oauthToken = oauthToken
        self.oauthRefreshToken = oauthRefreshToken
        self.oauthTokenExpiresAt = oauthTokenExpiresAt
    }
    
    init() {
        self.oauthToken = ""
        self.oauthRefreshToken = ""
        self.oauthTokenExpiresAt = Date()
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
        let clientSecret = ""
        var accessTokenURL = ""
        var grantType = ""
        var headers: [String:String] = [:]
        
        switch servise {
        case .GoogleAnalytics:
            clientID = "988266735713-9ruvi1tjo1bk6gckjuiqnncuq6otn0ko.apps.googleusercontent.com"
            accessTokenURL = "https://www.googleapis.com/oauth2/v4/token"
            grantType = "refresh_token"
            headers = ["Content-Type" : "application/x-www-form-urlencoded"]
        case .PayPal:
            break
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
        }
    }
    
    //Autorisation OAuth 1.0/2.0
    func oAuthAutorisation(servise: IntegratedServices, viewController: UIViewController, success: @escaping (_ credential: OAuthSwiftCredential) -> (), failure: @escaping failure) {
        
        switch servise {
        case .GoogleAnalytics:
            doOAuthGoogle(viewController: viewController, success: { credential in
                success(credential)
            }, failure: { error in
                failure(error)
            })
                  
        case .SalesForce:
            doOAuthSalesforce(viewController: viewController, success: { credential in
                success(credential)
            }, failure: {error in
                failure(error)
            })
        case .PayPal:
            doOAuthPayPal(viewController: viewController, success: { credential in
                success(credential)
            }, failure: {error in
                failure(error)
            })
        default:
            break
        }
    }
    
    private func doOAuthGoogle(viewController: UIViewController, success: @escaping (_ credential: OAuthSwiftCredential) -> (), failure: @escaping failure) {
        let oauthswift = OAuth2Swift(
            consumerKey:    "988266735713-9ruvi1tjo1bk6gckjuiqnncuq6otn0ko.apps.googleusercontent.com",
            consumerSecret: "",
            authorizeUrl:   "https://accounts.google.com/o/oauth2/v2/auth",
            accessTokenUrl: "https://accounts.google.com/o/oauth2/token",
            responseType:   "code"
        )
        // magic redirect - "urn:ietf:wg:oauth:2.0:oob"
        oauthswift.allowMissingStateCheck = true
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: viewController, oauthSwift: oauthswift)
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "CoreKPI.CoreKPI:/oauth2Callback")!, scope: "https://www.googleapis.com/auth/analytics.readonly", state: "",
            success: { credential, response, parameters in
                success(credential)
        },
            failure: { error in
                failure("\(error.localizedDescription)")
        })
    }
    
    private func doOAuthPayPal(viewController: UIViewController, success: @escaping (_ credential: OAuthSwiftCredential) -> (), failure: @escaping failure) {
        let oauthswift = OAuth2Swift(
            consumerKey:    "AdA0F4asoYIoJoGK1Mat3i0apr1bdYeeRiZ6ktSgPrNmAMIQBO_TZtn_U80H7KwPdmd72CJhUTY5LYJH",
            consumerSecret: "EBA8OIWD2WLj7Z0hytEiKl3F3PbdKGrYe-kqGOl-YY25R3M05H6RCfoPhXauYy7_nQUjsQ_Pss7LNBgI",
            authorizeUrl:   "https://www.sandbox.paypal.com/signin/authorize",
            accessTokenUrl: "https://api.sandbox.paypal.com/v1/identity/openidconnect/tokenservice",
            responseType:   "code"
        )
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: viewController, oauthSwift: oauthswift)
        let state = generateState(withLength: 20)
        
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "https://appauth.demo-app.io:/oauth2redirect")!, scope: "profile+email+address+phone", state: state,
            success: { credential, response, parameters in
                success(credential)
        },
            failure: { error in
                failure(error.description)
        })
    }
    
    private func doOAuthSalesforce(viewController: UIViewController, success: @escaping (_ credential: OAuthSwiftCredential) -> (), failure: @escaping failure) {
        let oauthswift = OAuth2Swift(
            consumerKey:    "3MVG9HxRZv05HarSOV2Bh.pnwumGqpwVny5raeBxpjMwIQCVzeb7HmzJvGTOxEm6N3S2Q7LFo48KvA.0DrKYt",
            consumerSecret: "2273564242408453432",
            authorizeUrl:   "https://login.salesforce.com/services/oauth2/authorize",
            accessTokenUrl: "https://login.salesforce.com/services/oauth2/token",
            responseType:   "code"
        )
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: viewController, oauthSwift: oauthswift)
        let state = generateState(withLength: 20)
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "https://appauth.demo-app.io:/oauth2redirect")!, scope: "full", state: state,
            success: { credential, response, parameters in
                success(credential)
        },
            failure: { error in
                failure(error.description)
        })
    }

}
