//
//  PayPal.swift
//  CoreKPI
//
//  Created by Семен on 28.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import Alamofire

class PayPal: ExternalRequest {
    
    let payPalUri = "https://api.sandbox.paypal.com/"
    
    func getBalance(success: @escaping () -> (), failure: @escaping failure)  {
        
        let url = "https://api-3t.sandbox.paypal.com/nvp"
        
        let apiUsername = "test_api1.sem.ru"
        let apiPassword = "8GJG2CHSNZ2F2W5Y"
        let apiSignature = "An5ns1Kso7MWUdW4ErQKJJJ4qi4-A3u4r.0LMFDTXAA-lnElRcGeoYx7"
        
        let params: [String : Any] = ["METHOD" : "GetBalance", "VERSION" : "204.0", "USER" : apiUsername, "PWD" : apiPassword, "SIGNATURE" : apiSignature]
        
        request(url, method: .post , parameters: params, encoding: URLEncoding.default).responseString { response in
            if let data = response.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                    if let jsonDictionary = json {
                        //success(jsonDictionary)
                    } else {
                        failure("Load failed")
                    }
                    
                } catch {
                    print("Vse ochen ploho")
//                    guard response.request.isSuccess else {
//                        let error = response.request.error
//                        if let error = error, (error as NSError).code != NSURLErrorCancelled {
//                            let requestError = error.localizedDescription
//                            failure(requestError)
//                        }
//                        return
//                    }
                }
            }
        }

        
//        let payUrl = payPalUri + "v1/payments/payment"
//        let headers = ["Authorization" : "Bearer \(oauthToken)", "Content-Type" : "application/json"]
//        let params: [String : Any] = ["intent" : "sale", "payer":["payment_method":"paypal"],"redirect_urls":["return_url":"http://corekpi.com", "cancel_url" : "http://example.com/your_cancel_url.html"], "transactions" : [["amount":["total":"7.47", "currency" : "USD"]]]]
//        
//        self.getJson(url: payUrl, header: headers, params: params, method: .post, success: { json in
//            success()
//        }, failure: {error in
//            failure(error)
//        })
    }
    
    func getInvoices(success: @escaping (_ json: NSDictionary) -> (), failure: @escaping failure)  {
        
        let invoiceListUrl = payPalUri + "v1/invoicing/invoices/"
        let headers = ["Authorization" : "Bearer \(oauthToken)", "Content-Type" : "application/json"]
        
        self.getJson(url: invoiceListUrl, header: headers, params: nil, method: .get, success: { json in
            success(json)
        }, failure: {error in
            failure(error)
        })
    }
}
