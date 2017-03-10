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

class PayPal: ExternalRequest {
    
    var apiUsername = ""
    var apiPassword = ""
    var apiSignature = ""
    
    init(apiUsername: String, apiPassword: String, apiSignature: String) {
        self.apiUsername = apiUsername
        self.apiPassword = apiPassword
        self.apiSignature = apiSignature
        super.init()
    }
    
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
    
    let payPalUri = "https://api-3t.sandbox.paypal.com/2.0/"
    
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
    
    func getSales(success: @escaping (_ sales: [(payer: String, netAmount: String)]) -> (), failure: @escaping failure) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("StartDate", ["xs:type":"dateTime"], getStartDate())]
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
    
    func getKPIS(success: @escaping (_ kpis: [(kpiName: String, value: String)]) -> (), failure: @escaping failure) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("StartDate", ["xs:type":"dateTime"], getStartDate())]
        let soapRequest = createXMLRequest(method: "TransactionSearch", subject: (nil, [:]), requestParams: params)
        request(getMutableRequest(soapRequest))
            .responseString { response in
                
                var dataArray: [(kpiName: String, value: String)] = []
                
                var netSales = 0
                var fees = 0
                var shippingCosts = 0
                var refunds = 0
                var incomingRefunds = 0
                var pending = 0
                var expenses = 0
                
                if let xmlString = response.result.value {
                    do {
                        let xmlDoc = try AEXMLDocument(xml: xmlString)
                        let transactions = xmlDoc.root["SOAP-ENV:Body"]["TransactionSearchResponse"].children
                        for transaction in transactions {
                            if transaction.name == "PaymentTransactions" {
                                let status = transaction["Status"].value!
                                switch status {
                                case "Success":
                                    let netSale = 0
                                default:
                                    break
                                    
                                }
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
    
    func getAverageRevenue(success: @escaping (_ revenue: String) -> (), failure: @escaping failure) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("StartDate", ["xs:type":"dateTime"], getStartDate()), ("TransactionClass", ["xs:type":"ePaymentTransactionClassCodeType"], "Received")]
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
    
    func getTransactionsByStatus(success: @escaping (_ expenses: [(status: String, size: Int)]) -> (), failure: @escaping failure) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("StartDate", ["xs:type":"dateTime"], getStartDate()), ("TransactionClass", ["xs:type":"ePaymentTransactionClassCodeType"], "All")]
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
    
    func getRecentExpenses(success: @escaping (_ expenses: [(payer: String, netAmount: String)]) -> (), failure: @escaping failure) {
        
        let params: [(field: String, description: [String:String], value: String)] = [("StartDate", ["xs:type":"dateTime"], getStartDate()), ("TransactionClass", ["xs:type":"ePaymentTransactionClassCodeType"], "Sent")]
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
    
    private func getStartDate() -> String {
        let dayInSecond = 60 * 60 * 24
        let mountAgo = Date(timeIntervalSinceNow: -(Double(dayInSecond * 30)))
        
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
    
}
