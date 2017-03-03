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
    var oauthswift: OAuth1Swift!
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
                
                if isCreation {
                    manager.createNewEntityForArrayOf(type: .balance, urlString: request.urlString)
                }
                
                notificationCenter.post(name: .qBBalanceSheetRefreshed, object: nil)
                
                return kpiInfo
                
            case .query:
                //Invoices
                let queryResult = jsonDict!["QueryResponse"] as! [String: Any]
                let invoceList = queryResult["Invoice"] as! [[String: Any]]
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                print(invoceList)
                
                for invoice in invoceList
                {
                    print(invoice)
                    let balance = invoice["Balance"] as! Float
                    let totalAmt = invoice["TotalAmt"] as! Float
                    var resultInvoice = (leftValue: "", centralValue: "", rightValue: "")
                    
                    manager.invoices.append((leftValue: "Invoice", centralValue: "", rightValue: "\(totalAmt)"))
                    
                    if totalAmt - balance > 0
                    {
                        resultInvoice.leftValue = "Non-paid invoice"
                        resultInvoice.rightValue = "\(totalAmt)"
                        
                        manager.nonPaidInvoices.append(resultInvoice)
                        
                        let overdueDateString = invoice["DueDate"] as! String
                        let overdueDate = dateFormatter.date(from: overdueDateString)! //Date in Moscow can be slightly different
                        
                        if currentDate > overdueDate
                        {
                            let overdueCustomer = (invoice["CustomerRef"] as! [String: Any])["name"] as! String
                            resultInvoice.leftValue = "\(overdueCustomer)"
                            manager.overdueCustomers.append(resultInvoice)
                        }
                    }
                    else
                    {
                        resultInvoice.leftValue = "Paid invoice"
                        resultInvoice.rightValue = "\(totalAmt)"
                        manager.paidInvoices.append(resultInvoice)
                    }
                    
                    print(invoice["Balance"] as! Float)
                    print(invoice["TotalAmt"] as! Float)
                }
                
                let nonPaidPercent = (manager.nonPaidInvoices.count * 100) / manager.invoices.count
                let paidPercent = (manager.paidInvoices.count * 100) / manager.invoices.count
                
                manager.paidInvoicesPercent.append((leftValue: "Paid invoices percent", centralValue: "", rightValue: "\(paidPercent)%"))
                manager.nonPaidInvoicesPercent.append((leftValue: "Non-paid invoices percent", centralValue: "", rightValue: "\(nonPaidPercent)%"))
                
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
                
                //TODO: Refactor for making different entity for every KPI
                if isCreation
                {
                    switch request!.kpiName!
                    {
                    case .Invoices:
                        manager.createNewEntityForArrayOf(type: .invoices, urlString: request.urlString)
                        
                    case .NetIncome:
                        manager.createNewEntityForArrayOf(type: .netIncome, urlString: request.urlString)
                        
                    case .PaidInvoices:
                        manager.createNewEntityForArrayOf(type: .paidInvoicesPercent, urlString: request.urlString)
                        
                    case .NonPaidInvoices:
                        manager.createNewEntityForArrayOf(type: .nonPaidInvoices, urlString: request.urlString)
                        
                    default:
                        break
                    }
                }
                
                notificationCenter.post(name: .qBInvoicesRefreshed, object: nil)
                
            case .profitLoss:
                let rows = jsonDict!["Rows"] as! [String: Any]
                let rows2 = rows["Row"] as! [[String: Any]]
                
                for row in rows2
                {
                    let summary = row["Summary"] as! [String: Any]
                    let colDataSum = summary["ColData"] as! [[String: Any]]
                    
                    let kpiTitle = colDataSum[0] as! [String: String]
                    
                    if kpiTitle["value"] == "Net Income" // GROSS PROFIT?
                    {
                        for item in colDataSum where (item["value"] as! String) != "Net Income"
                        {
                            let result = ("Profit", "", item["value"] as! String)
                            
                            manager.profitAndLoss.append(result)
                            print("DEBUG: \(manager.profitAndLoss)")
                        }
                    }
                }
                
                if isCreation {
                    manager.createNewEntityForArrayOf(type: .profitAndLoss, urlString: request.urlString)
                }
                
                notificationCenter.post(name: .qBProfitAndLossRefreshed, object: nil)
                
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
                
                if isCreation {
                    manager.createNewEntityForArrayOf(type: .accountList, urlString: request.urlString)
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
                
                if isCreation {
                    manager.createNewEntityForArrayOf(type: .paidInvoicesByCustomer, urlString: request.urlString)
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
                
                if isCreation {
                    manager.createNewEntityForArrayOf(type: .expencesByVendorSummary, urlString: request.urlString)
                }
                
                notificationCenter.post(name: .qBPaidInvoicesByCustomersRefreshed, object: nil)
            }
        }
        return nil
    }
}
