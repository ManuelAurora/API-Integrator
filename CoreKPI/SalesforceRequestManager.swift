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

typealias salesForceResult = (date: Date, value: Float)

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
    case Lead        = "Lead"
    case Opportunity = "Opportunity"
}

class SalesforceRequestManager
{
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
                            case .Lead:
                                self.leads.append(Lead(json: record))
                                
                            case .Opportunity:
                                self.opportunities.append(Opportunity(json: record))
                            }
                        }
                    }
                }
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
        case .Lead:
            parameters[.query] = "SELECT Name, CreatedDate, Status, Id, isConverted, Industry FROM Lead WHERE CreatedDate > \(currentMonth)"
            
        case .Opportunity:
            parameters[.query] = "SELECT Id, Name, Amount, IsWon, CloseDate FROM Opportunity WHERE CreatedDate > \(currentMonth)"
        }
        
        return parameters.stringFromHttpParameters()
    }
    
    
    /// This method fetch all data from SalesForce.
    func requestData() {
        
        getToken { [weak self] in
            let leadsUrl = (self?.instanceURL)! + APIMethods.query + "?" + (self?.formParametersFor(queryType: .Lead))!
            let oppUrl   = (self?.instanceURL)! + APIMethods.query + "?" + (self?.formParametersFor(queryType: .Opportunity))!
            
            self?.requestSalesForce(urls: [leadsUrl, oppUrl])
        }
    }
    
    
    /// This method returns values for Revenue/New Leads KPI
    ///
    /// - Returns: array of tuple (date, value)
    func getRevenueNewLeads() -> [salesForceResult] {
        
        var result = [salesForceResult]()
        
        fillRevenueArray()
        
        let newLeads = leads
        let revenue  = revenueByDates
        let currentDate = Date()
        let calendar    = Calendar.current
        let days        = (calendar.range(of: .day,
                                         in: .month,
                                         for: currentDate))!
        
        for day in days.lowerBound..<days.upperBound
        {
            let newLeads = newLeads.filter { lead in
                let dayCreated = calendar.component(.day, from: lead.createdDate)
                return dayCreated == day
            }
            
            let revenuesThisDay = revenue.filter { revenue in
                let dayClosed = calendar.component(.day, from: revenue.date)
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
                
                let sfResult: salesForceResult
                sfResult.date  = date!
                sfResult.value = totalRevenueThisDay / Float(newLeads.count) 
                
                result.append(sfResult)
            }
        }
        return result
    }
}
