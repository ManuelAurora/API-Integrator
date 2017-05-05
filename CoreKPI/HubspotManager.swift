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

typealias resultElement = (leftValue: String, centralValue: String, rightValue: String)
typealias hubspotParameters = [HSRequestParameterKeys: String]
public typealias jsonDict = [String: Any]

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
    case code       = "code"
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
    
    var dealsArray: [HSDeal] = []
    var pagesArray: [HSPage] = []
    var contactsArray: [HSContact] = []    
    var ownersArray: [HSOwner] = []
    var companiesArray: [HSCompany] = []
    var pipelinesArray: [HSPipeline] = []    
   
    var merged: Bool = false //This variable prevents multiple didSet from pipelinesArray
    
    var hubspotKPIManagedObject: HubspotKPI {
        do {
            let fetchHubspotKPI = NSFetchRequest<HubspotKPI>(entityName: "HubspotKPI")
            let result = try? managedContext.fetch(fetchHubspotKPI)
            let hskpi = (result == nil) || result!.isEmpty ? HubspotKPI() : result![0]
            
            return hskpi
        }
    }
    
    var hubspotExternal: [ExternalKPI] {
        
        let result = hubspotKPIManagedObject.externalKPI?.map { kpi in
            return kpi as! ExternalKPI
        }
       return result!
    }
    
    lazy var oauthSwift: OAuth2Swift = {
        
        let urlString = "https://app.hubspot.com/oauth/authorize"

        let oauth = OAuth2Swift(consumerKey: self.oauthParameters[.clientID]!,
                                          consumerSecret: "",
                                          authorizeUrl: urlString,
                                          responseType: "")
        
        return oauth
    }()
    
    private var requestCounter: Int = 0 {
        didSet {
            if requestCounter == 6
            {
                requestCounter = 0
                merged = false

                updatePipelinesAndDeals()
                
                NotificationCenter.default.post(
                name: .hubspotManagerRecievedData,
                object: nil)
            }
        }
    }
    
    private let apiURL = "https://api.hubapi.com"
    private let authorizeURL = "https://app.hubspot.com"
    
    var currentDate: Date {
        return Date()
    }
    
    lazy var oauthParameters: [HSRequestParameterKeys: String] = [
        .clientID: "93a8ccfd-db25-40b2-b793-969f5b4d3b21",
        .redirectURI: "https://corekpi.gtwenty.com/web/redirect/ios",
        .scope: "contacts content" //scope=x%20x where x is a scope
    ]
    
    lazy var getTokenParameters: [HSRequestParameterKeys: String] = [
        .grantType: "authorization_code",
        .clientID: "93a8ccfd-db25-40b2-b793-969f5b4d3b21",
        .clientSecret: "e9500393-5d36-4db3-a228-a449bc9e62a3",
        .redirectURI: "https://corekpi.gtwenty.com/web/redirect/ios"
    ]
    
    lazy var getDealsParameters: [HSRequestParameterKeys: String] = [
        .properties: "&properties=amount&properties=closedate&properties=createdate&properties=dealstage&properties=hubspot_owner_id&count=100"
    ]
    
    lazy var getContactsParameters: [HSRequestParameterKeys: String] = [
        .properties: "&count=250&property=createdate&property=notes_last_contacted&property=hubspot_owner_assigneddate&property=hubspot_owner_id&property=hs_analytics_source"
    ]
    
    func makeUrlPathForAuthentication() -> String {
        
        return authorizeURL + HSAPIMethods.oauth.rawValue + oauthParameters.stringFromHttpParameters()
    }
    
    let nc = NotificationCenter.default
    
    init() {        
        nc.addObserver(self, selector: #selector(getAccessToken),
                       name: .hubspotCodeRecieved,
                       object: nil)        
    }
    
    deinit {
        nc.removeObserver(self)
    }
    
    private func makeUrlPathGetToken() -> String {
       
        return ""
    }
    
    //This function filles deals array in Pipeline.stage.deals
    private func updatePipelinesAndDeals() {
        
        if pipelinesArray.count > 0
        && dealsArray.count     > 0
        && companiesArray.count > 0
        && merged == false
        {
            appendDealsToCompanies()
            appendDealsToPipelineStages()
            print("DEBUG: Merged")
        }
    }
    
    private func requestToken(with url: URL) {
        
        Alamofire.request(url,
                          method: HTTPMethod.post,
                          parameters: [:],
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON
            {
                response in
                if let json = response.value as? jsonDict,
                    let token = json["access_token"] as? String,
                    let refToken = json["refresh_token"] as? String,
                    let expired = json["expires_in"] as? Double {
                    
                    let hubSpotMO = self.hubspotKPIManagedObject
                    let validTill = Date(timeInterval: expired,
                                         since: Date())
                    
                    hubSpotMO.oauthToken     = token
                    hubSpotMO.refreshToken   = refToken
                    hubSpotMO.validationDate = validTill as NSDate
                    
                    try? self.managedContext.save()
                    
                    GetExternalServices().getData(success: { services in
                        
                        self.hubspotExternal.forEach { kpi in
                            let semenKPI = KPI(kpiID: -2,
                                               typeOfKPI: .IntegratedKPI,
                                               integratedKPI: kpi,
                                               createdKPI: nil,
                                               imageBacgroundColour: nil)
                            let addRequest = AddKPI()
                            addRequest.type = services.filter { $0.name == "HubSpot" }.first!.name
                            
                            addRequest.addKPI(kpi: semenKPI, success: { result in
                                print("Added new Internal KPI on server")
                            }, failure: { error in
                                print(error)
                            })
                        }
                        
                    }, failure: { error in
                        print(error)
                    })
                    
                    self.nc.post(name: .hubspotTokenRecieved,
                                 object: nil)
                }
        }
        
    }
    
    @objc func getAccessToken(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let code = userInfo["apiCode"] as? String else {
            return
        }
        
        var parameters = getTokenParameters
        
        parameters[.code] = code
        
        let urlString = makeUrlPathFor(request: .getToken,
                                 parameters: parameters)
        let url = URL(string: urlString)!
        
        requestToken(with: url)
    }
    
    private func refreshToken(_ completion: ()->()) {
        
        var parameters = getTokenParameters
        
        parameters[.refreshToken] = hubspotKPIManagedObject.refreshToken!
        parameters[.grantType]    = "refresh_token"
        
        let urlString = makeUrlPathFor(request: .getToken,
                                       parameters: parameters)
        let url = URL(string: urlString)!
        
        requestToken(with: url)
    }
    
    private func checkNeedsToRefreshToken(_ completion: ()->()) {
        
        let kpi = hubspotKPIManagedObject
        let currDate = Date()
        let tokenExpiredDate = kpi.validationDate! as Date
        
        if tokenExpiredDate <= currDate
        {
            refreshToken(completion)
        }
        else
        {
            completion()
        }
    }
    
    func connect() {
        
        checkNeedsToRefreshToken { 
            getDataFromHubSpot([.pages,
                                .companies,
                                .owners,
                                .deals,
                                .contacts,
                                .dealPipelines])
        }
    }
    
    func createNewEntityFor(service: IntegratedServices,
                            kpiName: String,
                            pipelineID: String? = nil) {
        
        let serviceName = service.rawValue        
        let extKPI = ExternalKPI()
        
        extKPI.userID = Int64(ModelCoreKPI.modelShared.profile.userId)
        extKPI.kpiName = kpiName
        extKPI.hsPipelineID = pipelineID
        extKPI.serviceName = serviceName
        extKPI.hubspotKPI = hubspotKPIManagedObject
                        
        do {
            try managedContext.save()
            
            NotificationCenter.default.post(Notification(name: .newExternalKPIadded))
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
        
    func getDataForReport(kpi: HubSpotCRMKPIs, pipelineId: String? = nil) -> resultArray {
        
        var result: resultArray = []
        
        switch kpi
        {
        case .DealsRevenue:
            let deals   = showClosedDeals()
            let revenue = showClosedAndWonDeals()
            
            deals.forEach { deal in
                let wonDeals = revenue.filter { $0.dealId == deal.dealId }
                var resultTuple = (leftValue: "",
                                   centralValue: "0",
                                   rightValue: "0")
                
                if let date = deal.createDate
                {
                    resultTuple.leftValue = "\(date)"
                }
                
                if let wonDeal = wonDeals.first
                {
                    let wonAmount  = wonDeal.amount ?? 0
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
            
        case .SalesFunnel, .DealStageFunnel:
            let pipe = pipelinesArray.filter { $0.pipelineId == pipelineId }[0]
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
            
        case .SalesPerformance:
            let contactsCreated  = showContactsCreated().count
            let contactsAssigned = showContactsAssigned().count
            let contactsWorked   = showContactsWorked().count
            let newDealsCreated  = showNewDealsCreated().count
            let dealsClosedWon   = showClosedAndWonDeals().count
            
            result.append((leftValue: "Contacts created",
                           centralValue: "",
                           rightValue: "\(contactsCreated)"))
            
            result.append((leftValue: "Contacts assigned",
                           centralValue: "",
                           rightValue: "\(contactsAssigned)"))
            
            result.append((leftValue: "Contacts worked",
                           centralValue: "",
                           rightValue: "\(contactsWorked)"))
            
            result.append((leftValue: "Deals created",
                           centralValue: "",
                           rightValue: "\(newDealsCreated)"))
            
            result.append((leftValue: "Deals closed won",
                           centralValue: "",
                           rightValue: "\(dealsClosedWon)"))
            
        case .SalesLeaderboard:
            let salesLeaderboard = showSalesLeaderboard()
            
            salesLeaderboard.forEach {
                result.append((leftValue:    "\($0.firstName ?? "")",
                               centralValue: "\($0.lastName ?? "")",
                               rightValue:   "\($0.sum())"))
            }
            
        case .DealRevenueLeaderboard:
            let revenues = showDealRevenueLeaderboard()
            
            revenues.forEach {
            result.append((leftValue:    "id: \($0.dealId ?? 0)",
                           centralValue: "",
                           rightValue:   "\($0.amount ?? 0)"))
            }
            
        case .ClosedDealsLeaderboard:
            let leaderboard = showClosedDealsLeaderboard()
            
            leaderboard.forEach {
                result.append((leftValue:    "id: \($0.dealId ?? 0)",
                               centralValue: "",
                               rightValue:   "\($0.amount ?? 0)"))            
            }
            
        case .TopWonDeals:
            let deals = showTopWonDeals()
            
            deals.forEach {
                result.append((leftValue: "id: \($0.dealId!)",
                               centralValue: "",
                               rightValue: "\($0.amount!)"))
            }
            
        case .RevenueByCompany:
            let companies = companiesArray.filter { $0.deals.count > 0 }
            
            companies.forEach {
                
                let dealsToSum = $0.deals.filter { $0.amount != nil &&
                                                   $0.amount > 0 &&
                                                   dateIsInCurrentPeriod($0.closeDate)
                }
                
                let revenue = dealsToSum.reduce(Float(0), { (res, deal) -> Float in
                    res + Float(deal.amount)
                })
                
                var resElem: resultElement = ("","","")
                
                resElem.leftValue = "id: \($0.companyId!)"
                resElem.rightValue = "\(revenue)"
                
                result.append(resElem)
            }
        }
        return result
    }
    
    func getDataForReport(kpi: HubSpotMarketingKPIs, pipelineId: String? = nil) -> resultArray {
        
        var result: resultArray = []
        
        switch kpi
        {
        case .VisitsContacts:
            let calendar   = Calendar.current
            let contacts   = showContactsCreated()
            let days       = (calendar.range(of: .day,
                                             in: .month,
                                             for: currentDate))!
                    
            for day in days.lowerBound..<days.upperBound
            {
                let contactsForDay = contacts.filter {
                    let createDay = calendar.dateComponents([.day], from: $0.createDate)
                    return createDay.day! == day
                }
                
                let resValue: resultElement
                let dateComponents = DateComponents(year: calendar.component(.year, from: currentDate),
                                                    month: calendar.component(.month, from: currentDate),
                                                    day: day)
                                
                let analisedDate = calendar.date(from: dateComponents)
                resValue.centralValue = ""
                resValue.leftValue = "\(analisedDate!)"
                resValue.rightValue = "\(contactsForDay.count)"
                
                result.append(resValue)
            }
            
        case .MarketingFunnel, .MarketingPerformance:
            let contacts = showContactsCreated()
            let visits = contacts.count * 10
            let customers = showCustomersFromContacts()
            
            result.append((leftValue:    "Visits",
                           centralValue: "",
                           rightValue:   "\(visits)"))
            
            result.append((leftValue:    "Contacts",
                           centralValue: "",
                           rightValue:   "\(contacts.count)"))
            
           result.append((leftValue:    "Customers",
                          centralValue: "",
                          rightValue:   "\(customers.count)"))
            
        case .ContactsVisitsBySource:
            let referrals = showContactsByReferrals()
            let direct = showContactsFromDirectTraffic()
            let offline = showContactsFromOffline()
            
            result.append((leftValue:    "Referrals",
                           centralValue: "",
                           rightValue:   "\(referrals.count)"))
            
            result.append((leftValue:    "Direct",
                           centralValue: "",
                           rightValue:   "\(direct.count)"))
            
            result.append((leftValue:    "Offline",
                           centralValue: "",
                           rightValue:   "\(offline.count)"))
            
        case .ContactsByReferrals:
            let referrals = showContactsByReferrals()
            
                result.append((leftValue: "Referrals:",
                               centralValue: "",
                               rightValue: "\(referrals.count)"))
            
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
            urlPath = makeUrlPathFor(request: request,
                                     parameters: [:]) + getDealsParameters[.properties]!
            
        case .contacts:
            urlPath = makeUrlPathFor(request: .contacts,
                                     parameters: [:]) + getContactsParameters[.properties]!
            
        case .dealPipelines:
            urlPath = makeUrlPathFor(request: .dealPipelines,
                                     parameters: [:])
            
        case .owners:
            urlPath = makeUrlPathFor(request: .owners,
                                     parameters: [:])
          
        case .companies:
           urlPath = makeUrlPathFor(request: .companies,
                                    parameters: [:])
            
        case .pages:
            urlPath = makeUrlPathFor(request: .pages,
                                     parameters: [:])
            
        default: break
        }
        
        requestURL = URL(string: urlPath)
        
        guard requestURL != nil else { return }
        
        let kpi    = hubspotKPIManagedObject
        let token  = kpi.oauthToken!
        let header = ["Authorization": "Bearer " + token]
        
        Alamofire.request(requestURL!, headers: header)
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
        
        self.requestCounter += 1
        
        return resultArray
    }
    
    private func getContactsFrom(json file: [String: Any]) -> [HSContact] {
        
        let allContacts = file["contacts"] as! [[String: Any]]
        
        let resultArray: [HSContact] = allContacts.map { contactJson in
            HSContact(json: contactJson)
        }
        
        self.requestCounter += 1
        
        return resultArray
    }
    
    private func getDealsFrom(json file: [String: Any]) -> [HSDeal] {
        
        guard let allDeals = file["results"] as? [[String: Any]] else { return [HSDeal]() }
        
        let resultArray: [HSDeal] = allDeals.map { dealJson in
            HSDeal(json: dealJson)
        }
        
        self.requestCounter += 1
        
        return resultArray
    }
    
    private func getPipelinesFrom(json file: [[String: Any]]) -> [HSPipeline] {
        
        let pipes = file.map { pipelineJson -> HSPipeline in
            
            var pipeline = HSPipeline(json: pipelineJson)
            
            if let stages = pipelineJson["stages"] as? [[String: Any]]
            {
                pipeline.stages = stages.map { HSStage(json: $0) }
            }
            
            return pipeline
        }
        
        self.requestCounter += 1
        return pipes
    }
    
    private func getOwnersFrom(json file: [[String: Any]]) -> [HSOwner] {
        
        self.requestCounter += 1
        return file.map { HSOwner(json: $0) }
    }
    
    private func getPagesFrom(json file: [String: Any]) -> [HSPage] {
        
        let pages = file["objects"] as! [[String: Any]]
        
        let resultArray = pages.map { HSPage(json: $0) }
        
        self.requestCounter += 1
        return resultArray
    }
    
    private func dateIsInCurrentPeriod(_ date: Date) -> Bool {
        
        let comparisonResult = Calendar.current.compare(currentDate,
                                                        to: date,
                                                        toGranularity: .month)
        
        return comparisonResult == .orderedSame ? true : false
    }
    
    private func appendDealsToPipelineStages() {
        
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
            merged = true
            return pipelineModified
        }
    }
    
    func appendDealsToCompanies() {
        
        let tempArray = companiesArray.map { company -> HSCompany in
            
            var tempCompany = company
            
            dealsArray.forEach {
                if let dealsCompanyIds = $0.companyIds, let companyId = company.companyId
                {
                    if dealsCompanyIds.count > 0 && dealsCompanyIds[0] == companyId {
                        tempCompany.deals.append($0)
                    }
                }
            }
            return tempCompany
        }
        
        companiesArray.removeAll()
        companiesArray.append(contentsOf: tempArray)
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
            $0.amount != nil && $0.amount > 0 &&
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
        
        return contactsArray.filter { $0.assignDate != nil && dateIsInCurrentPeriod($0.assignDate) }
    }
    
    //Array filled with contacts wich was contacted in given period
    func showContactsWorked() -> [HSContact] {
        
        return contactsArray.filter { ($0.lastContactDate != nil) && dateIsInCurrentPeriod($0.lastContactDate) }
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
        
        return deals.sorted { $0.amount ?? 0 > $1.amount ?? 0 }
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
   
    //Array of contacts from offline
    func showContactsFromOffline() -> [HSContact] {
        
        let resultArray = contactsArray.filter { $0.sourceType != nil && $0.sourceType == .offline }
        
        return resultArray
    }
    
    //Array of directs
    func showContactsFromDirectTraffic() -> [HSContact] {
        
        let resultArray = contactsArray.filter { $0.sourceType != nil && $0.sourceType == .directTraffic }
        
        return resultArray
    }
    
    //Array of referals
    func showContactsByReferrals() -> [HSContact] {
        
        let resultArray = contactsArray.filter { $0.sourceType != nil && $0.sourceType == .referrals }
        
        return resultArray
    }
}

