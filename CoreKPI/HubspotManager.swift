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
import CoreData

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
    case pages    = "/content/api/v2/pages?"
    case deals    = "/deals/v1/deal/recent/modified?"
    case contacts = "/contacts/v1/lists/recently_updated/contacts/recent?"
    case oauth    = "/oauth/authorize?"
    case getToken = "/oauth/v1/token?"
    case owners   = "/owners/v2/owners?"
    case dealPipelines = "/deals/v1/pipelines?"
    case companies  = "/companies/v2/companies/paged?"
}

class HubSpotManager
{
    static let sharedInstance = HubSpotManager()
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var dealsArray: [HSDeal] = [] {
        didSet {
            updatePipelinesAndDeals()
        }
    }
    
    var pagesArray: [HSPage] = []
    var contactsArray: [HSContact] = []    
    var ownersArray: [HSOwner] = []
    var companiesArray: [HSCompany] = []
    var pipelinesArray: [HSPipeline] = [] {
        didSet {
            updatePipelinesAndDeals()
        }
    }
    
    var delegate: ExternalKPIViewController?
    var webView: WebViewController!
    var merged: Bool = false
    
    private var requestCounter: Int = 0 {
        didSet {
            if requestCounter == 6 {
                NotificationCenter.default.post(
                name: .hubspotManagerRecievedData,
                object: nil)
                
                requestCounter = 0
            }
        }
    }
    
    private let apiURL = "https://api.hubapi.com"
    private let authorizeURL = "https://app.hubspot.com"
    
    var currentDate: Date {
        return Date(timeIntervalSince1970: 1489096636) //FIXME: DEBUGGING
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
        .properties: "&properties=amount&properties=closedate&properties=createdate&properties=dealstage&properties=hubspot_owner_id&count=100"
    ]
    
    lazy var getContactsParameters: [HSRequestParameterKeys: String] = [
        .properties: "&count=250&property=createdate&property=notes_last_contacted&property=hubspot_owner_assigneddate&property=hubspot_owner_id&property=hs_analytics_source"
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
            appendDealsToCompanies()
            print("DEBUG: Merged")
        }
        
        merged = false
    }
    
    func createNewEntity(type: HubSpotCRMKPIs) {
        
        let extKPI = ExternalKPI()
        var hubspotKPI: HubspotKPI!
        let fetchHubspotKPI = NSFetchRequest<HubspotKPI>(entityName: "HubspotKPI")
        
        do {
            let result = try? managedContext.fetch(fetchHubspotKPI)
            hubspotKPI = (result == nil) || result!.isEmpty ? HubspotKPI() : result![0]
        }        
        
        extKPI.serviceName = IntegratedServices.HubSpotCRM.rawValue
        extKPI.kpiName = type.rawValue
        extKPI.hubspotKPI = hubspotKPI        
        
        do {
            try managedContext.save()
            
            NotificationCenter.default.post(Notification(name: .newExternalKPIadded))
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func connect() {
        
        //let url = URL(string: makeUrlPathForAuthentication())
        // webView.handle(url!)
        
        getDataFromHubSpot([.pages,
                            .companies,
                            .owners,
                            .deals,
                            .contacts,
                            .dealPipelines])
    }
    
    func getDataForReport(kpi: HubSpotCRMKPIs) -> resultArray {
        
        var result: resultArray = []
        
        switch kpi
        {
        case .DealsRevenue:
            let deals   = showClosedDeals()
            let revenue = showClosedAndWonDeals()
            
            deals.forEach { deal in
                let wonDeal = revenue.filter { $0.dealId == deal.dealId }
                var resultTuple = (leftValue: "",
                                   centralValue: "0",
                                   rightValue: "0")
                
                if let date = deal.createDate
                {
                    resultTuple.leftValue = "\(date)"
                }
                
                if wonDeal.count > 0
                {
                    let wonAmount  = wonDeal[0].amount ?? 0
                    resultTuple.centralValue = "\(wonAmount)"
                }
                
                let dealAmount = deal.amount ?? 0
                resultTuple.rightValue   = "\(dealAmount)"
                
                result.append(resultTuple)
            }
            
        case .DealsClosedWonAndLost:
            let closedDeals   = showClosedDeals()
            
            closedDeals.forEach { deal in
                var resultTuple = (leftValue: "\(deal.closeDate!)",
                                   centralValue: "Lost",
                                   rightValue: "")
                
                if let amount = deal.amount, amount > 0
                {
                    resultTuple.centralValue  = "Won"
                    resultTuple.rightValue = "\(amount)"
                }                
                result.append(resultTuple)
            }
            
        case .SalesFunnel:
            //FIXME: Need to decide which pipeline needs to be visualised
            let pipe = pipelinesArray[9]
            var previousDealsCounter = 0
            var resultArray: resultArray = []
            
            pipe.stages.reversed().forEach {
                let total = $0.deals.count
                resultArray.append((leftValue: $0.label,
                                    centralValue: "",
                                    rightValue: "\(total + previousDealsCounter)"))
                previousDealsCounter += total
            }
            
            result.append(contentsOf: resultArray.reversed())
            
        default: break
        }
        return result
    }
    
    func getDataFromHubSpot(_ array: [HSAPIMethods]) {
        
        array.forEach { handle(request: $0) }
    }
    
    private func makeUrlPathFor(request: HSAPIMethods,
                                parameters: [HSRequestParameterKeys: String]) -> String {
        
        return apiURL + request.rawValue + parameters.stringFromHttpParameters()
    }
    
    private func handle(request: HSAPIMethods) {
        
        var requestURL: URL?
        var urlPath: String!
        
        switch request
        {
        case .deals:
            urlPath = makeUrlPathFor(request: request, parameters: [.hapiKey: "demo"]) + getDealsParameters[.properties]!
            
        case .contacts:
            urlPath = makeUrlPathFor(request: .contacts, parameters: [.hapiKey: "demo"]) + getContactsParameters[.properties]!
            
        case .dealPipelines:
            urlPath = makeUrlPathFor(request: .dealPipelines, parameters: [.hapiKey: "demo"])
            
        case .owners:
            urlPath = makeUrlPathFor(request: .owners, parameters: [.hapiKey: "demo"])
          
        case .companies:
           urlPath = makeUrlPathFor(request: .companies, parameters: [.hapiKey: "demo"])
            
        case .pages:
            urlPath = makeUrlPathFor(request: .pages, parameters: [.hapiKey: "demo"])
            
        default: break
        }
        
        requestURL = URL(string: urlPath)
        
        guard requestURL != nil else { return }
        
        Alamofire.request(requestURL!, headers: [:])
            .responseJSON(completionHandler:
                { response in
                    
                    self.requestCounter += 1
                    
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
                        case .deals:     self.dealsArray = self.getDealsFrom(json: json)
                        case .contacts:  self.contactsArray = self.getContactsFrom(json: json)
                        case .companies: self.companiesArray = self.getCompaniesFrom(json: json)
                        case .pages:     self.pagesArray = self.getPagesFrom(json: json)
                            
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
    
    private func getCompaniesFrom(json file: [String: Any]) -> [HSCompany] {
        
        let companies = file["companies"] as! [[String: Any]]
        
        let resultArray: [HSCompany] = companies.map { companyJson in
            HSCompany(json: companyJson)
        }
        
        return resultArray
    }
    
    private func getContactsFrom(json file: [String: Any]) -> [HSContact] {
        
        let allContacts = file["contacts"] as! [[String: Any]]
        
        let resultArray: [HSContact] = allContacts.map { contactJson in
            HSContact(json: contactJson)
        }
        
        return resultArray
    }
    
    private func getDealsFrom(json file: [String: Any]) -> [HSDeal] {
        
        guard let allDeals = file["results"] as? [[String: Any]] else { return [HSDeal]() }
        
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
    
    private func getPagesFrom(json file: [String: Any]) -> [HSPage] {
        
        let pages = file["objects"] as! [[String: Any]]
        
        let resultArray = pages.map { HSPage(json: $0) }
        
        return resultArray
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
    
    func appendDealsToCompanies() {
        
        companiesArray = companiesArray.map { company -> HSCompany in
        
            var tempCompany = company
            
            for deal in dealsArray
            {
                if let dealsCompanyIds = deal.companyIds, let companyId = company.companyId
                {
                   
                    if dealsCompanyIds.count > 0 && dealsCompanyIds[0] == companyId { tempCompany.deals.append(deal) }
                }
            }
            return tempCompany
        }
    }
    
    //MARK: Functions for getting key parameters
    //Array in wich deals are closed
    func showClosedDeals() -> [HSDeal] {
        
        return dealsArray.filter {
            
            if let closeDate = $0.closeDate
            {
                return dateIsInCurrentPeriod(closeDate)
            }
            else { return false }
        }
    }
    
    //Array in wich deals are closed and have Amount value
    func showClosedAndWonDeals() -> [HSDeal] {
        
        return dealsArray.filter {
            $0.amount != nil &&
                $0.closeDate != nil  &&
                dateIsInCurrentPeriod($0.closeDate)
        }
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
    
    //Array of deals, sorted by amount value
    func showDealRevenueLeaderboard() -> [HSDeal] {
        
        let deals = dealsArray.filter { $0.amount != nil && $0.amount > 0 }
    
        return deals.sorted { $0.amount > $1.amount }
    }

    //Array of closed deals, sorted by amount value
    func showClosedDealsLeaderboard() -> [HSDeal] {
        
        let deals = showClosedDeals()
        
        return deals.sorted { $0.amount > $1.amount }
    }
    
    //Array of closed and won deals, sorted by amount value
    func showTopWonDeals() -> [HSDeal] {
        
        let deals = showClosedAndWonDeals()
        
        return deals.sorted { $0.amount > $1.amount}
    }
    
    //Marketing
    //Array of contacts for Visit\Contacts KPI
    func showContactsFromVisits() -> [HSContact] {
        
        let referrals = contactsArray.filter { $0.sourceType != nil && $0.sourceType == .referrals }
        let direct = contactsArray.filter { $0.sourceType != nil && $0.sourceType == .directTraffic }
        
        let resultArray = referrals + direct
        
        return resultArray
    }
    
    //Array of customers, that come frome contacts
    func showCustomersFromContacts() -> [HSContact] {
        
        let customers = showContactsFromVisits().filter { $0.becomeCustomerDate != nil }
        
        return customers
    }
    
    //Array of referals
    func showContactsByReferals() -> [HSContact] {
        
        let resultArray = contactsArray.filter { $0.sourceType != nil && $0.sourceType == .referrals }
        
        return resultArray
    }
}

