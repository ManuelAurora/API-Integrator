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
                                          titleId: Int,
                                          options: [String]?) {
        
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
            
            if let pipelines = options, let pipeId = pipelines.first
            {
                let pipeArray = HubSpotManager.sharedInstance.pipelinesArray
                
                if let pipe = (pipeArray.filter { $0.pipelineId == pipeId }).first
                {
                    externalKpi.hsPipelineLabel = pipe.label
                }
                
                externalKpi.hsPipelineID = pipeId
            }
            
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
            
            if options?.count == 2
            {
                qbKpi.realmId = options?[0]
                qbKpi.oAuthTokenSecret = options?[1]
            }
            
            externalKpi.serviceName = IntegratedServices.Quickbooks.rawValue
            externalKpi.quickbooksKPI = qbKpi
            externalKpi.kpiName = ""
            
        case .googleAnalytics:
            let siteUrl = options?.first
            let gaKpi   = GAnalytics.googleAnalyticsEntity(for: siteUrl)
                
            gaKpi.oAuthToken = token
            gaKpi.oAuthRefreshToken = refToken
            gaKpi.oAuthTokenExpiresAt = date as NSDate
           
            //TODO: TEST FOR 2 OPTIONS
            if let options = options, options.count == 2
            {
                gaKpi.siteURL = options[0]
                gaKpi.viewID  = options[1]
            }
        
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
            
            if let options = options, options.count > 0
            {
                sfKPI.instance_url = options[0]
            }
            
            sfKPI.oAuthToken = token
            sfKPI.oAuthRefreshToken = refToken
            sfKPI.oAuthTokenExpiresAt = date as NSDate
            externalKpi.serviceName = IntegratedServices.SalesForce.rawValue
            externalKpi.saleForceKPI = sfKPI
            externalKpi.kpiName = ""
            
        case .paypal:
            guard let decyphered = token?.components(separatedBy: " "),
                decyphered.count == 2, let refToken = refToken else { return }
            
            let apiUsername = decyphered[0]
            let apiPassword = decyphered[1]
            
            var ppEntity: PayPalKPI!
            
            if let options = options
            {
                options.forEach { profileName in
                    ppEntity = PayPal.payPalEntityFor(profile: profileName)
                    ppEntity.profileName  = profileName
                    ppEntity.apiSignature = refToken
                    ppEntity.apiUsername  = apiUsername
                    ppEntity.apiPassword  = apiPassword
                }
            }
            else
            {
                ppEntity = PayPal.payPalEntityFor(profile: "No Name")
                ppEntity.profileName = "No Name"
                ppEntity.apiSignature = refToken
                ppEntity.apiUsername  = apiUsername
                ppEntity.apiPassword  = apiPassword
            }                        
            
            externalKpi.serviceName = IntegratedServices.PayPal.rawValue
            externalKpi.payPalKPI = ppEntity
            externalKpi.kpiName = ""
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
                        let options = kpiData["options"] as? [String]
                        let service = IntegratedServicesServerID(rawValue: serviceId)!
                        
                        createEntitiesForService(service,
                                                 userId: userId,
                                                 token: token,
                                                 refToken: refTok,
                                                 ttl: ttl,
                                                 upDateStr: lastUpd ?? "",
                                                 kpiId: kpiId,
                                                 titleId: titleID,
                                                 options: options)
                    }
                    return kpis
                }
            }
        }
        return nil
    }
}
