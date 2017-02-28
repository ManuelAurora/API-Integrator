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
    
    init(oauthswift: OAuth1Swift, request: urlStringWithMethod, manager: QuickBookDataManager) {
        
        self.oauthswift = oauthswift
        self.request = request
        self.manager = manager
    }
    
    func getData() {
        
        oauthswift.client.get(
            
            request.urlString, headers: ["Accept":"application/json"],
            success: { response in
                
                //let appDelegate = UIApplication.shared.delegate as! AppDelegate
               // let managedContext = appDelegate.persistentContainer.viewContext
                
                let kpiInfo = self.handle(response: response, method: self.request.method)
                ////
                ////                let entityDescription = NSEntityDescription.entity(forEntityName: "ExternalKPI", in: managedContext)
                ////                let extKPI = ExternalKPI(entity: entityDescription!, insertInto: managedContext)
                ////
                ////                let QBKpiEntity = NSEntityDescription.entity(forEntityName: "QuickbooksKPI", in: managedContext)
                ////                let qbKPI = QuickbooksKPI(entity: QBKpiEntity!, insertInto: managedContext)
                //
                //                qbKPI.kpiValue = kpiInfo?.kpiValue
                //                extKPI.kpiName = kpiInfo?.kpiName
                //                extKPI.serviceName = IntegratedServices.Quickbooks.rawValue
                //                qbKPI.oAuthToken = self.quickBookDataManager.serviceParameters[.oauthToken]!
                //                qbKPI.oAuthRefreshToken = self.quickBookDataManager.serviceParameters[.oauthRefreshToken]!
                //                extKPI.quickbooksKPI = qbKPI
                //
                //                do {
                //                    try managedContext.save()
                //                }
                //                catch let error {
                //                    print(error.localizedDescription)
                //                }
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
                
            case .accountList:
                let rows = jsonDict!["Rows"] as! [String: Any]
                let rows2 = rows["Row"] as! [[String: Any]]
                
                for row in rows2
                {
                    let colData = row["ColData"] as! [[String: String]]
                    let result = (colData[0]["value"], "", colData[4]["value"])
                    
                    print("DEBUG: \(result)")
                }
                
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
            }
        }
        return nil
    }
}
