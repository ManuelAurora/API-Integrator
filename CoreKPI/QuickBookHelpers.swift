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
    case thisYear = "This Fiscal Year"
}

enum QBPredifinedSummarizeValues: String
{
    case days = "Days"
    case month = "Month"
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
    case consumerKey = "consumerKey"
    case consumerSecret = "consumerSecret"
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

struct QBIncomeProfitKPI
{
    var profitMonth: String!   { didSet { if profitMonth   != nil { checkValuesAreFilled() }}}
    var profitQuartal: String! { didSet { if profitQuartal != nil { checkValuesAreFilled() }}}
    var profitYear: String!    { didSet { if profitYear    != nil { checkValuesAreFilled() }}}
    var incomeMonth: String!   { didSet { if incomeMonth   != nil { checkValuesAreFilled() }}}
    var incomeQuartal: String! { didSet { if incomeQuartal != nil { checkValuesAreFilled() }}}
    var incomeYear: String!    { didSet { if incomeYear    != nil { checkValuesAreFilled() }}}
    
    //If values are filled - KPI ready for use
    func checkValuesAreFilled() {
        
        if  profitMonth   != nil &&
            profitQuartal != nil &&
            profitYear    != nil &&
            incomeMonth   != nil &&
            incomeQuartal != nil &&
            incomeYear    != nil {
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: .qbManagerRecievedData, object: nil)
        }        
    }
}

struct QBProfitAndLoss: QuickBookMethod
{
    internal var methodName: QBMethod
    
    internal var queryParameters: [QBQueryParameterKeys : String]
    
    internal func formUrlPath(method: QuickBookMethod) -> String {
        return queryParameters.stringFromHttpParameters()
    }
    
    init(in period: QBPredifinedDateRange) {
        
        let queryParameters: [QBQueryParameterKeys: String] = [
            .dateMacro: period.rawValue,
            .summarizeBy: QBPredifinedSummarizeValues.month.rawValue
        ]
        
        self.methodName = .profitLoss
        self.queryParameters = queryParameters
    }
    
    init(with queryParameters: [QBQueryParameterKeys: String]) {
        self.queryParameters = queryParameters
        self.methodName = .profitLoss
    }
}

enum QuickbooksConstants
{
    static let lenghtOfRealmId = 15
}

