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
    
    let payPalUri = "https://api-3t.sandbox.paypal.com/2.0/"
    
    func getBalance(success: @escaping (_ balance: String) -> (), failure: @escaping failure)  {
        
        let soapRequest = createXMLRequest(method: "GetBalance", subject: (nil, [:]), requestParams: [])

        
        let soapLenth = String(soapRequest.xml.characters.count)
        let theURL = URL(string: payPalUri)
        
        var mutableR = URLRequest(url: theURL!)
        mutableR.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        mutableR.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Content-Type")
        mutableR.addValue(soapLenth, forHTTPHeaderField: "Content-Length")
        mutableR.httpMethod = "POST"
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        
        request(mutableR)
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
