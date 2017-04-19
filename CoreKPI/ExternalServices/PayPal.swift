//
//  PayPal.swift
//  CoreKPI
//
//  Created by Семен on 28.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import Alamofire
import AEXML

typealias payPalData = (payer: String, netAmount: String, amount: String, date: String)

class PayPal: ExternalRequest {
    
    var apiUsername = ""
    var apiPassword = ""
    var apiSignature = ""
    let appID = "APP-80W284485P519543T"
    let payPalUri = "https://api-3t.sandbox.paypal.com/2.0/"
    
    init(apiUsername: String, apiPassword: String, apiSignature: String) {
        self.apiUsername = apiUsername
        self.apiPassword = apiPassword
        self.apiSignature = apiSignature
        super.init()
    }
    
    //MARK: - GetAccountInfo for checkig input API credentials
    func getAccountInfo(success: @escaping () -> (), failure: @escaping failure) {
        let soapRequest = createXMLRequest(method: "GetPalDetails", subject: (nil, [:]), requestParams: [])
        
        request(getMutableRequest(soapRequest))
            .responseString { response in
                if let xmlString = response.result.value {
                    do {
                        let xmlDoc = try AEXMLDocument(xml: xmlString)
                        if xmlDoc.root["SOAP-ENV:Body"]["GetPalDetailsResponse"]["Ack"].value == "Success" {
                            success()
                        } else {
                            failure("Authorisation error")
                        }
                    } catch {
                        print("\(error)")
                    }
                } else {
                    print("error fetching XML")
                }
        }
    }
    
    //MARK: - GetBalance
    func getBalance(success: @escaping (_ balance: String) -> (), failure: @escaping failure)  {
        
        let soapRequest = createXMLRequest(method: "GetBalance", subject: (nil, [:]), requestParams: [])
        
        request(getMutableRequest(soapRequest))
            .responseString { response in
                if let xmlString = response.result.value {
                    do {
                        let xmlDoc = try AEXMLDocument(xml: xmlString)
                        if let balance = xmlDoc.root["SOAP-ENV:Body"]["GetBalanceResponse"]["Balance"].value {
                            success(balance)
                        } else {
                            failure("Parsing balance error")
                        }
                    } catch {
                        print("\(error)")
                    }
                } else {
                    print("error fetching XML")
                }
        }
    }
    
    //MARK:- Get net sales/total sales
    func getSales(success: @escaping (_ sales: [payPalData]) -> (), failure: @escaping failure) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("StartDate", ["xs:type":"dateTime"], getDate(mounthsAgo: 1)), ("TransactionClass", ["xs:type":"ePaymentTransactionClassCodeType"], "Received")]
        let soapRequest = createXMLRequest(method: "TransactionSearch", subject: (nil, [:]), requestParams: params)
        request(getMutableRequest(soapRequest))
            .responseString { response in
                
                var dataArray: [payPalData] = []
                
                if let xmlString = response.result.value {
                    do {
                        let xmlDoc = try AEXMLDocument(xml: xmlString)
                        let transactions = xmlDoc.root["SOAP-ENV:Body"]["TransactionSearchResponse"].children
                        for transaction in transactions {
                            if transaction.name == "PaymentTransactions" {
                                dataArray.append((transaction["PayerDisplayName"].value!, transaction["NetAmount"].value!, transaction["GrossAmount"].value!, transaction["Timestamp"].value!))
                            }
                        }
                        success(dataArray)
                    } catch {
                        print("\(error)")
                    }
                } else {
                    print("error fetching XML")
                }
        }
    }
    
    //MARK: - Get KPIs
    func getKPIS(success: @escaping (_ kpis: [(kpiName: String, value: String, percent: Int)]) -> ()) {
        
        var curentData: (netSales: Double, fees: Double, shippingCost: Double, refunds: Double, incomingRefunds: Double, pending: Double, expenses: Double)!
        var lastPeriodData: (netSales: Double, fees: Double, shippingCost: Double, refunds: Double, incomingRefunds: Double, pending: Double, expenses: Double)!
        
        getCurentKPIs(success: {kpiData in
            curentData = kpiData
            if let kpiData = self.createDataForResponse(curentData: curentData, lastPeriodData: lastPeriodData) {
                success(kpiData)
            }
        })
        
        getLastPeriodKPIs(success: {kpiData in
            lastPeriodData = kpiData
            if let kpiData = self.createDataForResponse(curentData: curentData, lastPeriodData: lastPeriodData) {
                success(kpiData)
            }
        })
    }
    
    private func createDataForResponse(curentData: (netSales: Double, fees: Double, shippingCost: Double, refunds: Double, incomingRefunds: Double, pending: Double, expenses: Double)?, lastPeriodData: (netSales: Double, fees: Double, shippingCost: Double, refunds: Double, incomingRefunds: Double, pending: Double, expenses: Double)?) -> [(kpiName: String, value: String, percent: Int)]? {
        
        var kpis: [(kpiName: String, value: String, percent: Int)] = []
        
        if curentData != nil && lastPeriodData != nil {
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 3
                        
            var salesValue = 0
            var feesValue = 0
            var refundsValue = 0
            var incomingValue = 0
            var expensesValue = 0
            
            if curentData!.netSales > 0
            {
                salesValue = Int((lastPeriodData?.netSales)!/((curentData?.netSales)!/100))
            }
            
            if curentData!.fees > 0
            {
                feesValue = Int((lastPeriodData?.fees)!/((curentData?.fees)!/100))
            }
            
            if curentData!.refunds > 0
            {
                refundsValue = Int((lastPeriodData?.refunds)!/((curentData?.refunds)!/100))
            }
            
            if curentData!.incomingRefunds > 0
            {
                incomingValue = Int((lastPeriodData?.incomingRefunds)!/((curentData?.incomingRefunds)!/100))
            }
            
            if curentData!.expenses > 0
            {
                expensesValue = Int((lastPeriodData?.expenses)!/((curentData?.expenses)!/100))
            }            
            
            kpis.append(("Net sales", numberFormatter.string(for: curentData?.netSales)!, salesValue ))
            kpis.append(("Fees", numberFormatter.string(for: curentData?.fees)!, feesValue))
            kpis.append(("Refunds", numberFormatter.string(for: curentData?.refunds)!, refundsValue))
            kpis.append(("Incoming refunds", numberFormatter.string(for: curentData?.incomingRefunds)!, incomingValue))
            kpis.append(("Expenses", numberFormatter.string(for: curentData?.expenses)!, expensesValue))
            
            return kpis
        } else {
            return nil
        }
    }
    
    private func getCurentKPIs(success: @escaping (_ kpisData: (netSales: Double, fees: Double, shippingCost: Double, refunds: Double, incomingRefunds: Double, pending: Double, expenses: Double)) -> ()) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("StartDate", ["xs:type":"dateTime"], getDate(mounthsAgo: 1))]
        
        getTransactionsXML(params: params, success: {kpisData in
            success(kpisData)
        })
        
    }
    
    private func getLastPeriodKPIs(success: @escaping (_ kpisData: (netSales: Double, fees: Double, shippingCost: Double, refunds: Double, incomingRefunds: Double, pending: Double, expenses: Double)) -> ()) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("StartDate", ["xs:type":"dateTime"], getDate(mounthsAgo: 2)), ("EndDate", ["xs:type":"dateTime"], getDate(mounthsAgo: 1))]
        
        getTransactionsXML(params: params, success: {kpisData in
            success(kpisData)
        })
        
    }
    
    private func getTransactionsXML(params: [(field: String, description: [String:String], value: String)], success: @escaping (_ kpisData: (netSales: Double, fees: Double, shippingCost: Double, refunds: Double, incomingRefunds: Double, pending: Double, expenses: Double)) -> ()) {
        
        let soapRequest = createXMLRequest(method: "TransactionSearch", subject: (nil, [:]), requestParams: params)
        request(getMutableRequest(soapRequest))
            .responseString { response in
                
                var netSales = 0.0
                var fees = 0.0
                //var shippingCost = 0.0
                var refunds = 0.0
                var incomingRefunds = 0.0
                //var pending = 0.0
                var expenses = 0.0
                
                
                if let xmlString = response.result.value {
                    do {
                        let xmlDoc = try AEXMLDocument(xml: xmlString)
                        
                        netSales = self.parseNetSales(xml: xmlDoc)
                        fees = self.parseFees(xml: xmlDoc)
                        
                        refunds = self.parseRefunds(xml: xmlDoc)
                        incomingRefunds = self.parseIncomingRefunds(xml: xmlDoc)
                        
                        
                        expenses = self.parseExpenses(xml: xmlDoc)
                        
                        success((netSales, fees, /*shippingCost*/0.0, refunds, incomingRefunds, /*pending*/0.0, expenses))
                    } catch {
                        print("\(error)")
                    }
                } else {
                    print("error fetching XML")
                }
        }
    }
    
    private func parseNetSales(xml: AEXMLDocument) -> Double {
        let transactions = xml.root["SOAP-ENV:Body"]["TransactionSearchResponse"].children
        var netSales = 0.0
        for transaction in transactions {
            if transaction.name == "PaymentTransactions" {
                if transaction["Type"].value! == "Payment" {
                    let sale = Double(transaction["NetAmount"].value!)!
                    netSales += sale > 0 ? sale : 0
                }
            }
        }
        return netSales
    }
    
    private func parseFees(xml: AEXMLDocument) -> Double {
        let transactions = xml.root["SOAP-ENV:Body"]["TransactionSearchResponse"].children
        var fees = 0.0
        for transaction in transactions {
            if transaction.name == "PaymentTransactions" {
                if transaction["Type"].value! == "Payment" {
                    print(transaction["FeeAmount"].value!)
                    fees += Double(transaction["FeeAmount"].value!)!
                }
            }
        }
        return -fees
    }
    
    private func parseRefunds(xml: AEXMLDocument) -> Double {
        let transactions = xml.root["SOAP-ENV:Body"]["TransactionSearchResponse"].children
        var refunds = 0.0
        for transaction in transactions {
            if transaction.name == "PaymentTransactions" {
                if transaction["Type"].value! == "Refund" {
                    let refund = Double(transaction["GrossAmount"].value!)!
                    refunds += refund < 0 ? refund : 0
                }
            }
        }
        return -refunds
    }
    
    private func parseIncomingRefunds(xml: AEXMLDocument) -> Double {
        let transactions = xml.root["SOAP-ENV:Body"]["TransactionSearchResponse"].children
        var refunds = 0.0
        for transaction in transactions {
            if transaction.name == "PaymentTransactions" {
                if transaction["Type"].value! == "Refund" {
                    let refund = Double(transaction["GrossAmount"].value!)!
                    refunds += refund > 0 ? refund : 0
                }
            }
        }
        return refunds
    }

    private func parseExpenses(xml: AEXMLDocument) -> Double {
        let transactions = xml.root["SOAP-ENV:Body"]["TransactionSearchResponse"].children
        var expenses = 0.0
        for transaction in transactions {
            if transaction.name == "PaymentTransactions" {
                if transaction["Type"].value! == "Payment" {
                    let expense = Double(transaction["NetAmount"].value!)!
                    expenses += expense < 0 ? expense : 0
                }
            }
        }
        return -expenses
    }

    
    //MARK: - Get Average revenue sale
    func getAverageRevenue(success: @escaping (_ revenue: String) -> (), failure: @escaping failure) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("StartDate", ["xs:type":"dateTime"], getDate(mounthsAgo: 1)), ("TransactionClass", ["xs:type":"ePaymentTransactionClassCodeType"], "Received")]
        let soapRequest = createXMLRequest(method: "TransactionSearch", subject: (nil, [:]), requestParams: params)
        request(getMutableRequest(soapRequest))
            .responseString { response in
                
                var revenue = 0.0
                var paymentsCount = 0.0
                
                if let xmlString = response.result.value {
                    do {
                        let xmlDoc = try AEXMLDocument(xml: xmlString)
                        let transactions = xmlDoc.root["SOAP-ENV:Body"]["TransactionSearchResponse"].children
                        for transaction in transactions {
                            if transaction.name == "PaymentTransactions" {
                                paymentsCount += 1
                                revenue += Double(transaction["NetAmount"].value!)!
                            }
                        }
                        let averageRevenue = revenue/paymentsCount
                        let numberFormatter = NumberFormatter()
                        numberFormatter.numberStyle = .decimal
                        numberFormatter.maximumFractionDigits = 3
                        let numberString = numberFormatter.string(for: averageRevenue)
                        success("$" + numberString!)
                    } catch {
                        print("\(error)")
                    }
                } else {
                    print("error fetching XML")
                }
        }
    }
    
    //MARK: - Get Average revenue sale by period
    func getAverageRevenueSaleByPeriod(success: @escaping ([(revenue: String, period: String, total: Int)]) -> (), failure: @escaping failure) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("StartDate", ["xs:type":"dateTime"], getDate(mounthsAgo: 1)), ("TransactionClass", ["xs:type":"ePaymentTransactionClassCodeType"], "Received")]
        let soapRequest = createXMLRequest(method: "TransactionSearch", subject: (nil, [:]), requestParams: params)
        request(getMutableRequest(soapRequest))
            .responseString { response in
                
                var transactionsArray: [(amount: Double, date: Date)] = []
                var revenuesArray: [(revenue: String, period: String, total: Int)] = []
                
                if let xmlString = response.result.value {
                    do {
                        let xmlDoc = try AEXMLDocument(xml: xmlString)
                        let transactions = xmlDoc.root["SOAP-ENV:Body"]["TransactionSearchResponse"].children
                        for transaction in transactions {
                            if transaction.name == "PaymentTransactions" {
                                let netAmount = Double(transaction["NetAmount"].value!)!
                                let dateString = transaction["Timestamp"].value!
                                //let timeZone = transaction["Timezone"].value!
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                                let date = dateFormatter.date(from: dateString)
                                
                                let calendar = Calendar.current
                                var components = calendar.dateComponents([.month, .year, .day], from: date!)
                                //components.timeZone = TimeZone(abbreviation: timeZone)
                                components.hour = 0
                                components.minute = 0
                                let newDate = calendar.date(from: components)
                                
                                transactionsArray.append((netAmount,newDate!))
                            }
                        }
                        
                        var dateArray: [Date] = []
                        
                        for transaction in transactionsArray {
                            
                            if dateArray.count == 0 {
                                dateArray.append(transaction.date)
                            } else {
                                var isNewDate = true
                                for i in 0..<dateArray.count {
                                    if dateArray[i] == transaction.date {
                                        isNewDate = false
                                    }
                                }
                                if isNewDate {
                                    dateArray.append(transaction.date)
                                }
                            }
                        }
                        
                        for date in dateArray {
                            let transactionsGroup = transactionsArray.filter{$0.date == date}
                            
                            var amountSum = 0.0
                            let total = transactionsGroup.count
                            
                            for transaction in transactionsGroup {
                                amountSum += transaction.amount
                            }
                            
                            let revenue = amountSum/Double(total)
                            
                            let numberFormatter = NumberFormatter()
                            numberFormatter.numberStyle = .decimal
                            numberFormatter.maximumFractionDigits = 3
                            let numberString = numberFormatter.string(for: revenue)
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            
                            let dateString = dateFormatter.string(from: date) == dateFormatter.string(from: Date()) ? "Today" : dateFormatter.string(from: date)
                            
                            revenuesArray.append((numberString!, dateString, total))
                        }
                        success(revenuesArray)
                    } catch {
                        print("\(error)")
                    }
                } else {
                    print("error fetching XML")
                }
        }
    }
    
    //MARK: - Get top countries by sales
    func getTopCountriesBySales(success: @escaping (_ topCountries: [(country: String, sale: Int, total: Int)]) -> (), failure: @escaping failure) {
        getTransactionIDs(success: {transactionsIDs in
            
            var countries: [String] = []
            var topCountries: [(country: String, sale: Int, total: Int)] = []
            
            for id in transactionsIDs {
                self.getTransactionCountry(transactionsID: id, success: { country in
                    countries.append(country)
                    if countries.count == transactionsIDs.count {
                        for country in countries {
                            let total = countries.count
                            
                            if topCountries.count == 0 {
                                topCountries.append((country, 1, total))
                            } else {
                                var isNewProduct = true
                                for i in 0..<topCountries.count {
                                    if topCountries[i].country == country {
                                        let size = topCountries[i].sale
                                        topCountries[i] = (country, size + 1, total)
                                        isNewProduct = false
                                    }
                                }
                                if isNewProduct {
                                    topCountries.append((country, 1, total))
                                }
                            }
                        }
                        topCountries.sort{$0.sale>$1.sale}
                        success(topCountries)
                    }
                }, failure: {error in
                    print(error)
                })
            }
        }, failure: {error in
            print(error)
        })

    }
    
    //MARK: - Get top product
    func getTopProduct(success: @escaping (_ topProducts: [(product: String, size: Int, total: Int)]) -> (), failure: @escaping failure) {
        getTransactionIDs(success: {transactionsIDs in
            
            var products: [String] = []
            var topProducts: [(product: String, size: Int, total: Int)] = []
            
            for id in transactionsIDs {
                self.getTransactionProduct(transactionsID: id, success: { product in
                    products.append(product)
                    if products.count == transactionsIDs.count {
                        for product in products {
                            let total = products.count
                            
                            if topProducts.count == 0 {
                                topProducts.append((product, 1, total))
                            } else {
                                var isNewProduct = true
                                for i in 0..<topProducts.count {
                                    if topProducts[i].product == product {
                                        let size = topProducts[i].size
                                        topProducts[i] = (product, size + 1, total)
                                        isNewProduct = false
                                    }
                                }
                                if isNewProduct {
                                    topProducts.append((product, 1, total))
                                }
                            }
                        }
                        topProducts.sort(by: { (first, second) -> Bool in
                            return first.size > second.size
                        })
                        success(topProducts)
                    }
                }, failure: {error in
                    print(error)
                })
            }
        }, failure: {error in
            print(error)
        })
    }
    
    //MARK: private helper methods
    private func getTransactionIDs(success: @escaping (_ transactionsID: [String]) -> (), failure: @escaping failure) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("StartDate", ["xs:type":"dateTime"], getDate(mounthsAgo: 1)), ("TransactionClass", ["xs:type":"ePaymentTransactionClassCodeType"], "Received")]
        let soapRequest = createXMLRequest(method: "TransactionSearch", subject: (nil, [:]), requestParams: params)
        request(getMutableRequest(soapRequest))
            .responseString { response in
                
                var transactionsID: [String] = []
                
                if let xmlString = response.result.value {
                    do {
                        let xmlDoc = try AEXMLDocument(xml: xmlString)
                        let transactions = xmlDoc.root["SOAP-ENV:Body"]["TransactionSearchResponse"].children
                        for transaction in transactions {
                            if transaction.name == "PaymentTransactions" {
                                if let transactionID = transaction["TransactionID"].value {
                                    transactionsID.append(transactionID)
                                }
                            }
                        }
                        success(transactionsID)
                    } catch {
                        print("\(error)")
                    }
                } else {
                    print("error fetching XML")
                }
        }
    }
    
    private func getTransactionCountry(transactionsID: String, success: @escaping (_ country: String) -> (), failure: @escaping failure) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("TransactionID", ["xs:type":"xs:string"], transactionsID)]
        let soapRequest = createXMLRequest(method: "GetTransactionDetails", subject: (nil, [:]), requestParams: params)
        request(getMutableRequest(soapRequest))
            .responseString { response in
                
                if let xmlString = response.result.value {
                    do {
                        let xmlDoc = try AEXMLDocument(xml: xmlString)
                        let payerInfo = xmlDoc.root["SOAP-ENV:Body"]["GetTransactionDetailsResponse"]["PaymentTransactionDetails"]["PayerInfo"].children
                        for item in payerInfo {
                            if item.name == "PayerCountry" {
                                if let country = item.value {
                                    success(country)
                                    return
                                }
                            }
                        }
                        success("Other")
                    } catch {
                        print("\(error)")
                    }
                } else {
                    print("error fetching XML")
                }
        }
    }
    
    private func getTransactionProduct(transactionsID: String, success: @escaping (_ product: String) -> (), failure: @escaping failure) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("TransactionID", ["xs:type":"xs:string"], transactionsID)]
        let soapRequest = createXMLRequest(method: "GetTransactionDetails", subject: (nil, [:]), requestParams: params)
        request(getMutableRequest(soapRequest))
            .responseString { response in
                
                if let xmlString = response.result.value {
                    do {
                        let xmlDoc = try AEXMLDocument(xml: xmlString)
                        let paymentItem = xmlDoc.root["SOAP-ENV:Body"]["GetTransactionDetailsResponse"]["PaymentTransactionDetails"]["PaymentItemInfo"]["PaymentItem"].children
                        for item in paymentItem {
                            if item.name == "Name" {
                                if let product = item.value {
                                    success(product)
                                    return
                                }
                            }
                        }
                        success("Other")
                    } catch {
                        print("\(error)")
                    }
                } else {
                    print("error fetching XML")
                }
        }
    }
    
    //MARK: - Get transactions by status
    func getTransactionsByStatus(success: @escaping (_ expenses: [(status: String, size: Int)]) -> (), failure: @escaping failure) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("StartDate", ["xs:type":"dateTime"], getDate(mounthsAgo: 1)), ("TransactionClass", ["xs:type":"ePaymentTransactionClassCodeType"], "All")]
        let soapRequest = createXMLRequest(method: "TransactionSearch", subject: (nil, [:]), requestParams: params)
        request(getMutableRequest(soapRequest))
            .responseString { response in

                var transactionsSize: [(status: String, size: Int)] = []
                
                if let xmlString = response.result.value {
                    do {
                        let xmlDoc = try AEXMLDocument(xml: xmlString)
                        let transactions = xmlDoc.root["SOAP-ENV:Body"]["TransactionSearchResponse"].children
                        for transaction in transactions {
                            if transaction.name == "PaymentTransactions" {
                                if let status = transaction["Status"].value {
                                    if transactionsSize.count == 0 {
                                        transactionsSize.append((status, 1))
                                    } else {
                                        var isNewStatus = true
                                        for i in 0..<transactionsSize.count {
                                            if transactionsSize[i].status == status {
                                                let size = transactionsSize[i].size
                                                transactionsSize[i] = (status, size + 1)
                                                isNewStatus = false
                                            }
                                        }
                                        if isNewStatus {
                                            transactionsSize.append((status, 1))
                                        }
                                    }
                                }
                            }
                        }
                        success(transactionsSize)
                    } catch {
                        print("\(error)")
                    }
                } else {
                    print("error fetching XML")
                }
        }
        
    }
    
    //MARK: - Get pending by type
    func getPendingByType(success: @escaping (_ pending: [(status: String, count: Int)]) -> (), failure: @escaping failure) {
        
        let merchantEmail = generateEmailFromApiUsername()
        
        let headers: [String : String] = [
            "X-PAYPAL-SECURITY-USERID" : apiUsername,
            "X-PAYPAL-SECURITY-PASSWORD" : apiPassword,
            "X-PAYPAL-SECURITY-SIGNATURE" : apiSignature,
            "X-PAYPAL-REQUEST-DATA-FORMAT" : "NV",
            "X-PAYPAL-RESPONSE-DATA-FORMAT" : "JSON",
            "X-PAYPAL-APPLICATION-ID" : appID
            ]
        
        let params: [String : Any] = [
            "requestEnvelope.errorLanguage" : "en_US",
            "merchantEmail" : merchantEmail,
            "parameters.origin" : "",
            "page" : 1,
            "pageSize" : 10
        ]
        
        request("https://svcs.sandbox.paypal.com/Invoice/SearchInvoices", method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            
            if let data = response.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                    if let jsonDictionary = json {
                        if let size = jsonDictionary["count"] as? String, Int(size)! > 0 {
                            if let invoiceList = jsonDictionary["invoiceList"] as? NSDictionary {
                                if let invoiceArray = invoiceList["invoice"] as? NSArray {
                                    
                                    var statusArray: [(status: String, count: Int)] = []
                                    
                                    for i in 0..<invoiceArray.count {
                                        let invoice = invoiceArray[i] as! NSDictionary
                                        let status = invoice["status"] as! String
                                        
                                        if statusArray.count == 0 {
                                            statusArray.append((status, 1))
                                        } else {
                                            var isNewStatus = true
                                            for i in 0..<statusArray.count {
                                                if statusArray[i].status == status {
                                                    let size = statusArray[i].count
                                                    statusArray[i] = (status, size + 1)
                                                    isNewStatus = false
                                                }
                                            }
                                            if isNewStatus {
                                                statusArray.append((status, 1))
                                            }
                                        }
                                    }
                                    success(statusArray)
                                }
                            }
                        }
                    } else {
                        failure("Load failed")
                    }
                } catch {
                    guard response.result.isSuccess else {
                        let error = response.result.error
                        if let error = error, (error as NSError).code != NSURLErrorCancelled {
                            let requestError = error.localizedDescription
                            failure(requestError)
                        }
                        return
                    }
                }
            }
        }
        
    }
    
    //MARK: - Get recent expenses
    func getRecentExpenses(success: @escaping (_ expenses: [(payer: String, netAmount: String)]) -> (), failure: @escaping failure) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("StartDate", ["xs:type":"dateTime"], getDate(mounthsAgo: 1)), ("TransactionClass", ["xs:type":"ePaymentTransactionClassCodeType"], "Sent")]
        let soapRequest = createXMLRequest(method: "TransactionSearch", subject: (nil, [:]), requestParams: params)
        request(getMutableRequest(soapRequest))
            .responseString { response in
                
                var dataArray: [(payer: String, netAmount: String)] = []
                
                if let xmlString = response.result.value {
                    do {
                        let xmlDoc = try AEXMLDocument(xml: xmlString)
                        let transactions = xmlDoc.root["SOAP-ENV:Body"]["TransactionSearchResponse"].children
                        for transaction in transactions {
                            if transaction.name == "PaymentTransactions" {
                                dataArray.append((transaction["PayerDisplayName"].value!, transaction["NetAmount"].value!))
                            }
                        }
                        success(dataArray)
                    } catch {
                        print("\(error)")
                    }
                } else {
                    print("error fetching XML")
                }
        }
    }
    
    
    //MARK: - Helpers methods
    private func getDate(mounthsAgo: Int) -> String {
        let dayInSecond = 60 * 60 * 24
        let mountAgo = Date(timeIntervalSinceNow: -(Double(dayInSecond * 30 * mounthsAgo)))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: mountAgo) + "T00:00:00Z"
        return dateString
    }
    
    private func getMutableRequest(_ soapRequest: AEXMLDocument) -> URLRequest {
        let soapLenth = String(soapRequest.xml.characters.count)
        let theURL = URL(string: payPalUri)
        
        var mutableR = URLRequest(url: theURL!)
        mutableR.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        mutableR.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Content-Type")
        mutableR.addValue(soapLenth, forHTTPHeaderField: "Content-Length")
        mutableR.httpMethod = "POST"
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    private func createXMLRequest(method: String, subject: (subValue: String?, subAttributes: [String : String]), requestParams: [(field: String, description: [String:String], value: String)]) -> AEXMLDocument {
        
        let xml = AEXMLDocument()
        let attributes = ["xmlns:xsi" : "http://www.w3.org/2001/XMLSchema-instance", "xmlns:SOAP-ENC" : "http://schemas.xmlsoap.org/soap/encoding/", "xmlns:SOAP-ENV" : "http://schemas.xmlsoap.org/soap/envelope/", "xmlns:xsd" : "http://www.w3.org/2001/XMLSchema", "SOAP-ENV:encodingStyle" : "http://schemas.xmlsoap.org/soap/encoding/"]
        let envelope = xml.addChild(name: "SOAP-ENV:Envelope", attributes: attributes)
        let header = envelope.addChild(name: "SOAP-ENV:Header")
        let requesterCredentials = header.addChild(name: "RequesterCredentials", attributes: ["xmlns" : "urn:ebay:api:PayPalAPI"])
        let credentials = requesterCredentials.addChild(name: "Credentials", attributes: ["xmlns" : "urn:ebay:apis:eBLBaseComponents"])
        _ = credentials.addChild(name: "Username", value: apiUsername, attributes: [:])
        _ = credentials.addChild(name: "Password", value: apiPassword, attributes: [:])
        _ = credentials.addChild(name: "Signature", value: apiSignature, attributes: [:])
        _ = credentials.addChild(name: "Subject", value: subject.subValue, attributes: subject.subAttributes)
        
        let body = envelope.addChild(name: "SOAP-ENV:Body")
        let Req = body.addChild(name: method + "Req", attributes: ["xmlns":"urn:ebay:api:PayPalAPI"])
        let Request = Req.addChild(name: method + "Request")
        _ = Request.addChild(name: "Version", value: "204.0", attributes: ["xmlns" : "urn:ebay:apis:eBLBaseComponents"])
        for param in requestParams {
            let descr = param.description.first
            _ = Request.addChild(name: param.field, value: param.value, attributes: [(descr?.key)! : (descr?.value)!])
        }
        return xml
    }
    
    private func generateEmailFromApiUsername() -> String {
        let separatedBypointEmail = apiUsername.components(separatedBy: ".")
        let separatedByUnderLineName = separatedBypointEmail[0].components(separatedBy: "_")
        
        var domain = ""
        for (index, component) in separatedBypointEmail.enumerated() {
            if index > 0 {
                if index != separatedBypointEmail.count - 1 {
                    domain += component + "."
                } else {
                    domain += component
                }
            }
        }
        let email = separatedByUnderLineName[0] + "@" + domain
        return email
    }
    
}
