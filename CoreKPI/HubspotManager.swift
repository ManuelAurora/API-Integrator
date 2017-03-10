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
    case owners   = "/owners/v2/owners?"
    case dealPipelines = "/deals/v1/pipelines?"
    
}

class HubSpotManager
{
    static let sharedInstance = HubSpotManager()
    
    var dealsArray: [HSDeal] = [] {
        didSet {
            updatePipelinesAndDeals()
        }
    }
    
    var contactsArray: [HSContact] = []
    var ownersArray: [HSOwner] = []
    var pipelinesArray: [HSPipeline] = [] {
        didSet {
            updatePipelinesAndDeals()
        }
    }
    
    var delegate: ExternalKPIViewController?
    var webView: WebViewController!
    var merged: Bool = false
    
    private let apiURL = "https://api.hubapi.com"
    private let authorizeURL = "https://app.hubspot.com"
    
    var currentDate: Date {
        return Date()
    }
    
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
        .properties: "&properties=amount&properties=closedate&properties=createdate&properties=dealstage&properties=hubspot_owner_id"
    ]
    
    lazy var getContactsParameters: [HSRequestParameterKeys: String] = [
        .properties: "&property=createdate&property=notes_last_contacted&property=hubspot_owner_assigneddate&property=hubspot_owner_id"
    ]
    
    private func makeUrlPathForAuthentication() -> String {
        
        return authorizeURL + HSAPIMethods.oauth.rawValue + oauthParameters.stringFromHttpParameters()
    }
    
    private func makeUrlPathGetToken() -> String {
       
        return ""
    }
    
    //This function filles deals array in Pipeline.stage.deals
    private func updatePipelinesAndDeals() {
        
        if pipelinesArray.count > 0 && dealsArray.count > 0 && merged == false {
            appendDealsToPipelineStages()
            print("DEBUG: Merged")           
        }
    }
    
    func connect() {
        
        let url = URL(string: makeUrlPathForAuthentication())
        
        webView.handle(url!)
        
        handle(request: .owners)
        handle(request: .deals)
        handle(request: .contacts)
        handle(request: .dealPipelines)
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
            let urlPath = makeUrlPathFor(request: request, parameters: [.hapiKey: "demo"]) + getDealsParameters[.properties]!
            requestURL = URL(string: urlPath)
            
        case .contacts:
            let urlPath = makeUrlPathFor(request: .contacts, parameters: [.hapiKey: "demo"]) + getContactsParameters[.properties]!
            requestURL = URL(string: urlPath)
            
        case .dealPipelines:
            let urlPath = makeUrlPathFor(request: .dealPipelines, parameters: [.hapiKey: "demo"])
            requestURL = URL(string: urlPath)
            
        case .owners:
            let urlPath = makeUrlPathFor(request: .owners, parameters: [.hapiKey: "demo"])
            requestURL = URL(string: urlPath)
            
        default: break
        }
        
        guard requestURL != nil else { return }
        
        Alamofire.request(requestURL!, headers: [:])
            .responseJSON(completionHandler:
                { response in
                    
                    var error = false
                    
                    if let responseValue = response.result.value as? [String: String],
                        let status = responseValue["status"],
                        status != "error"  { error = true; print("DEBUG: Error response from HubSpot")
                    }
                    
                    guard error == false else { return }
                    
                    if let json = response.result.value as? [String: Any]
                    {
                        switch request
                        {
                        case .deals:    self.dealsArray = self.getDealsFrom(json: json)
                        case .contacts: self.contactsArray = self.getContactsFrom(json: json)
                        default: break
                        }
                    }
                    else if let json = response.result.value as? [[String: Any]]
                    {
                        switch request
                        {
                        case .owners:        self.ownersArray = self.getOwnersFrom(json: json)
                        case .dealPipelines: self.pipelinesArray = self.getPipelinesFrom(json: json)
                        default: break
                        }
                    }
            })
    }
    
    /*
    //////////////////////////////////////////////
      MARK: Get items from HubSpot callback json
    //////////////////////////////////////////////
    */
    private func getContactsFrom(json file: [String: Any]) -> [HSContact] {
        
        let allContacts = file["contacts"] as! [[String: Any]]
        
        let resultArray: [HSContact] = allContacts.map { contactJson in
            HSContact(json: contactJson)
        }
        
        return resultArray
    }
    
    private func getDealsFrom(json file: [String: Any]) -> [HSDeal] {
        
        guard let allDeals = file["deals"] as? [[String: Any]] else { return [HSDeal]() }
        
        let resultArray: [HSDeal] = allDeals.map { dealJson in
            HSDeal(json: dealJson)
        }
        
        return resultArray
    }
    
    private func getPipelinesFrom(json file: [[String: Any]]) -> [HSPipeline] {
        
        return file.map { pipelineJson -> HSPipeline in
            
            var pipeline = HSPipeline(json: pipelineJson)
            
            if let stages = pipelineJson["stages"] as? [[String: Any]]
            {
                pipeline.stages = stages.map { HSStage(json: $0) }
            }
            
            return pipeline
        }
    }
    
    private func getOwnersFrom(json file: [[String: Any]]) -> [HSOwner] {
        
        return file.map { HSOwner(json: $0) }
    }
    
    private func dateIsInCurrentPeriod(_ date: Date) -> Bool {
        
        let comparisonResult = Calendar.current.compare(currentDate, to: date, toGranularity: .month)
        
        return comparisonResult == .orderedSame ? true : false
    }
    
    private func appendDealsToPipelineStages() {
        
        merged = true
        
        pipelinesArray = pipelinesArray.map { pipeline  -> HSPipeline in
            
            var pipelineModified = pipeline
            
            pipelineModified.stages = pipeline.stages.map { stage -> HSStage in
                
                var modifiedStage = stage
                
                for deal in dealsArray
                {
                    if let dealStage = deal.dealStage, let stageId = stage.stageId
                    {
                        if dealStage == stageId {
                            modifiedStage.deals.append(deal)
                        }
                    }
                }
                return modifiedStage
            }
            return pipelineModified
        }
    }
    
    //MARK: Functions for getting key parameters
    
    //Array in wich deals are closed
    func showClosedDeals() -> [HSDeal] {
        
        return dealsArray.filter { dateIsInCurrentPeriod($0.closeDate) }
    }
    
    //Array in wich deals are closed and have Amount value
    func showClosedAndWonDeals() -> [HSDeal] {
        
        return dealsArray.filter { $0.amount != nil && dateIsInCurrentPeriod($0.closeDate) }
    }
    
    //Array of deals that was created in given period
    func showNewDealsCreated() -> [HSDeal] {
        
        return dealsArray.filter { dateIsInCurrentPeriod($0.createDate) }
    }
    
    //Array filled with all contacts, created for period
    func showContactsCreated() -> [HSContact] {
        
        return contactsArray.filter { dateIsInCurrentPeriod($0.createDate) }
    }
    
    //Array filled with assign property filled in given period
    func showContactsAssigned() -> [HSContact] {
        
        return contactsArray.filter { dateIsInCurrentPeriod($0.assignDate) }
    }
    
    //Array filled with contacts wich was contacted in given period
    func showContactsWorked() -> [HSContact] {
        
        return contactsArray.filter { dateIsInCurrentPeriod($0.lastContactDate) }
    }
    
    //Array filled with sales leaders
    func showSalesLeaderboard() -> [HSOwner]  {
        
        let tempArray = ownersArray.map { owner -> HSOwner in
            
            var ownerTemp = owner
            
            for deal in dealsArray
            {
                if let dealsOwnerId = deal.ownerId, let ownerId = owner.ownerId
                {
                    if dealsOwnerId == ownerId
                    {
                        ownerTemp.deals.append(deal)
                    }
                }
            }
            return ownerTemp
        }
        
        let salesLeaderboard = tempArray.filter { $0.sum() > 0 }
        
        return salesLeaderboard.sorted { $0.sum() > $1.sum() }
    }
}

