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
import CoreData

typealias resultArray = [(leftValue: String, centralValue: String, rightValue: String)]
typealias urlStringWithMethod = (urlString: String, method: QuickBookMethod?)

class QuickBookDataManager
{
    enum ResultArrayType {
        case balance
        case profitAndLoss
        case accountList
        case nonPaidInvoices
        case paidInvoicesByCustomer
        case paidInvoicesPercent
        case overdueCustomers
        case nonPaidInvoicesPercent
        case invoices
    }
    
    private lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        return managedContext
    }()
    
    private let urlBase = "https://sandbox-quickbooks.api.intuit.com/v3/company/"
    
    lazy var oauthswift: OAuth1Swift = {
        let oauthswift = OAuth1Swift(
            consumerKey:    "qyprdLYMArOQwomSilhpS7v9Ge8kke",
            consumerSecret: "ogPRVftZXLA1A03QyWNyJBax1qOOphuVJVP121np",
            requestTokenUrl: "https://oauth.intuit.com/oauth/v1/get_request_token",
            authorizeUrl:    "https://appcenter.intuit.com/Connect/Begin",
            accessTokenUrl:  "https://oauth.intuit.com/oauth/v1/get_access_token"
        )
        return oauthswift
    }()
    
    var balanceSheet: resultArray = [] {
        didSet {
            guard balanceSheet.count > 0 else { return }
            //createNewEntityForArrayOf(type: .balance)
        }
    }
    
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
            
        case .Invoices:
            return invoices
            
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
    
    func clearAllData() {
        
        balanceSheet.removeAll()
        profitAndLoss.removeAll()
        accountList.removeAll()
        paidInvoices.removeAll()
        nonPaidInvoices.removeAll()
        paidInvoicesByCustomer.removeAll()
        nonPaidInvoicesPercent.removeAll()
        paidInvoicesPercent.removeAll()
        invoices.removeAll()
        overdueCustomers.removeAll()
    }
    
    func updateDataFromIntuit(_ oauthswift: OAuth1Swift) {
        
        clearAllData()
        
        for request in listOfRequests
        {
            let handler = QuickBookRequestHandler(oauthswift: oauthswift,
                                                  request: request,
                                                  manager: self)
            
            handler.getData()
        }
        
        listOfRequests.removeAll()
    }
    
    func fetchDataFromIntuit(_ oauthswift: OAuth1Swift) {
        
        for request in listOfRequests
        {
            let handler = QuickBookRequestHandler(oauthswift: oauthswift,
                                                  request: request,
                                                  manager: self,
                                                  isCreation: true)
            handler.getData()
        }
        
        listOfRequests.removeAll()
    }
    
    func createNewEntityForArrayOf(type: ResultArrayType, urlString: String) {
        
        let extKPI = ExternalKPI()
        var qbKPI: QuickbooksKPI!
        
        let fetchQuickbookKPI = NSFetchRequest<QuickbooksKPI>(entityName: "QuickbooksKPI")
        if let quickbooksKPI = try? managedContext.fetch(fetchQuickbookKPI), quickbooksKPI.count > 0
        {
            qbKPI = quickbooksKPI[0]
        }
        else
        {
            qbKPI = QuickbooksKPI()
            qbKPI.oAuthToken = serviceParameters[.oauthToken] ?? nil
            qbKPI.oAuthRefreshToken = serviceParameters[.oauthRefreshToken] ?? nil
            qbKPI.oAuthTokenSecret = serviceParameters[.oauthTokenSecret] ?? nil
        }
        
        switch type
        {
        case .balance:
            
            extKPI.kpiName = QiuckBooksKPIs.Balance.rawValue
            extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
            
        case .invoices:            
            
            extKPI.kpiName = QiuckBooksKPIs.Invoices.rawValue
            extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
            
        default: break
        }
        
        do {
            try managedContext.save()
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
}




