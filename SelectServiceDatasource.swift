//
//  SelectServiceDatasource.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 16.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

private let cellId = "ServiceCell"

struct KPISource
{
    let service: IntegratedServices
}

class SelectServiceDatasource
{
    let kpiSources: [KPISource] = {
        let sfService = KPISource(service: .SalesForce)
        let qbService = KPISource(service: .Quickbooks)
        let gaService = KPISource(service: .GoogleAnalytics)
        let hcService = KPISource(service: .HubSpotCRM)
        let hmService = KPISource(service: .HubSpotMarketing)
        let ppService = KPISource(service: .PayPal)
        
        return [sfService, qbService, gaService, hcService, hmService, ppService]
        
    }()

    func getKpisFor(service: IntegratedServices) -> [semenSettingsTuple] {
        
        var kpiArray = [semenSettingsTuple]()
        
        switch service
        {
        case .SalesForce:
            for saleforceKPI in iterateEnum(SalesForceKPIs.self) {
                kpiArray.append((saleforceKPI.rawValue, false))
            }
            
        case .Quickbooks:
            for quickbookKPI in iterateEnum(QiuckBooksKPIs.self) {
                kpiArray.append((quickbookKPI.rawValue, false))
            }
            
        case .GoogleAnalytics:
            for googleAnalyticsKPI in iterateEnum(GoogleAnalyticsKPIs.self) {
                kpiArray.append((googleAnalyticsKPI.rawValue, false))
            }
            
        case .HubSpotCRM:
            for hubSpotCrmKPI in iterateEnum(HubSpotCRMKPIs.self) {
                kpiArray.append((hubSpotCrmKPI.rawValue, false))
            }
            
        case .HubSpotMarketing:
            for hubSpotmarketingKPI in iterateEnum(HubSpotMarketingKPIs.self) {
                kpiArray.append((hubSpotmarketingKPI.rawValue, false))
            }
            
        case .PayPal:
            for payPalKPI in iterateEnum(PayPalKPIs.self) {
                kpiArray.append((payPalKPI.rawValue, false))
            }
        default: break
        }
        
        return kpiArray
    }
}
