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

enum QBPredifinedSummarizeValues: String
{
    case days = "Days"
}

enum QBQueryParameterKeys: String
{
    case dateMacro = "date_macro"
    case startDate = "start_date" // YYYY-MM-DD
    case endDate   = "end_date"
    case summarizeBy = "summarize_column_by"
    case query = "query"
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
    case balanceSheet   = "/reports/BalanceSheet"
    case profitLoss     = "/reports/ProfitAndLoss"
    case vendorExpenses = "/reports/VendorExpenses"
    case accountList    = "/reports/AccountList"
    case query          = "/query"
}

struct ExternalKpiInfo
{
    var kpiName: String = ""
    var kpiValue: String = ""
}

struct QBQuery: QuickBookMethod
{
    internal var methodName: QBMethod
    
    internal var queryParameters: [QBQueryParameterKeys : String]
    
    internal func formUrlPath(method: QuickBookMethod) -> String {
        return queryParameters.stringFromHttpParameters()
    }
    
    init(with queryParameters: [QBQueryParameterKeys: String]) {
        self.queryParameters = queryParameters
        self.methodName = QBMethod.query
    }
}

struct QBAccountList: QuickBookMethod
{
    internal var methodName: QBMethod
    
    internal var queryParameters: [QBQueryParameterKeys : String]
    
    internal func formUrlPath(method: QuickBookMethod) -> String {
        return queryParameters.stringFromHttpParameters()
    }
    
    init(with queryParameters: [QBQueryParameterKeys: String]) {
        self.queryParameters = queryParameters
        self.methodName = QBMethod.accountList
    }
}

struct QBvendorExpenses: QuickBookMethod
{
    internal var methodName: QBMethod
    
    internal var queryParameters: [QBQueryParameterKeys : String]
    
    internal func formUrlPath(method: QuickBookMethod) -> String {
        return queryParameters.stringFromHttpParameters()
    }
    
    init(with queryParameters: [QBQueryParameterKeys: String]) {
        self.queryParameters = queryParameters
        self.methodName = QBMethod.vendorExpenses
    }
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

struct QBProfitAndLoss: QuickBookMethod
{
    internal var methodName: QBMethod
    
    internal var queryParameters: [QBQueryParameterKeys : String]
    
    internal func formUrlPath(method: QuickBookMethod) -> String {
        return queryParameters.stringFromHttpParameters()
    }

    init(with queryParameters: [QBQueryParameterKeys: String]) {
        self.queryParameters = queryParameters
        self.methodName = QBMethod.profitLoss
    }
}

class QuickBookDataManager
{
    typealias resultArray = [(leftValue: String, centralValue: String, rightValue: String)]
    
    private let urlBase = "https://sandbox-quickbooks.api.intuit.com/v3/company/"
    private var balanceSheet: resultArray = []
    private var profitAndLoss: resultArray = []
    private var accountList: resultArray  = []
    
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
        
        //TODO:  This method NEED to be refined, due equivalent responses
        
        guard let queryMethod = queryMethod else { print("DEBUG: Query method not found"); return nil }
        
        if let jsonDict = try? response.jsonObject(options: .allowFragments) as? [String: Any] {
            
            switch queryMethod.methodName
            {
            case .balanceSheet:
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
                
            case .query:
                
                let queryResult = jsonDict!["QueryResponse"] as! [String: Any]
                
                  print(queryResult)
                
            case .profitLoss:
                let rows = jsonDict!["Rows"] as! [String: Any]
                let rows2 = rows["Row"] as! [[String: Any]]
                
                for row in rows2
                {
                    let summary = row["Summary"] as! [String: Any]
                    let colDataSum = summary["ColData"] as! [[String: Any]]
                    
                    let kpiTitle = colDataSum[0] as! [String: String]
                    
                    if kpiTitle["value"] == "Net Income"
                    {
                        for item in colDataSum where (item["value"] as! String) != "Net Income"
                        {
                            let result = ("Net Income", "", item["value"] as! String)
                            
                            profitAndLoss.append(result)
                            print("DEBUG: \(profitAndLoss)")
                        }
                    }
                }
                
            case .accountList:
                let rows = jsonDict!["Rows"] as! [String: Any]
                let rows2 = rows["Row"] as! [[String: Any]]
                
                for row in rows2
                {
                    let colData = row["ColData"] as! [[String: String]]
                    let result = (colData[0]["value"], "", colData[4]["value"])
                    
                    print("DEBUG: \(result)")
                }
                
            case .vendorExpenses:
                let rows = jsonDict!["Rows"] as! [String: Any]
                let rows2 = rows["Row"] as! [[String: String]]
                
                for row in rows2
                {
                    let colData = row["ColData"] as! [[String: String]]
                    
                    let title = colData[0]
                    let value = colData[1] 
                    
                    let result = (title["value"]! , "", value["value"]!)
                    
                    profitAndLoss.append(result)
                    print("DEBUG: \(profitAndLoss)")
                }
            }
        }
        return nil
    }
}

protocol QuickBookMethod
{
    var queryParameters: [QBQueryParameterKeys: String] { get }
    var methodName: QBMethod { get }
    func formUrlPath(method: QuickBookMethod) -> String
}
