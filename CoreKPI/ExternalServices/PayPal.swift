//
//  PayPal.swift
//  CoreKPI
//
//  Created by Семен on 28.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class PayPal: ExternalRequest {
    
    let payPalUri = "https://api.sandbox.paypal.com/"
    
    func getBalance(success: @escaping () -> (), failure: @escaping failure)  {
        
        let payUrl = payPalUri + "v1/payments/payment"
        let headers = ["Authorization" : "Bearer \(oauthToken)", "Content-Type" : "application/json"]
        let params: [String : Any] = ["intent" : "sale", "payer":["payment_method":"paypal"],"redirect_urls":["return_url":"http://corekpi.com", "cancel_url" : "http://example.com/your_cancel_url.html"], "transactions" : [["amount":["total":"7.47", "currency" : "USD"]]]]
        
        self.getJson(url: payUrl, header: headers, params: params, method: .post, success: { json in
            success()
        }, failure: {error in
            failure(error)
        })
    }
    
    func getInvoices(success: @escaping () -> (), failure: @escaping failure)  {
        
        let invoiceListUrl = payPalUri + "v1/invoicing/invoices/"
        let headers = ["Authorization" : "Bearer \(oauthToken)", "Content-Type" : "application/json"]
        let params: [String : Any] = [:]
        
        self.getJson(url: invoiceListUrl, header: headers, params: params, method: .post, success: { json in
            success()
        }, failure: {error in
            failure(error)
        })

    }
}
