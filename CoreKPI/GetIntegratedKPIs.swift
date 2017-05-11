//
//  GetIntegratedKPIs.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 05.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GetIntegratedKPIs: Request {
    
    func getKPIsFromServer(success: @escaping (_ arrayOfKPI: [KPI]) -> (), failure: @escaping failure) {
        
        let data: [String : Any] = [:]
        
        self.getJson(category: "/kpi/getIntegratedKPIList", data: data,
                     success: { json in
                        if let arrayOfKPI = self.parsingJson(json: json) {
                            success(arrayOfKPI)
                        } else {
                            failure(self.errorMessage ?? "Wrong data from server")
                        }
        },
                     failure: { (error) in
                        failure(error)
        })
    }
    
    private func createEntitiesForService(_ servId: IntegratedServicesServerID,
                                          userId: Int,
                                          token: String?,
                                          refToken: String?,
                                          ttl: Int?,
                                          upDateStr: String,
                                          kpiId: Int,
                                          titleId: Int) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let dateFormatter = DateFormatter()        
        let externalKpi = ExternalKPI(context: managedContext)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //2017-01-27 08:19:00
        
        var date: Date!
        
        if let d = dateFormatter.date(from: upDateStr), let time = ttl
        {
            date = d.addingTimeInterval(TimeInterval(time))
        }
        
        switch servId
        {
        case .hubspotMarketing:
             let request = NSFetchRequest<HubspotKPI>(entityName: "HubspotKPI")
             var hsKpi: HubspotKPI!
             
             if let result = try? managedContext.fetch(request), let hKpi = result.first
             {
                hsKpi = hKpi
             }
             else
             {
                hsKpi = HubspotKPI(context: managedContext)
             }
            
            hsKpi.oauthToken = token
            hsKpi.refreshToken = refToken
            hsKpi.validationDate = date as NSDate
            externalKpi.serviceName = IntegratedServices.HubSpotMarketing.rawValue
            externalKpi.hubspotKPI = hsKpi
            externalKpi.kpiName = ""
            
            //extKpi.hsPipelineID
            
        case .hubspotCRM:
            let request = NSFetchRequest<HubspotKPI>(entityName: "HubspotKPI")
            var hsKpi: HubspotKPI!
            
            if let result = try? managedContext.fetch(request), let hKpi = result.first
            {
                hsKpi = hKpi
            }
            else
            {
                hsKpi = HubspotKPI(context: managedContext)
            }
            
            hsKpi.oauthToken = token
            hsKpi.refreshToken = refToken
            hsKpi.validationDate = date as NSDate
            externalKpi.serviceName = IntegratedServices.HubSpotCRM.rawValue
            externalKpi.hubspotKPI = hsKpi
            externalKpi.kpiName = ""
            //extKpi.hsPipelineID
            
        case .quickbooks:
            let request = NSFetchRequest<QuickbooksKPI>(entityName: "QuickbooksKPI")
            var qbKpi: QuickbooksKPI!
            
            if let result = try? managedContext.fetch(request), let qKpi = result.first
            {
                qbKpi = qKpi
            }
            else
            {
                qbKpi = QuickbooksKPI(context: managedContext)
            }
            
            qbKpi = QuickbooksKPI(context: managedContext)
            qbKpi.oAuthToken = token
            qbKpi.oAuthRefreshToken = refToken
            qbKpi.oAuthTokenExpiresAt = date as NSDate
            
            externalKpi.serviceName = IntegratedServices.Quickbooks.rawValue
            externalKpi.quickbooksKPI = qbKpi
            externalKpi.kpiName = ""
            
        case .googleAnalytics:
            let request = NSFetchRequest<GoogleKPI>(entityName: "GoogleKPI")
            var gaKpi: GoogleKPI!
            
            if let result = try? managedContext.fetch(request), let qqKpi = result.first
            {
                gaKpi = qqKpi
            }
            else
            {
                gaKpi = GoogleKPI(context: managedContext)
            }
            
            gaKpi.oAuthToken = token
            gaKpi.oAuthRefreshToken = refToken
            gaKpi.oAuthTokenExpiresAt = date as NSDate
            externalKpi.serviceName = IntegratedServices.GoogleAnalytics.rawValue
            externalKpi.googleAnalyticsKPI = gaKpi
            externalKpi.kpiName = ""
            
        case .salesforceCRM:
            let request = NSFetchRequest<SalesForceKPI>(entityName: "SalesForceKPI")
            var sfKPI: SalesForceKPI!
            
            if let result = try? managedContext.fetch(request), let sKpi = result.first
            {
                sfKPI = sKpi
            }
            else
            {
                sfKPI = SalesForceKPI(context: managedContext)
            }
            
            sfKPI.oAuthToken = token
            sfKPI.oAuthRefreshToken = refToken
            sfKPI.oAuthTokenExpiresAt = date as NSDate
            externalKpi.serviceName = IntegratedServices.SalesForce.rawValue
            externalKpi.saleForceKPI = sfKPI
            externalKpi.kpiName = ""
        
        case .paypal:
            print("PAYPAL")
        }
        
        externalKpi.userID = Int64(userId)
        externalKpi.kpiName = getKpiNameFrom(id: titleId)
        externalKpi.serverID = Int64(kpiId)
        
        do {
            try managedContext.save()
        }
        catch let error {
            print(error.localizedDescription)
        }        
    }
    
    func parsingJson(json: NSDictionary) -> [KPI]? {
        
        if let successKey = json["success"] as? Int
        {
            if successKey == 1
            {
                let kpis = [KPI]()
                if let dataKey = json["data"] as? [jsonDict]
                {
                    dataKey.forEach { kpiData in
                        
                        let kpiId = kpiData["int_kpi_id"] as! Int
                        let serviceId = kpiData["token_type"] as! Int
                        let token = kpiData["token"] as? String
                        let ttl = kpiData["ttl"] as? Int
                        let refTok = kpiData["refresh_token"] as? String
                        let userId = kpiData["user_id"] as! Int
                        let lastUpd = kpiData["last_update_date"] as? String
                        let titleID = kpiData["title"] as! Int
                        let service = IntegratedServicesServerID(rawValue: serviceId)!
                        
                        createEntitiesForService(service,
                                                 userId: userId,
                                                 token: token,
                                                 refToken: refTok,
                                                 ttl: ttl,
                                                 upDateStr: lastUpd ?? "",
                                                 kpiId: kpiId,
                                                 titleId: titleID)
                        
                    }
                    return kpis
                }
            }
        }
        return nil
    }
}
