//
//  GoogleAnalytics.swift
//  CoreKPI
//
//  Created by Семен on 02.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GAnalytics: ExternalRequest {
    
    class func googleAnalyticsEntity(for siteUrl: String?) -> GoogleKPI {
        
        guard let siteUrl = siteUrl else { return GoogleKPI() }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context     = appDelegate.persistentContainer.viewContext
        let request     = NSFetchRequest<GoogleKPI>(entityName: "GoogleKPI")
        
        let predicate = NSPredicate(format: "siteURL = %@", siteUrl)
        
        request.predicate = predicate
        
        if let result  = try? context.fetch(request), let entity = result.first
        {
            return entity
        }
        else
        {
            return GoogleKPI(context: context)
        }
    }
    
    class func getServerIdFor(kpi: GoogleAnalyticsKPIs) -> Int {
        
        switch kpi
        {
        case .UsersSessions: return 19
        case .AudienceOverview: return 20
        case .GoalOverview: return 21
        case .TopPagesByPageviews: return 22
        case .TopSourcesBySessions: return 23
        case .TopOrganicKeywordsBySession: return 24
        case .TopChannelsBySessions: return 25
        case .RevenueTransactions: return 26
        case .EcommerceOverview: return 27
        case .RevenueByLandingPage: return 28
        case .RevenueByChannels: return 29
        case .TopKeywordsByRevenue: return 30
        case .TopSourcesByRevenue: return 31
        }
    }
    
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
    
    func getAnalytics(param: ReportRequest, success: @escaping (_ report: Report, _ newOauthToken: String?) -> (), failure: @escaping failure) {
        analyticsRequest(param: param, success: {report in
            success(report, nil)
        }, failure: { error in
            if error == "401" {
                //update token
                self.updateAccessToken(servise: .GoogleAnalytics, success: {tokenInfo in
                    self.oauthToken = tokenInfo.token
                    //get analytics with new oauth token
                    self.analyticsRequest(param: param, success: { report in
                        success(report, tokenInfo.token)
                    }, failure: {error in
                        failure(error)
                    }
                    )
                }, failure: { error in
                    failure(error)
                }
                )
            } else {
                failure(error)
            }
        }
        )
    }
    
    private func analyticsRequest(param: ReportRequest, success: @escaping (_ report: Report) -> (), failure: @escaping failure) {
        
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
            print(error)
        }
        )
    }
    
}
