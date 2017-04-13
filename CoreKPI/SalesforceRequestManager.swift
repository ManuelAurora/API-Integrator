//
//  SalesforceRequestManager.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 10.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import UIKit

struct SFResult
{
    var date:        Date?
    var firstValue:  Float?
    var secondValue: Float?
}

enum SFOpportunityStage: String
{
    case qualification     = "Qualification"
    case needsAnalysis     = "Needs Analysis"
    case negotiationReview = "Negotiation/Review"
    case valueProposition  = "Value Proposition"
    case prospecting       = "Prospecting"
    case perceptAnalysis   = "Perception Analysis"
    case decisionMakers    = "Id. Decision Makers"
    case proposalPrice     = "Proposal/Price Quote"
}

enum URLParameterKey: String
{
    case oauthToken = "oauthToken"
    case query      = "q"
}

enum URLHeaderKey: String
{
    case oauthToken = "Authorization"
}

enum SFQueryType: String
{
    case lead        = "Lead"
    case opportunity = "Opportunity"
    case user        = "User"
}

class SalesforceRequestManager
{
    private var requestCounter: Int = 0 {
        didSet {
            if requestCounter == 3
            {
                requestCounter = 0
                fillRevenueArray()
                NotificationCenter.default.post(
                    name: .salesForceManagerRecievedData,
                    object: nil)
            }
        }
    }
    static let shared = SalesforceRequestManager()
    
    private let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private struct APIMethods
    {
        static let tooling             = "/services/data/v39.0/tooling"
        static let eclair              = "/services/data/v39.0/eclair"
        static let prechatForms        = "/services/data/v39.0/prechatForms"
        static let chatter             = "/services/data/v39.0/chatter"
        static let tabs                = "/services/data/v39.0/tabs"
        static let appMenu             = "/services/data/v39.0/appMenu"
        static let quickActions        = "/services/data/v39.0/quickActions"
        static let queryAll            = "/services/data/v39.0/queryAll"
        static let commerce            = "/services/data/v39.0/commerce"
        static let wave                = "/services/data/v39.0/wave"
        static let analytics           = "/services/data/v39.0/analytics"
        static let search              = "/services/data/v39.0/search"
        static let composite           = "/services/data/v39.0/composite"
        static let parameterizedSearch = "/services/data/v39.0/parameterizedSearch"
        static let theme               = "/services/data/v39.0/theme"
        static let nouns               = "/services/data/v39.0/nouns"
        static let event               = "/services/data/v39.0/event"
        static let serviceTemplates    = "/services/data/v39.0/serviceTemplates"
        static let recent              = "/services/data/v39.0/recent"
        static let connect             = "/services/data/v39.0/connect"
        static let licensing           = "/services/data/v39.0/licensing"
        static let limits              = "/services/data/v39.0/limits"
        static let process             = "/services/data/v39.0/process"
        static let asyncQueries        = "/services/data/v39.0/async-queries"
        static let query               = "/services/data/v39.0/query"
        static let match               = "/services/data/v39.0/match"
        static let emailConnect        = "/services/data/v39.0/emailConnect"
        static let compactLayouts      = "/services/data/v39.0/compactLayouts"
        static let knowledgeManagement = "/services/data/v39.0/knowledgeManagement"
        static let sobjects            = "/services/data/v39.0/sobjects"
        static let actions             = "/services/data/v39.0/actions"
        static let support             = "/services/data/v39.0/support"
    }
    
    private var urlHeaders     = [String: String]()
    private var leads          = [Lead]()
    private var opportunities  = [Opportunity]()
    private var revenueByDates = [Revenue]()
    private var users          = [User]()
    
    private var instanceURL: String!
    private var idURL:       String!
    
    ///  This helper method will return SaleforceKPI which contains token,
    ///  refreshToken and url info.
    ///
    /// - Returns: SalesForceKPI instance
    private func fetchSalesForceKPIEntity() -> SalesForceKPI? {
        
        do {
            let request = NSFetchRequest<SalesForceKPI>(entityName: "SalesForceKPI")
            let result  = try self.managedContext.fetch(request)
            
            if result.count > 0
            {
                let sfEntity = result[0]
                return sfEntity
            }
        }
        catch let error {
            print("DEBUG: Core Data" + error.localizedDescription); return nil
        }
        
        return nil
    }
    
    /// This method updates token using refresh token. It also updates token in
    /// SalesForceKPI instance.
    /// - Parameter success: will be executed after all things done with success
    private func updateToken(success: @escaping success) {
        
        let request = ExternalRequest()
        let sfKPI   = fetchSalesForceKPIEntity()
        
        if let kpi = sfKPI
        {
            request.oauthToken = kpi.oAuthToken!
            request.oauthRefreshToken = kpi.oAuthRefreshToken!
            request.updateAccessToken(servise: .SalesForce, success: { token in
                kpi.oAuthToken = token
                try? self.managedContext.save()
                success()
            }) { error in
                print("DEBUG: \(error)")
            }
        }
    }
    
    /// This method firstly will call updateToken(), then it will set manager's
    /// properties: instanceURL and urlHeaders (oauth token will be appended).
    /// - Parameter success: will be executed after all things done with success
    private func getToken(success: (success?) = nil) {
        
        updateToken {
            if let sfEntity = self.fetchSalesForceKPIEntity()
            {
                self.instanceURL = sfEntity.instance_url
                self.urlHeaders[URLHeaderKey.oauthToken.rawValue] = "Bearer " + sfEntity.oAuthToken!
                if let s = success { s() }
            }
        }
    }    
    
    /// This method will execute REST API query for all given urls.
    ///
    /// - Parameter urls: Contains all url that need to be requested
    private func requestSalesForce(urls: [String]) {
        
        urls.forEach {
            request($0, method: .get, parameters: nil, headers: urlHeaders).responseJSON {
                data in
                
                if let json = data.value as? [String: Any], let records = json["records"] as? [[String: Any]]
                {
                    records.forEach { record in
                        if let attributes =  record["attributes"] as? [String: String],
                            let typeString =  attributes["type"],
                            let type = SFQueryType(rawValue: typeString)
                        {
                            switch type
                            {
                            case .lead:
                                self.leads.append(Lead(json: record))
                                
                            case .opportunity:
                                self.opportunities.append(Opportunity(json: record))
                                
                            case .user:
                                self.users.append(User(json: record))
                            }
                        }
                    }
                }
                self.requestCounter += 1
            }
        }
    }
    
    /// This method parses all opportunity structs, and fills property array 
    /// revenueByDates with Revenue objects
    private func fillRevenueArray() {
        
        let wonOpportunities = opportunities.map { opportunity -> Opportunity? in
            if opportunity.isWon != nil && opportunity.isWon == true
            {
                return opportunity
            }
            return nil
        }
        
        wonOpportunities.forEach {
            if let date = $0?.closeDate, let amount = $0?.amount
            {
                let revenue = Revenue(amount:amount, date: date)
                revenueByDates.append(revenue)
            }
        }
    }
    
    /// This method forms query string which will be used as url request parameter
    ///
    /// - Parameter queryType: type of record that will be requested
    /// - Returns: formated string
    private func formParametersFor(queryType: SFQueryType) -> String {
        
        var parameters: [URLParameterKey: String] = [:]
        let currentMonth = Date().beginningOfMonth!.stringForSalesForceQuery()
        
        switch queryType
        {
        case .lead:
            parameters[.query] = "SELECT Name, CreatedDate, Status, Id, isConverted, Industry FROM Lead WHERE CreatedDate > \(currentMonth)"
            
        case .opportunity:
            parameters[.query] = "SELECT Id, Name, Amount, IsWon, CloseDate, StageName, OwnerId FROM Opportunity WHERE CreatedDate > \(currentMonth)"
            
        case .user:
            parameters[.query] = "SELECT Id, Name, Email FROM User"
        }
        
        return parameters.stringFromHttpParameters()
    }
    
    private func clearAllData() {
        
        leads.removeAll()
        opportunities.removeAll()
        revenueByDates.removeAll()
        
    }
    
    /// This method fetch all data from SalesForce.
    func requestData() {
        
        clearAllData()
        
        getToken { [weak self] in
            
            guard let weakSelf = self else { return }
            
            let leadsUrl = weakSelf.instanceURL + APIMethods.query + "?" + weakSelf.formParametersFor(queryType: .lead)
            let oppUrl   = weakSelf.instanceURL + APIMethods.query + "?" + weakSelf.formParametersFor(queryType: .opportunity)
            let userUrl  = weakSelf.instanceURL + APIMethods.query + "?" + weakSelf.formParametersFor(queryType: .user)
            
            weakSelf.requestSalesForce(urls: [leadsUrl, oppUrl, userUrl])
        }
    }
    
    /// This method returns data for Converted Leads KPI
    ///
    /// - Returns: array of SFResult
    func getLeadsConvertedLeads() -> [SFResult] {
        
        var result   = [SFResult]()
        let newLeads = leads
        let convertedLeads = leads.filter { $0.isConverted != nil && $0.isConverted == true }
        
        let currentDate = Date()
        let calendar    = Calendar.current
        let days        = (calendar.range(of: .day,
                                          in: .month,
                                          for: currentDate))!
        
        for day in days.lowerBound..<days.upperBound
        {
            let leadsThisDay = newLeads.filter { lead in
                let creationDay = creationDayFrom(date: lead.createdDate)
                return creationDay == day
            }
            
            let convertedThisDay = convertedLeads.filter { lead in
                let creationDay = creationDayFrom(date: lead.createdDate)
                return creationDay == day
            }
            
            if leadsThisDay.count > 0 || convertedThisDay.count > 0
            {
                var sfResult = SFResult()
                
                sfResult.firstValue  = Float(leadsThisDay.count)
                sfResult.secondValue = Float(convertedThisDay.count)
                
                result.append(sfResult)
            }
        }
        
        return result
    }
    
    /// This method returns day-number from chosen date.
    ///
    /// - Parameter date: date to take value from.
    /// - Returns: integer representation of day's number in current month
    private func creationDayFrom(date: Date) -> Int {
        
        let calendar   = Calendar.current
        let dayCreated = calendar.component(.day, from: date)
        
        return dayCreated
    }
    
    /// This method returns values for Revenue/New Leads KPI
    ///
    /// - Returns: array of tuple (date, value)
    func getRevenueNewLeads() -> [SFResult] {
        
        var result      = [SFResult]()
        let newLeads    = leads
        let revenue     = revenueByDates
        let currentDate = Date()
        let calendar    = Calendar.current
        let days        = (calendar.range(of: .day,
                                         in: .month,
                                         for: currentDate))!
        
        for day in days.lowerBound..<days.upperBound
        {
            let newLeads = newLeads.filter { lead in
                let dayCreated = creationDayFrom(date: lead.createdDate)
                return dayCreated == day
            }
            
            let revenuesThisDay = revenue.filter { revenue in
                let dayClosed   = creationDayFrom(date: revenue.date)
                return dayClosed == day
            }
            
            let totalRevenueThisDay = revenuesThisDay.reduce(Float(0), { (result, rev) -> Float in
                return result + rev.amount
            })
            
            if newLeads.count > 0
            {
                let dateComponents = DateComponents(year: calendar.component(.year, from: currentDate),
                                                    month: calendar.component(.month, from: currentDate),
                                                    day: day)
                
                let date = calendar.date(from: dateComponents)
                
                var sfResult        = SFResult()
                sfResult.date       = date!
                sfResult.firstValue = totalRevenueThisDay / Float(newLeads.count)
                
                result.append(sfResult)
            }
        }
        return result
    }
    
    /// For some reason Semeon hardcoded chart values to tuple.
    /// This extra method will help us convert data to it.
    /// - Parameter kpi: kpi value
    /// - Returns: tuple (date, val, val)
    func getDataForChart(kpi: SalesForceKPIs) -> resultArray {
        
        var array: resultArray = []
        
        switch kpi
        {
        case .RevenueNewLeads:
            let data = getRevenueNewLeads()
            
            data.forEach {
                array.append(( leftValue:    "\($0.date!)",
                    centralValue: "\($0.firstValue ?? 0)",
                    rightValue:   "\($0.secondValue ?? 0)"))
            }
            
        case .ConvertedLeads:
            let data = getLeadsConvertedLeads()
            
            data.forEach {
                array.append((leftValue:    "\($0.firstValue ?? 0)",
                              centralValue: "",
                              rightValue:   "\($0.secondValue ?? 0)"))
            }
            
        case .OpenOpportunitiesByStage:
            for stage in iterateEnum(SFOpportunityStage.self)
            {
                let oppsStaged = opportunities.filter { $0.stage == stage.rawValue }
                array.append((leftValue: stage.rawValue,
                              centralValue: "",
                              rightValue: "\(oppsStaged.count)"))
            }
            
        case .TopSalesRep:
            users.forEach { user in
                let sales = opportunities.filter {
                    $0.isWon   == true && $0.ownerId == user.id
                }
                
                if sales.count > 0
                {
                    guard let name = user.name else { return }
                    
                    let revenue = sales.reduce(Float(0)) { (result, opp) -> Float in
                        return result + opp.amount
                    }
                    
                    array.append((leftValue:    name,
                                  centralValue: "\(sales.count)",
                                  rightValue:   "\(revenue)"))
                }
            }
            
        case .NewLeadsByIndustry:
            var listOfIndustries = [String]()
                
            leads.forEach {
                guard var industry = $0.industry,
                    !listOfIndustries.contains(industry) else { return }
                
                if industry == "" { industry = "Not Set" }
                
                listOfIndustries.append(industry)
            }
            
            listOfIndustries.forEach { industry in
                let leadsByIndustry = leads.filter { lead in
                    var mutableLead = lead
                    if mutableLead.industry == "" { mutableLead.industry = "Not Set" }
                    return mutableLead.industry == industry                    
                }
                
                array.append((leftValue: industry,
                              centralValue: "",
                              rightValue: "\(leadsByIndustry.count)"))
            }
            
        default: break
        }
        
        return array
    }
}

