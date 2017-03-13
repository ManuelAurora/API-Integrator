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
typealias urlStringWithMethod = (urlString: String, method: QuickBookMethod?, kpiName: QiuckBooksKPIs?)
typealias success = () -> ()

class QuickBookDataManager
{
    enum ResultArrayType {
        case netIncome
        case balance
        case profitAndLoss
        case accountList
        case nonPaidInvoices
        case paidInvoicesByCustomer
        case paidInvoicesPercent
        case overdueCustomers
        case nonPaidInvoicesPercent
        case invoices
        case expencesByVendorSummary
        case openInvoicesByCustomers
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
    
    var kpiRequestsToSave: [urlStringWithMethod] = [] //This Array stores values for saving new kpi's into CoreData
    
    var profitAndLoss: resultArray = []
    var accountList: resultArray  = []
    var paidInvoices: resultArray = []
    var netIncome: resultArray = []
    var nonPaidInvoices: resultArray = []
    var paidInvoicesByCustomer: resultArray = []
    var nonPaidInvoicesPercent: resultArray = []
    var paidInvoicesPercent: resultArray = []
    var invoices: resultArray = []
    var overdueCustomers: resultArray = []
    var expencesByVendorSummary: resultArray = []
    var openInvoicesByCustomers: resultArray = []
    
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
    
    var kpiFilter =  [String: Bool]()
    
    lazy var serviceParameters: [AuthenticationParameterKeys: String] = {
        let parameters: [AuthenticationParameterKeys: String] = [
            .companyId:   "123145773393399",
            .callbackUrl: "CoreKPI:/oauth-callback/intuit"            
        ]
        
        return parameters
    }()
    
    private func getInfoFor(kpi: QiuckBooksKPIs) -> resultArray {
        
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
    
    private func makeDate() {
        
        let startOfQuarter: Date
        let date = Date()
        let calendar = Calendar.current
    }
    
    private func formUrlPath(method: QuickBookMethod) -> String {
        
        let companyId = serviceParameters[AuthenticationParameterKeys.companyId]!
        let fullUrlPath = self.urlBase +
            companyId +
            method.methodName.rawValue + "?" +
            method.queryParameters.stringFromHttpParameters()

        return fullUrlPath
    }
    
    private var queryParameters: [QBQueryParameterKeys: String] {
        let queryParameters: [QBQueryParameterKeys: String] = [
            .query: "SELECT * FROM Invoice"
        ]
        
        return queryParameters
    }
    
    private var queryInvoices: QuickBookMethod {
        return QBQuery(with: queryParameters)
    }
    
    private var queryPath: String {
        return formUrlPath(method: queryInvoices)
    }
    
    private func appendQueryRequest() {
        
        kpiFilter[QiuckBooksKPIs.Invoices.rawValue] = true
        kpiFilter[QiuckBooksKPIs.NetIncome.rawValue] = true
        kpiFilter[QiuckBooksKPIs.NonPaidInvoices.rawValue] = true
        kpiFilter[QiuckBooksKPIs.OpenInvoicesByCustomers.rawValue] = true
        kpiFilter[QiuckBooksKPIs.OverdueCustomers.rawValue] = true
        kpiFilter[QiuckBooksKPIs.PaidInvoices.rawValue] = true
    }
    
    private func saveNewEntities() {
        
        for request in kpiRequestsToSave
        {
            switch request.kpiName!
            {
            case .Invoices:
                createNewEntityForArrayOf(type: .invoices, urlString: request.urlString)
                
            case .NetIncome:
                createNewEntityForArrayOf(type: .netIncome, urlString: request.urlString)
                
            case .PaidInvoices:
                createNewEntityForArrayOf(type: .paidInvoicesPercent, urlString: request.urlString)
                
            case .NonPaidInvoices:
                createNewEntityForArrayOf(type: .nonPaidInvoicesPercent, urlString: request.urlString)
                
            case .OpenInvoicesByCustomers:
                createNewEntityForArrayOf(type: .openInvoicesByCustomers, urlString: request.urlString)
                
            case .OverdueCustomers:
                createNewEntityForArrayOf(type: .overdueCustomers, urlString: request.urlString)
                
            case .PaidExpenses:
                createNewEntityForArrayOf(type: .expencesByVendorSummary, urlString: request.urlString)
                
            case .Balance:
                createNewEntityForArrayOf(type: .balance, urlString: request.urlString)
              
            case .BalanceByBankAccounts:
                createNewEntityForArrayOf(type: .accountList, urlString: request.urlString)
                
            case .PaidInvoicesByCustomers:
                createNewEntityForArrayOf(type: .paidInvoicesByCustomer, urlString: request.urlString)
                
            default:
                break
            }
        }
        
        kpiRequestsToSave.removeAll()
    }
    
    func formListOfRequests(from array: [(SettingName: String, value: Bool)]) {
        
        for item in array
        {
            let kpi = QiuckBooksKPIs(rawValue: item.SettingName)!
            
            if kpiFilter[item.SettingName] == nil
            {
                switch kpi
                {
                case .NetIncome, .Invoices, .NonPaidInvoices, .OpenInvoicesByCustomers, .OverdueCustomers, .PaidInvoices:
                    let req = urlStringWithMethod(urlString: queryPath, method: queryInvoices, kpiName: kpi)
                    
                    kpiRequestsToSave.append(req)
                    listOfRequests.append(req)
                    appendQueryRequest()
                    
                case .Balance:
                    let balanceQueryParameters: [QBQueryParameterKeys: String] = [
                        .dateMacro: QBPredifinedDateRange.thisMonth.rawValue
                    ]
                    
                    let balanceSheet = QBBalanceSheet(with: balanceQueryParameters)
                    let pathForBalance = formUrlPath(method: balanceSheet)
                    let req = urlStringWithMethod(urlString: pathForBalance, method: balanceSheet, kpiName: kpi)
                    
                    listOfRequests.append(req)
                    kpiRequestsToSave.append(req)
                    
                case .BalanceByBankAccounts:
                    let accountListParameters: [QBQueryParameterKeys: String] = [
                        .dateMacro: QBPredifinedDateRange.thisMonth.rawValue
                    ]
                    
                    let accountList = QBAccountList(with: accountListParameters)
                    let pathForAccountList = formUrlPath(method: accountList)
                    let req = urlStringWithMethod(urlString: pathForAccountList, method: accountList, kpiName: kpi)
                    
                    listOfRequests.append(req)
                    kpiRequestsToSave.append(req)
                    
                case .IncomeProfitKPIs:
                    let profitAndLossQueryParameters: [QBQueryParameterKeys: String] = [
                        .dateMacro: QBPredifinedDateRange.thisMonth.rawValue,
                        .summarizeBy: QBPredifinedSummarizeValues.days.rawValue
                    ]
                    
                    let profitAndLoss = QBProfitAndLoss(with: profitAndLossQueryParameters)
                    let pathForProfitAndLoss = formUrlPath(method: profitAndLoss)
                    let req = urlStringWithMethod(urlString: pathForProfitAndLoss, method: profitAndLoss, kpiName: kpi)
                    
                    listOfRequests.append(req)
                    kpiRequestsToSave.append(req)
                    
                case .PaidInvoicesByCustomers:
                    let paidInvoicesParameters: [QBQueryParameterKeys: String] = [
                        .dateMacro: QBPredifinedDateRange.thisQuarter.rawValue,
                        .summarizeBy: QBPredifinedSummarizeValues.customers.rawValue
                    ]
                    
                    let paidInvoices = QBPaidInvoicesByCustomers(with: paidInvoicesParameters)
                    let paidInvoicesPath = formUrlPath(method: paidInvoices)
                    let req = urlStringWithMethod(urlString: paidInvoicesPath, method: paidInvoices, kpiName: kpi)
                    
                    kpiRequestsToSave.append(req)
                    listOfRequests.append(req)
                    
                case .PaidExpenses:
                    let paidExpensesParameters: [QBQueryParameterKeys: String] = [
                        .dateMacro: QBPredifinedDateRange.thisQuarter.rawValue
                    ]
                    
                    let paidExpenses = QBPaidExpenses(with: paidExpensesParameters)
                    let paidExpencesPath = formUrlPath(method: paidExpenses)
                    let req = urlStringWithMethod(urlString: paidExpencesPath, method: paidExpenses, kpiName: kpi)
                    
                    listOfRequests.append(req)
                    kpiRequestsToSave.append(req)
                }
            }
            else
            {
                kpiRequestsToSave.append(urlStringWithMethod(urlString: queryPath, method: queryInvoices, kpiName: kpi))
            }
        }
    }
    
    private func clearAllData() {
        
        netIncome.removeAll()
        kpiFilter.removeAll()
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
    
    func fetchDataFromIntuit(isCreation: Bool) {
        
        clearAllData()
        
        for request in listOfRequests
        {
            let handler = QuickBookRequestHandler(oauthswift: oauthswift,
                                                  request: request,
                                                  manager: self,
                                                  isCreation: isCreation)            
            
            handler.getData()
        }
        
        if isCreation { saveNewEntities() }
        listOfRequests.removeAll()
    }
    
    private func createNewEntityForArrayOf(type: ResultArrayType, urlString: String) {
        
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
        case .nonPaidInvoicesPercent:
            extKPI.kpiName = QiuckBooksKPIs.NonPaidInvoices.rawValue
            extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
            
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
            
        case .accountList:
            extKPI.kpiName = QiuckBooksKPIs.BalanceByBankAccounts.rawValue
            extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
            
        case .profitAndLoss:
            extKPI.kpiName = QiuckBooksKPIs.IncomeProfitKPIs.rawValue
            extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
            
        case .overdueCustomers:
            extKPI.kpiName = QiuckBooksKPIs.OverdueCustomers.rawValue
            extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
            
        case .expencesByVendorSummary:
            extKPI.kpiName = QiuckBooksKPIs.PaidExpenses.rawValue
            extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
            
        case .paidInvoicesByCustomer:
            extKPI.kpiName = QiuckBooksKPIs.PaidInvoicesByCustomers.rawValue
            extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
            
        case .netIncome:
            extKPI.kpiName = QiuckBooksKPIs.NetIncome.rawValue
            extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
            
        case .paidInvoicesPercent:
            extKPI.kpiName = QiuckBooksKPIs.PaidInvoices.rawValue
            extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
            
        case .nonPaidInvoices:
            extKPI.kpiName = QiuckBooksKPIs.NonPaidInvoices.rawValue
            extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
        
        case .openInvoicesByCustomers:
            extKPI.kpiName = QiuckBooksKPIs.OpenInvoicesByCustomers.rawValue
            extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString            
        }
        
        do {
            try managedContext.save()
           
            NotificationCenter.default.post(Notification(name: .newExternalKPIadded))
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func doOAuthQuickbooks(_ success: @escaping success) {
    
        let infoFetch = NSFetchRequest<QuickbooksKPI>(entityName: "QuickbooksKPI")
        
        do {
            let quickbooksKPIInfo = try managedContext.fetch(infoFetch)
            
            if quickbooksKPIInfo.count > 0, let token = quickbooksKPIInfo[0].oAuthToken,
                let tokenSecret = quickbooksKPIInfo[0].oAuthTokenSecret
            {
                serviceParameters[.oauthToken] = token
                serviceParameters[.oauthTokenSecret] = tokenSecret
                oauthswift.client.credential.oauthToken = token
                oauthswift.client.credential.oauthTokenSecret = tokenSecret
                success()
            }
            else
            {                
                let callbackUrlString = serviceParameters[.callbackUrl]
                
                guard let callBackUrl = callbackUrlString else { print("DEBUG: Callback URL not found!"); return }
                
                let _ = oauthswift.authorize(
                    withCallbackURL: callBackUrl,
                    success: { credential, response, parameters in
                        self.serviceParameters[.oauthToken] = credential.oauthToken
                        self.serviceParameters[.oauthRefreshToken] = credential.oauthRefreshToken
                        self.serviceParameters[.oauthTokenSecret] = credential.oauthTokenSecret
                        success()
                }) { error in
                    print(error.localizedDescription)
                }
            }
        }
        catch {
            print("DEBUG: CoreData error")
        }
    }
}




