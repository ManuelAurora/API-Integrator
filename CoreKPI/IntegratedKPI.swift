//
//  IntegratedKPI.swift
//  CoreKPI
//
//  Created by Семен on 20.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

//MARK: - Enums
enum IntegratedServices: String {
    case none = "Choose Service"
    case SalesForce
    case Quickbooks
    case GoogleAnalytics
    case HubSpotCRM
    case HubSpotMarketing
    case PayPal
}

enum SalesForceKPIs: String {
    case none
    case RevenueNewLeads = "Revenue/new leads"
    case KeyMetrics = "Key metrics"
    case ConvertedLeads = "Converted Leads"
    case OpenOpportunitiesByStage = "Open opportunities by Stage"
    case TopSalesRep = "Top Sales Rep"
    case NewLeadsByIndustry = "New leads by industry"
    case CampaignROI = "Campaign ROI"
}

enum QiuckBooksKPIs: String {
    case none
    case Test = "Coming soon"
}

enum GoogleAnalyticsKPIs: String {
    case none
    case Test = "Coming soon"
}

enum HubSpotCRMKPIs: String {
    case none
    case Test = "Coming soon"
}

enum HubSpotMarketingKPIs: String {
    case none
    case Test = "Coming soon"
}

enum PayPalKPIs: String {
    case none
    case Test = "Coming soon"
}

enum TypeOfKPI: String {
    case IntegratedKPI
    case createdKPI
}

enum ImageForKPIList: String {
    case Increases = "Green up.png"
    case Decreases = "Red down.png"
    case SaleForce = "SaleForce.png"
    case QuickBooks = "QuickBooks.png"
    case GoogleAnalytics = "GoogleAnalytics.png"
    case HubSpotCRM = "HubSpotCRM.png"
    case PayPal = "PayPal.png"
    case HubSpotMarketing = "HubSpotMarketing.png"
}

enum Departments: String {
    case none = "Select"
    case Sales
    case Procurement
    case Projects
    case FinancialManagement = "Financial management"
    case Staff
}

//MARK: - Structs for KPIs
struct IntegratedKPI {
    var service: IntegratedServices
    var saleForceKPIs: [SalesForceKPIs]?
    var quickBookKPIs: [QiuckBooksKPIs]?
    var googleAnalytics: [GoogleAnalyticsKPIs]?
    var hubSpotCRMKPIs: [HubSpotCRMKPIs]?
    var payPalKPIs: [PayPalKPIs]?
    var hubSpotMarketingKPIs: [HubSpotMarketingKPIs]?
}
