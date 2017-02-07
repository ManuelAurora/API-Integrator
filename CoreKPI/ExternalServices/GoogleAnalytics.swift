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
    
    typealias success = (_ json: NSDictionary) -> ()
    typealias failure = (_ error: String) -> ()
    
    func getViewID(success: @escaping (_ viewsArray: [(viewID: String, webSiteUri: String)]) -> (), failure: @escaping failure ) {
        
        let url = "https://www.googleapis.com/analytics/v3/management/accounts/~all/webproperties/~all/profiles"
        let headers = ["Authorization" : "Bearer \(oauthToken)"]
        
        let request = ExternalRequest(url: url)
        request.getJson(header: headers, params: nil, method: .get, success: { json in
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
    
    func getAnalytics(viewId: String, success: @escaping () -> (), failure: @escaping failure ) {
        let url = "https://analyticsreporting.googleapis.com."
        let uri = "/v4/reports:batchGet"
        
        //test
        let param = ReportRequest(viewId: viewId, startDate: "2017-01-01", endDate: "2017-02-01", expression: "ga:users", alias: "", formattingType: "INTEGER")
        let jsonString = param.toDictionary()
        //test
        
        let params: [String : Any] = ["reportRequests" : jsonString]
        let headers = ["Authorization" : "Bearer \(oauthToken)"]
        
        let request = ExternalRequest(url: url+uri)
        request.getJson(header: headers, params: params, method: .post, success: { json in
            if let reports = json["reports"] as? NSArray {
                let data = reports[0] as! NSDictionary
                let rep = Report(dictionary: data)
                
            }
            
            //let report = Report(dictionary: json
            //print(report.nextPageToken ?? "nil")
        }, failure: { error in
            failure(error)
        }
        )
    }
}
