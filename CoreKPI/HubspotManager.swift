//
//  HubspotManager.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 07.03.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import OAuthSwift

enum HSRequestParameterKeys: String
{
    case scope = "scope"
    case redirectURI = "redirect_uri"
    case grantType = "grant_type"
    case clientID = "client_id"
    case clientSecret = "client_secret"
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case expiresIn = "expires_in"
    case hapiKey = "hapikey"
    case properties = "properties"
}

enum HSAPIMethods: String
{
    case deals    = "/deals/v1/deal/paged?"
    case contacts = "/contacts/v1/lists/all/contacts/all?"
    case oauth    = "/oauth/authorize?"
    case getToken = "/oauth/v1/token?"
}

class HubSpotManager
{
    static let sharedInstance = HubSpotManager()
    
    var dealsArray: [HSDeal] = []
    var contactsArray: [HSContact] = []
    
    var delegate: ExternalKPIViewController?
    var webView: WebViewController!
    
    private let apiURL = "https://api.hubapi.com"
    private let authorizeURL = "https://app.hubspot.com"
    
    lazy var oauthParameters: [HSRequestParameterKeys: String] = [
        .clientID: "93a8ccfd-db25-40b2-b793-969f5b4d3b21",
        .redirectURI: "CoreKPI://callback" ,
        .scope: "contacts" //scope=x%20x where x is a scope
    ]
    
    lazy var getTokenParameters: [HSRequestParameterKeys: String] = [
        .grantType: "authorization_code",
        .clientID: "93a8ccfd-db25-40b2-b793-969f5b4d3b21",
        .clientSecret: "e9500393-5d36-4db3-a228-a449bc9e62a3"
    ]
    
    lazy var getDealsParameters: [HSRequestParameterKeys: String] = [
        .properties: "properties=amount&properties=closedate&properties=createdate"
    ]
    
    lazy var getContactsParameters: [HSRequestParameterKeys: String] = [
        .properties: "property=createdate&property=notes_last_contacted&property=hubspot_owner_assigneddate&property=hubspot_owner_id"
    ]
    
    private func makeUrlPathForAuthentication() -> String {
        
        return authorizeURL + HSAPIMethods.oauth.rawValue + oauthParameters.stringFromHttpParameters()
    }
    
    private func makeUrlPathGetToken() -> String {
       
        return ""
    }
    
    func connect() {
        
        let url = URL(string: makeUrlPathForAuthentication())
        
        webView.handle(url!)
        
        handle(request: .deals)
        handle(request: .contacts)
    }
    
    func getDataFromHubSpot(_ array: [HSAPIMethods]) {
        
        for request in array
        {
            handle(request: request)
        }
    }
    
    private func makeUrlPathFor(request: HSAPIMethods, parameters: [HSRequestParameterKeys: String]) -> String {
        
        return apiURL + request.rawValue + parameters.stringFromHttpParameters()
    }
    
    private func handle(request: HSAPIMethods) {
        
        var requestURL: URL?
        
        switch request
        {
        case .deals:
            let urlPath = makeUrlPathFor(request: request, parameters: [:]) + getDealsParameters[.properties]!
            requestURL = URL(string: urlPath)!
            
        case .contacts:
            let urlPath = makeUrlPathFor(request: .contacts, parameters: [:]) + getContactsParameters[.properties]!
            requestURL = URL(string: urlPath)!
            
        default: break
        }
        
        guard requestURL != nil else { return }
        
        Alamofire.request(requestURL!, headers: ["Authorization": "Bearer CLvwkJqrKxICAQEYs-gDILqTDSjOvwIyGQBC-5ITmNa_bD7ISMgaMiGr-MOyY-XWXEI"])
            .responseJSON(completionHandler:
                { response in
                    if let JSON = response.result.value as? [String: Any]
                    {
                        switch request
                        {
                        case .deals: self.dealsArray = self.getDealsFrom(json: JSON)
                        case .contacts: self.contactsArray = self.getContactsFrom(json: JSON)
                        default: break
                        }
                    }
            })
    }
    
    private func getContactsFrom(json file: [String: Any]) -> [HSContact] {
        
        let allContacts = file["contacts"] as! [[String: Any]]
        
        let resultArray: [HSContact] = allContacts.map { contactJson in
            HSContact(json: contactJson)
        }
        
        return resultArray
    }
    
    private func getDealsFrom(json file: [String: Any]) -> [HSDeal] {
        
        let allDeals = file["deals"] as! [[String: Any]]
        
        let resultArray: [HSDeal] = allDeals.map { dealJson in
            HSDeal(json: dealJson)
        }
        
        return resultArray
    }
    
    //Array in wich deals are closed and have Amount value
    func showDealsRevenueArray() -> [HSDeal]{
        
        return dealsArray.filter { $0.amount != nil }
    }
    
    
}
