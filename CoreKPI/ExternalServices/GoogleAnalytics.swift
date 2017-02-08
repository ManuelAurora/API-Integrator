//
//  GoogleAnalytics.swift
//  CoreKPI
//
//  Created by Семен on 02.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import Alamofire

class GoogleAnalytics: ExternalRequest {
    
    func getViewID(success: @escaping (_ viewsArray: [(viewID: String, webSiteUri: String)]) -> (), failure: @escaping failure ) {
        
        let url = "https://www.googleapis.com/analytics/v3/management/accounts/~all/webproperties/~all/profiles"
        let headers = ["Authorization" : "Bearer \(oauthToken)"]
        
        self.getJson(url: url, header: headers, params: nil, method: .get, success: { json in
            if let items = json["items"] as? NSArray {
                var viewsArray: [(viewID: String, webSiteUri: String)] = []
                for i in 0..<items.count {
                    let item = items[i] as! NSDictionary
                    let viewID = item["id"] as! String
                    let link = item["websiteUrl"] as! String
                    viewsArray.append((viewID, link))
                }
                success(viewsArray)
            }
        }, failure: { error in
            failure(error)
        }
        )
    }
    
    func getAnalytics(param: ReportRequest, success: @escaping (_ report: Report) -> (), failure: @escaping failure ) {
        let url = "https://analyticsreporting.googleapis.com."
        let uri = "/v4/reports:batchGet"
    
        let jsonString = param.toJSON()
        
        let params: [String : Any] = ["reportRequests" : jsonString]
        let headers = ["Authorization" : "Bearer \(oauthToken)"]
        
        self.getJson(url: url+uri, header: headers, params: params, method: .post, success: { json in
            if let reports = json["reports"] as? NSArray {
                let data = reports[0] as! NSDictionary
                let rep = Report(JSON: data as! [String : Any])
                success(rep!)
            } else {
                if let error = json["error"] as? NSDictionary {
                    let code = error["code"] as! Int
                    failure("\(code)")
                }
            }
        }, failure: { error in
            failure(error)
        }
        )
    }
}
