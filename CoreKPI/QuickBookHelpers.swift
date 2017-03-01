//
//  QuickBookHelpers.swift
//  CoreKPI
//
//  Created by Мануэль on 28.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

protocol QuickBookMethod
{
    var queryParameters: [QBQueryParameterKeys: String] { get }
    var methodName: QBMethod { get }
    func formUrlPath(method: QuickBookMethod) -> String
}

enum QBPredifinedDateRange: String
{
    case today = "Today"
    case yesterday = "Yesterday"
    case thisMonth = "This Month"
    case thisQuarter = "This Fiscal Quarter"
}

enum QBPredifinedSummarizeValues: String
{
    case days = "Days"
    case customers = "Customers"
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
    case oauthTokenSecret = "oauthTokenSecret" 
}

enum QBMethod: String
{
    case balanceSheet   = "/reports/BalanceSheet"
    case profitLoss     = "/reports/ProfitAndLoss"
    case paidExpenses = "/reports/VendorExpenses"
    case accountList    = "/reports/AccountList"
    case query          = "/query"
    case paidInvoicesByCustomers = "/reports/CustomerIncome"
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

struct QBPaidInvoicesByCustomers: QuickBookMethod
{
    internal var methodName: QBMethod
    
    internal var queryParameters: [QBQueryParameterKeys : String]
    
    internal func formUrlPath(method: QuickBookMethod) -> String {
        return queryParameters.stringFromHttpParameters()
    }
    
    init(with queryParameters: [QBQueryParameterKeys: String]) {
        self.queryParameters = queryParameters
        self.methodName = QBMethod.paidInvoicesByCustomers
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

struct QBPaidExpenses: QuickBookMethod
{
    internal var methodName: QBMethod
    
    internal var queryParameters: [QBQueryParameterKeys : String]
    
    internal func formUrlPath(method: QuickBookMethod) -> String {
        return queryParameters.stringFromHttpParameters()
    }
    
    init(with queryParameters: [QBQueryParameterKeys: String]) {
        self.queryParameters = queryParameters
        self.methodName = QBMethod.paidExpenses
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
