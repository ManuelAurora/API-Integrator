//
//  QuickBookRequestHandler.swift
//  CoreKPI
//
//  Created by Мануэль on 28.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import OAuthSwift

class QuickBookRequestHandler
{
    private var oauthswift: OAuth1Swift!
    var credential: OAuthSwiftCredential!
    var request: urlStringWithMethod!
    weak var manager: QuickBookDataManager!
    var isCreation: Bool
    let notificationCenter = NotificationCenter.default
    
    init(oauthswift: OAuth1Swift, request: urlStringWithMethod, manager: QuickBookDataManager, isCreation: Bool = false) {
        
        self.oauthswift = oauthswift
        self.request = request
        self.manager = manager
        self.isCreation = isCreation
    }
    
    func getData() {       
       //TODO: Remove credential parameter, and create dict which will contain companyId ["id": OauthCredential].
        //must fill this dict from CoreData entities.
        oauthswift.client.credential.oauthToken = credential.oauthToken
        oauthswift.client.credential.oauthTokenSecret = credential.oauthTokenSecret
        oauthswift.client.credential.oauthRefreshToken = credential.oauthRefreshToken
        
        _ = oauthswift.client.get(
            
            request.urlString, headers: ["Accept":"application/json"],
            success: { response in
                
                if let method = self.request.method {
                    _ = self.handle(response: response, method: method)
                }               
        },
            failure: { error in
                print(error)
        })
    }
    
    func handle(response: OAuthSwiftResponse, method: QuickBookMethod) -> ExternalKpiInfo? {
        
        //TODO:  This method NEED to be refined, due equivalent responses
        
        //guard let queryMethod = method else { print("DEBUG: Query method not found"); return nil }
        
        if let jsonDict = try? response.jsonObject(options: .allowFragments) as? [String: Any] {
            
            switch method.methodName
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
                                
                manager.balanceSheet.append(result)
                notificationCenter.post(name: .qBBalanceSheetRefreshed, object: nil)
                
                return kpiInfo
                
            case .query:
                //Invoices
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                if let queryResult = jsonDict?["QueryResponse"] as? [String: Any],
                    let invoiceList = queryResult["Invoice"] as? [[String: Any]]
                {
                    for invoice in invoiceList
                    {
                        let balance = invoice["Balance"] as! Float
                        let totalAmt = invoice["TotalAmt"] as! Float
                        let docNumber = invoice["DocNumber"] as! String
                        let customerName = (invoice["CustomerRef"] as! [String: Any])["name"] as! String
                        let metaData = invoice["MetaData"] as! [String: String]
                        let date = metaData["CreateTime"]!
                        
                        let overdueDateString = invoice["DueDate"] as! String
                        let overdueDate = dateFormatter.date(from: overdueDateString)! //Date in Moscow can be slightly different
                        let customer = (invoice["CustomerRef"] as! [String: Any])["name"] as! String
                        var resultInvoice = (leftValue: "", centralValue: "", rightValue: "")
                        
                        manager.invoices.append((leftValue: "\(date) \(docNumber)", centralValue: "\(customerName)", rightValue: "\(totalAmt)"))
                        
                        if balance > 0
                        {
                            resultInvoice.leftValue = "\(customer)"
                            resultInvoice.rightValue = "\(balance)"
                            manager.nonPaidInvoices.append(resultInvoice)
                            
                            if currentDate > overdueDate
                            {
                                resultInvoice.leftValue = "\(customer)"
                                manager.overdueCustomers.append(resultInvoice)
                            }
                        }
                        else
                        {
                            resultInvoice.leftValue = "Paid invoice"
                            resultInvoice.rightValue = "\(totalAmt)"
                            manager.paidInvoices.append(resultInvoice)
                        }
                    }
                }
                if manager.nonPaidInvoices.count > 0 && manager.nonPaidInvoices.count > 0
                {
                    let nonPaidPercent = (manager.nonPaidInvoices.count * 100) / manager.invoices.count
                    let paidPercent = (manager.paidInvoices.count * 100) / manager.invoices.count
                    manager.paidInvoicesPercent.append((leftValue: "Paid invoices percent", centralValue: "", rightValue: "\(paidPercent)%"))
                    manager.nonPaidInvoicesPercent.append((leftValue: "Non-paid invoices percent", centralValue: "", rightValue: "\(nonPaidPercent)%"))
                }
                
                let netIncome = manager.paidInvoices.reduce(Float(0), { (sum, item) in
                    sum + Float(item.rightValue)!
                })
                
                manager.netIncome.append((leftValue: "Net Income", centralValue: "", rightValue: "\(netIncome)"))
                
                var filteredOverdueArray = resultArray()
                
                for customer in manager.overdueCustomers
                {
                    if !filteredOverdueArray.contains(where: { (value) -> Bool in
                        return customer.leftValue == value.leftValue }) {
                        
                        let sum = manager.overdueCustomers.filter {
                            $0.leftValue == customer.leftValue
                            } .reduce(Float(0)) { (total, value) in
                                return total + Float(value.rightValue)!
                        }
                        
                        let refactoredCustomer = (leftValue: customer.leftValue , centralValue: "", rightValue: "\(sum)")
                        
                        filteredOverdueArray.append(refactoredCustomer)
                    }
                }
                
                manager.overdueCustomers = filteredOverdueArray
                notificationCenter.post(name: .qBInvoicesRefreshed, object: nil)
                
            case .profitLoss:
                
                let rowsDict   = jsonDict!["Rows"]   as! [String: Any]
                let rows       = rowsDict["Row"]     as! [[String: Any]]
                let header     = jsonDict!["Header"] as! [String: Any]
                let dateMacro  = header["DateMacro"] as! String
                
                for row in rows
                {
                    if let groupString = row["group"] as? String, groupString == "GrossProfit" || groupString == "Income"
                    {
                        let summary    = row["Summary"] as? [String: Any]
                        let colDataSum = summary?["ColData"]  as? [[String: String]]
                        let kpiTitle   = colDataSum?[0]["value"]
                        let value      = colDataSum?[1]["value"]
                        
                        switch groupString
                        {
                        case "GrossProfit":
                            switch dateMacro
                            {
                            case "this calendar year":    manager.incomeProfitKPI.profitYear    = value
                            case "this calendar quarter": manager.incomeProfitKPI.profitQuartal = value
                            case "this month":            manager.incomeProfitKPI.profitMonth   = value
                            default: break
                            }
                            
                        case "Income":
                            switch dateMacro
                            {
                            case "this calendar year":    manager.incomeProfitKPI.incomeYear    = value
                            case "this calendar quarter": manager.incomeProfitKPI.incomeQuartal = value
                            case "this month":            manager.incomeProfitKPI.incomeMonth   = value
                            default: break
                            }
                            
                        default: break
                        }
                    }                    
                }                
                
            case .accountList:
                let rows = jsonDict!["Rows"] as! [String: Any]
                let rows2 = rows["Row"] as! [[String: Any]]
                
                for row in rows2
                {
                    let colData = row["ColData"] as! [[String: String]]
                    let result = (colData[0]["value"]!, "", colData[4]["value"]!)
                    
                    manager.accountList.append(result)
                    print("DEBUG: \(result)")
                }
                
                notificationCenter.post(name: .qBAccountListRefreshed, object: nil)
                
            case .paidInvoicesByCustomers:
                let rows = jsonDict!["Rows"] as! [String: Any]
                let rows2 = rows["Row"] as! [[String: Any]]
                
                for row in rows2
                {
                    //let summary = row["Summary"] as! [String: Any]
                    if let colData = row["ColData"] as? [[String: Any]] {
                        
                        let customer = colData[0]["value"] as! String
                        let income = colData[3]["value"] as! String
                        
                        let result = (leftValue: customer, centralValue: "", rightValue: income)
                        
                        manager.paidInvoicesByCustomer.append(result)
                    }
                }
                
                notificationCenter.post(name: .qBPaidInvoicesByCustomersRefreshed, object: nil)
                
            case .paidExpenses:
                let rows = jsonDict!["Rows"] as! [String: Any]
                let rows2 = rows["Row"] as! [[String: Any]]
                
                for row in rows2
                {
                    if let colData = row["ColData"] as? [[String: String]]
                    {
                        
                        let title = colData[0]
                        let value = colData[1]
                        
                        let result = (title["value"]! , "", value["value"]!)
                        
                        manager.profitAndLoss.append(result)
                        print("DEBUG: \(manager.profitAndLoss)")
                    }
                }
                
                notificationCenter.post(name: .qBPaidInvoicesByCustomersRefreshed, object: nil)
            }
        }
        return nil
    }
}
