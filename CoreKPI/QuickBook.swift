//
//  QuickBook.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 20.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import OAuthSwift
import Alamofire

enum QBPredifinedDateRange: String
{
    case today = "Today"
    case yesterday = "Yesterday"
    case thisMonth = "This Month"
}

enum QBQueryParameterKeys: String
{
    case dateMacro = "date_macro"
    case startDate = "start_date" // YYYY-MM-DD
    case endDate   = "end_date"
}

enum AuthenticationParameterKeys: String
{
    case callbackUrl = "callbackUrl"
    case companyId = "companyId"
    case oauthToken = "oauthToken"
    case oauthRefreshToken = "oauthRefreshToken"
}

enum QBMethod: String
{
    case balanceSheet = "/reports/BalanceSheet"
}

struct ExternalKpiInfo
{
    var kpiName: String = ""
    var kpiValue: String = ""
}

struct QBBalanceSheet: QuickBookMethod
{
    internal var methodName: QBMethod
    
    var queryParameters = [QBQueryParameterKeys: String]()
    
    init(with queryParameters: [QBQueryParameterKeys: String]) {
        self.queryParameters = queryParameters
        self.methodName = QBMethod.balanceSheet
    }
    
    func formUrlPath(method: QuickBookMethod) -> String {
        
        return queryParameters.stringFromHttpParameters()
    }
}

class QuickBookDataManager
{
    typealias resultArray = [(leftValue: String, centralValue: String, rightValue: String)]
    private let urlBase = "https://sandbox-quickbooks.api.intuit.com/v3/company/"
    private var balanceSheet: resultArray = []
    
    var queryMethod: QuickBookMethod?
        
    lazy var serviceParameters: [AuthenticationParameterKeys: String] = {
        let parameters: [AuthenticationParameterKeys: String] = [
            .companyId:   "123145773393399",
            .callbackUrl: "CoreKPI.CoreKPI:/oauth-callback/intuit"
        ]
        
        return parameters
    }()
    
    func getInfoFor(kpi: QiuckBooksKPIs) -> resultArray {
        
        switch kpi
        {
        case .Balance:
            return balanceSheet
            
        default:
            break
        }
        
       return resultArray()
    }
    
    class func shared() -> QuickBookDataManager {
        
        struct Singelton
        {
            static let manager = QuickBookDataManager()
        }
        
        return Singelton.manager
    }
    
    var companyID: String {
        set {
            return serviceParameters[.companyId] = companyID
        }
        get {
            return serviceParameters[.companyId]!
        }
    }
    
    convenience init(method: QuickBookMethod) {
        self.init()
        queryMethod = method
    }
    
    func formUrlPath(method: QuickBookMethod) -> String {
        
        let companyId = serviceParameters[AuthenticationParameterKeys.companyId]!
        let fullUrlPath = self.urlBase +
            companyId +
            method.methodName.rawValue + "?" +
            method.queryParameters.stringFromHttpParameters()

        return fullUrlPath
    }
    
    func handle(response: OAuthSwiftResponse ) -> ExternalKpiInfo? {
        
        guard let queryMethod = queryMethod else { print("DEBUG: Query method not found"); return nil }
        
        switch queryMethod.methodName
        {
        case .balanceSheet:
            if let jsonDict = try? response.jsonObject(options: .allowFragments) as? [String: Any] {
                
                let rows = jsonDict!["Rows"] as! [String: Any]
                let rows2 = rows["Row"] as! [[String: Any]]
                
                var kpiInfo = ExternalKpiInfo()
                
                for row in rows2
                {
                    let summary = row["Summary"] as! [String: Any]
                    let colDataSum = summary["ColData"] as! [[String: Any]]
                    let kpiSummary = colDataSum[1] as! [String: String]
                    //let kpiTitle = colDataSum[0] as! [String: String]
                    
                    kpiInfo.kpiName = QiuckBooksKPIs.Balance.rawValue
                    kpiInfo.kpiValue = kpiSummary["value"]!
                }
                
                let result = (kpiInfo.kpiName,"",kpiInfo.kpiValue)
                
                balanceSheet.append(result)
                
                return kpiInfo
            }
            else {
                print("no json response")
            }
            
            return nil
        }
    }
}

protocol QuickBookMethod
{
    var queryParameters: [QBQueryParameterKeys: String] { get }
    var methodName: QBMethod { get }
    func formUrlPath(method: QuickBookMethod) -> String
}
