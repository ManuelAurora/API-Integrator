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
import OAuthSwiftAlamofire

typealias resultArray = [(leftValue: String, centralValue: String, rightValue: String)]
typealias urlStringWithMethod = (
    urlString: String,
    method: QuickBookMethod?, kpiName: QiuckBooksKPIs?
)

typealias success = () -> ()

class QuickBookDataManager
{    
    lazy var sessionManager: SessionManager =  {
        let sm = SessionManager()
        sm.adapter = self.oauthswift.requestAdapter
        return sm
    }()
    
    enum ResultArrayType {
        case netIncome
        case balance
        case accountList
        case paidInvoicesByCustomer
        case paidInvoicesPercent
        case overdueCustomers
        case nonPaidInvoicesPercent
        case invoices
        case expencesByVendorSummary
        case openInvoicesByCustomers
        case incomeProfitKPIs
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
    
    lazy var incomeProfitKPI: QBIncomeProfitKPI = {
        let kpi = QBIncomeProfitKPI()
        return kpi
    }()
    
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
    var credentialTempList: [OAuthSwiftCredential] = []
    
    var kpiFilter =  [String: Bool]()
    
    lazy var serviceParameters: [AuthenticationParameterKeys: String] = {
        let parameters: [AuthenticationParameterKeys: String] = [
            .callbackUrl: "CoreKPI:/oauth-callback/intuit",
            .consumerKey:    "qyprdLYMArOQwomSilhpS7v9Ge8kke",
            .consumerSecret: "ogPRVftZXLA1A03QyWNyJBax1qOOphuVJVP121np"
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
    
    func dataFor(kpi: QiuckBooksKPIs) -> resultArray {
        
        switch kpi
        {
        case .Balance: return balanceSheet
        case .BalanceByBankAccounts: return accountList
        //case .IncomeProfitKPIs: return incomeProfitKPI
        case .Invoices:                return invoices
        case .NetIncome:               return paidInvoices
        case .NonPaidInvoices:         return nonPaidInvoicesPercent
        case .OpenInvoicesByCustomers: return openInvoicesByCustomers
        case .OverdueCustomers:        return overdueCustomers
        case .PaidExpenses:            return expencesByVendorSummary
        case .PaidInvoices:            return paidInvoicesPercent
        case .PaidInvoicesByCustomers: return paidInvoicesByCustomer
        default: break
        }        
        return resultArray()
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
        let beginDate = Date().beginningOfMonth?.stringForQuickbooksQuery()
        let endDate = Date().endOfMonth?.stringForQuickbooksQuery()
        var queryParameters = [QBQueryParameterKeys: String]()
        
        if let begin = beginDate, let end = endDate
        {
            queryParameters[.query] = "SELECT * FROM Invoice WHERE MetaData.CreateTime >= '\(begin)' AND MetaData.CreateTime <= '\(end)'"
        }
        
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
                
            case .IncomeProfitKPIs:
                createNewEntityForArrayOf(type: .incomeProfitKPIs, urlString: request.urlString)
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
                    
                    let profitAndLossMonth = QBProfitAndLoss(in: .thisMonth)
                    let profitAndLossQuartal = QBProfitAndLoss(in: .thisQuarter)
                    let profitAndLossYear = QBProfitAndLoss(in: .thisYear)
                                        
                    let reqMonth = urlStringWithMethod(urlString: formUrlPath(method: profitAndLossMonth),
                                                  method: profitAndLossMonth,
                                                  kpiName: kpi)
                    
                    let reqQuartal = urlStringWithMethod(urlString: formUrlPath(method: profitAndLossQuartal),
                                                         method: profitAndLossQuartal,
                                                         kpiName: kpi)
                    
                    let reqYear = urlStringWithMethod(urlString: formUrlPath(method: profitAndLossYear),
                                                      method: profitAndLossYear,
                                                      kpiName: kpi)
                    
                    listOfRequests.append(contentsOf: [reqMonth, reqQuartal, reqYear])
                    kpiRequestsToSave.append(reqMonth)
                    
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
    
    private func updateOauthCredentialsFor(request: urlStringWithMethod) {
        
        let numbersInUrlString = request.urlString.components(separatedBy: CharacterSet.decimalDigits.inverted)
        
        let idArray = numbersInUrlString.filter {
            
            if $0.characters.count >= QuickbooksConstants.lenghtOfRealmId { return true }
            else { return false }
        }
        
        guard idArray.count > 0 else { return }
        
        let realmId = idArray[0]
        
        let fetchQuickbookKPI = NSFetchRequest<QuickbooksKPI>(entityName: "QuickbooksKPI")
        
        if let quickbooksKPI = try? managedContext.fetch(fetchQuickbookKPI), quickbooksKPI.count > 0
        {
            let filteredArray = quickbooksKPI.filter { $0.realmId == realmId }
            
            guard filteredArray.count > 0 else { return }
            
            let kpi = filteredArray[0]
            
            oauthswift.client.credential.oauthToken = kpi.oAuthToken!
            oauthswift.client.credential.oauthTokenSecret = kpi.oAuthTokenSecret!
            oauthswift.client.credential.oauthRefreshToken = kpi.oAuthRefreshToken!
        }
    }
    
    func fetchDataFromIntuit(isCreation: Bool) {
        
        clearAllData()
        
        for request in listOfRequests
        {
            updateOauthCredentialsFor(request: request)
            
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
        
        if let quickbooksKPI = try? managedContext.fetch(fetchQuickbookKPI), quickbooksKPI.count > 0,
            let companyId = serviceParameters[.companyId]
        {
            let filteredArray = quickbooksKPI.filter { $0.realmId == companyId }
            
            qbKPI = filteredArray[0]
        }
        
        extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
        
        switch type
        {
        case .nonPaidInvoicesPercent:
            extKPI.kpiName = QiuckBooksKPIs.NonPaidInvoices.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
            
        case .balance:
            extKPI.kpiName = QiuckBooksKPIs.Balance.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
            
        case .invoices:
            extKPI.kpiName = QiuckBooksKPIs.Invoices.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
            
        case .accountList:
            extKPI.kpiName = QiuckBooksKPIs.BalanceByBankAccounts.rawValue
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
        
        case .openInvoicesByCustomers:
            extKPI.kpiName = QiuckBooksKPIs.OpenInvoicesByCustomers.rawValue
            extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
            extKPI.quickbooksKPI = qbKPI
            extKPI.requestJsonString = urlString
            
        case .incomeProfitKPIs:
            extKPI.kpiName = QiuckBooksKPIs.IncomeProfitKPIs.rawValue
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
    
    //MARK: Authentication
    func doOAuthQuickbooks(_ success: @escaping success) {
        
        let callbackUrlString = serviceParameters[.callbackUrl]
        let infoFetch = NSFetchRequest<QuickbooksKPI>(entityName: "QuickbooksKPI")

        guard let callBackUrl = callbackUrlString else { print("DEBUG: Callback URL not found!"); return }
        
        oauthswift.client.credential.oauthToken = ""
        oauthswift.client.credential.oauthTokenSecret = ""
        oauthswift.client.credential.oauthRefreshToken = ""
               
        let _ = oauthswift.authorize(
            withCallbackURL: callBackUrl,
            success: { credential, response, parameters in
                do {
                    let quickbooksKPIInfo = try self.managedContext.fetch(infoFetch)
                    
                    if let currentCompanyId = self.serviceParameters[.companyId]
                    {
                        let filteredArray = quickbooksKPIInfo.filter { $0.realmId == currentCompanyId }
                        
                        if filteredArray.count > 0
                        {
                            let kpi = filteredArray[0]
                            kpi.oAuthToken = credential.oauthToken
                            kpi.oAuthTokenSecret = credential.oauthTokenSecret
                            kpi.oAuthRefreshToken = credential.oauthRefreshToken
                        }
                        else
                        {
                            let newQbKPI = QuickbooksKPI()
                            
                            newQbKPI.oAuthToken = credential.oauthToken
                            newQbKPI.oAuthRefreshToken = credential.oauthRefreshToken
                            newQbKPI.oAuthTokenSecret = credential.oauthTokenSecret
                            newQbKPI.realmId = currentCompanyId
                        }
                    }
                    
                    try self.managedContext.save()
                }
                catch {
                    print("DEBUG: CoreData error")
                }
                
                self.serviceParameters[.oauthToken] = credential.oauthToken
                self.serviceParameters[.oauthRefreshToken] = credential.oauthRefreshToken
                self.serviceParameters[.oauthTokenSecret] = credential.oauthTokenSecret
                
                success()
        }) { error in
            print(error.localizedDescription)
        }
    }
}




