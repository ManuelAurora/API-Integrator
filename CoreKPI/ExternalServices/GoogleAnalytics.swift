//
//  GoogleAnalytics.swift
//  CoreKPI
//
//  Created by Семен on 02.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import Alamofire

class GoogleAnalytics {
    
    let oauthToken: String
    let oauthRefreshToken: String
    let oauthTokenExpiresAt: Date
    
    init(oauthToken: String, oauthRefreshToken: String, oauthTokenExpiresAt: Date) {
        self.oauthToken = oauthToken
        self.oauthRefreshToken = oauthRefreshToken
        self.oauthTokenExpiresAt = oauthTokenExpiresAt
    }
    
    func getAnalytics() {
        let url = "https://analyticsreporting.googleapis.com."
        let uri = "/v4/reports:batchGet"
        
        //test
        let param = ReportRequest(viewId: "132149654", startDate: "2017-01-01", endDate: "2017-02-01", expression: "users", alias: "", formattingType: "INTEGER")
        let jsonString = param.toDictionary()
        //test
        
        let params: [String : Any] = ["reportRequests" : jsonString]
        let headers = ["Authorization" : "Bearer \(oauthToken)"]
        
        request(url+uri, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let data = response.data {
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                    if let jsonDictionary = json {
                        print(jsonDictionary)
                    } else {
                        print("Load failed")
                    }
                    
                } catch {
                    guard response.result.isSuccess else {
                        let error = response.result.error
                        if let error = error, (error as NSError).code != NSURLErrorCancelled {
                            let requestError = error.localizedDescription
                            print(requestError)
                        }
                        return
                    }
                }
            }
        }
    }
}
