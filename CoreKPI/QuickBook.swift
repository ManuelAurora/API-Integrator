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

typealias resultArray = [(leftValue: String, centralValue: String, rightValue: String)]
typealias urlStringWithMethod = (urlString: String, method: QuickBookMethod)

class QuickBookDataManager
{
    private let urlBase = "https://sandbox-quickbooks.api.intuit.com/v3/company/"
    var balanceSheet: resultArray = []
    var profitAndLoss: resultArray = []
    var accountList: resultArray  = []
    var paidInvoices: resultArray = []
    var nonPaidInvoices: resultArray = []
    var paidInvoicesByCustomer: resultArray = []
    var nonPaidInvoicesPercent: resultArray = []
    var paidInvoicesPercent: resultArray = []
    var invoices: resultArray = []
    var overdueCustomers: resultArray = []
    
    var queryMethod: QuickBookMethod?
    var companyID: String {
        set {
            return serviceParameters[.companyId] = companyID
        }
        get {
            return serviceParameters[.companyId]!
        }
    }
    
    var listOfRequests: [urlStringWithMethod] = []

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
    
    func formListOfRequests(from array: [(SettingName: String, value: Bool)]) {
        
        var kpiFilter =  [String: Bool]()
                
        for item in array
        {
            let kpi = QiuckBooksKPIs(rawValue: item.SettingName)!
            
            guard kpiFilter[item.SettingName] == nil else { return }
            
            switch kpi
            {
            case .NetIncome, .Invoices, .NonPaidInvoices, .OpenInvoicesByCustomers, .OverdueCustomers, .PaidInvoices:
                
                let queryParameters: [QBQueryParameterKeys: String] = [
                    .query: "SELECT * FROM Invoice"
                ]
                
                let queryInvoices = QBQuery(with: queryParameters)
                let queryPath = formUrlPath(method: queryInvoices)
                
                listOfRequests.append(urlStringWithMethod(urlString: queryPath, method: queryInvoices))
                kpiFilter[QiuckBooksKPIs.Invoices.rawValue] = true
                kpiFilter[QiuckBooksKPIs.NetIncome.rawValue] = true
                kpiFilter[QiuckBooksKPIs.NonPaidInvoices.rawValue] = true
                kpiFilter[QiuckBooksKPIs.OpenInvoicesByCustomers.rawValue] = true
                kpiFilter[QiuckBooksKPIs.OverdueCustomers.rawValue] = true
                kpiFilter[QiuckBooksKPIs.PaidInvoices.rawValue] = true
                
            case .Balance:
                let balanceQueryParameters: [QBQueryParameterKeys: String] = [
                    .dateMacro: QBPredifinedDateRange.thisMonth.rawValue
                ]
                
                let balanceSheet = QBBalanceSheet(with: balanceQueryParameters)
                let pathForBalance = formUrlPath(method: balanceSheet)
                
                listOfRequests.append(urlStringWithMethod(urlString: pathForBalance, method: balanceSheet))
                
            case .BalanceByBankAccounts:
                let accountListParameters: [QBQueryParameterKeys: String] = [
                    .dateMacro: QBPredifinedDateRange.thisMonth.rawValue
                ]
                
                let accountList = QBAccountList(with: accountListParameters)
                let pathForAccountList = formUrlPath(method: accountList)
                
                listOfRequests.append(urlStringWithMethod(urlString: pathForAccountList, method: accountList))
                
            case .IncomeProfitKPIs:
                let profitAndLossQueryParameters: [QBQueryParameterKeys: String] = [
                    .dateMacro: QBPredifinedDateRange.thisMonth.rawValue,
                    .summarizeBy: QBPredifinedSummarizeValues.days.rawValue
                ]
                
                let profitAndLoss = QBProfitAndLoss(with: profitAndLossQueryParameters)
                let pathForProfitAndLoss = formUrlPath(method: profitAndLoss)
                
                listOfRequests.append(urlStringWithMethod(urlString: pathForProfitAndLoss, method: profitAndLoss))
                
            case .PaidInvoicesByCustomers:
                let paidInvoicesParameters: [QBQueryParameterKeys: String] = [
                    .dateMacro: QBPredifinedDateRange.thisQuarter.rawValue,
                    .summarizeBy: QBPredifinedSummarizeValues.customers.rawValue
                ]
                
                let paidInvoices = QBPaidInvoicesByCustomers(with: paidInvoicesParameters)
                let paidInvoicesPath = formUrlPath(method: paidInvoices)
                
                listOfRequests.append(urlStringWithMethod(urlString: paidInvoicesPath, method: paidInvoices))
                
            case .PaidExpenses:
                let paidExpensesParameters: [QBQueryParameterKeys: String] = [
                    .dateMacro: QBPredifinedDateRange.thisQuarter.rawValue
                ]
                
                let paidExpenses = QBPaidExpenses(with: paidExpensesParameters)
                let paidExpencesPath = formUrlPath(method: paidExpenses)

                listOfRequests.append(urlStringWithMethod(urlString: paidExpencesPath, method: paidExpenses))
            }
        }
    }
    
    func fetchDataFromIntuit(_ oauthswift: OAuth1Swift) {
        
        for request in listOfRequests
        {
            let handler = QuickBookRequestHandler(oauthswift: oauthswift,
                                                  request: request,
                                                  manager: self)
            handler.getData()
        }
        
        listOfRequests.removeAll()
    }
}

protocol QuickBookMethod
{
    var queryParameters: [QBQueryParameterKeys: String] { get }
    var methodName: QBMethod { get }
    func formUrlPath(method: QuickBookMethod) -> String
}
