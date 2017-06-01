//
//  SelectServiceDatasource.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 16.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

struct KPISource
{
    let service: IntegratedServices
}

extension SelectServiceDatasource
{
    enum SectionType
    {
        case custom
        case integrated
    }
}

class SelectServiceDatasource
{
    let sections: [SectionType] = [.custom, .integrated]
    
    let kpiSources: [KPISource] = {
        let sfService = KPISource(service: .SalesForce)
        let qbService = KPISource(service: .Quickbooks)
        let gaService = KPISource(service: .GoogleAnalytics)
        let hcService = KPISource(service: .HubSpotCRM)
        let hmService = KPISource(service: .HubSpotMarketing)
        let ppService = KPISource(service: .PayPal)
        
        return [ppService, gaService, qbService, hcService, hmService, sfService]
    }()

    func getKpisFor(service: IntegratedServices) -> [semenSettingsTuple] {
        
        var kpiArray = [semenSettingsTuple]()
        
        let services = ModelCoreKPI.modelShared.integratedServices

        switch service
        {
        case .SalesForce, .GoogleAnalytics, .Quickbooks, .HubSpotCRM, .HubSpotMarketing, .none:
            break
       
        case .PayPal:
            let payPal = services.filter { $0.id == PayPal.serverId }.first!
            
            payPal.kpis.forEach { kpi in
                 kpiArray.append((kpi.title, false))
            }
        }
        return kpiArray
    }
}
