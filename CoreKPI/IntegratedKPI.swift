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
    case RevenueNewLeads = "Revenue/new leads"
    case KeyMetrics = "Key metrics"
    case ConvertedLeads = "Converted Leads"
    case OpenOpportunitiesByStage = "Open opportunities by Stage"
    case TopSalesRep = "Top Sales Rep"
    case NewLeadsByIndustry = "New leads by industry"
    case CampaignROI = "Campaign ROI"
}

enum QiuckBooksKPIs: String {
    case NetIncome = "Net Income"
    case Balance = "Balance"
    case BalanceByBankAccounts = "Balance by Bank Accounts"
    case IncomeProfitKPIs = "Income/Profit KPIS"
    case Invoices
    case NonPaidInvoices = "Non-Paid Invoices"    
    case PaidInvoices = "Paid invoices"
    case PaidInvoicesByCustomers = "Paid invoices by Customers"
    case OpenInvoicesByCustomers = "Open invoices by Customers"
    case OverdueCustomers = "Overdue Customers"
    case PaidExpenses = "Paid Expenses"
}

enum GoogleAnalyticsKPIs: String {
    case UsersSessions = "Users/Sessions"
    case AudienceOverview = "Audience Overview"
    case GoalOverview = "Goal Overview"
    case TopPagesByPageviews = "Top Pages by Pageviews"
    case TopSourcesBySessions = "Top Sources by Sessions"
    case TopOrganicKeywordsBySession = "Top Organic keywords by session"
    case TopChannelsBySessions = "Top Channels by sessions"
    case RevenueTransactions = "Revenue/ Transactions"
    case EcommerceOverview = "Ecommerce Overview"
    case RevenueByLandingPage = "Revenue by landing page"
    case RevenueByChannels = "Revenue by Channels"
    case TopKeywordsByRevenue = "Top Keywords by Revenue"
    case TopSourcesByRevenue = "Top Sources by Revenue"
}

enum HubSpotCRMKPIs: String {
    case DealsRevenue = "Deals/Revenue"
    case SalesPerformance = "Sales Performance"
    case SalesFunnel = "Sales Funnel"
    case DealsClosedWonAndLost = "Deals Closed Won and Lost"
    case SalesLeaderboard = "Sales Leaderboard"
    case DealRevenueLeaderboard = "Deal Revenue Leaderboard"
    case ClosedDealsLeaderboard = "Closed Deals Leaderboard"
    case DealStageFunnel = "Deal Stage Funnel"
    case TopWonDeals = "Top Won Deals"
    case RevenueByCompany = "Revenue by Company"
}

enum HubSpotMarketingKPIs: String {
    case VisitsContacts = "Visits/Contacts"
    case MarketingFunnel = "Marketing Funnel"
    case LandingPagePerformance = "Landing Page performance"
    case BloggingPerformance = "Blogging Performance"
    case EmailPerformance = "E-mail Performance"
    case MarketingPerformance = "Marketing Performance"
    case ContactsVisitsBySource = "Contacts/Visits by Source"
    case VisitsBySource = "Visits by Source"
    case ContactsByReferrals = "Contacts by Referrals"
    case TopBlogPostByPageviews = "Top Blog Post by pageviews"
}

enum PayPalKPIs: String {
    case Balance
    case NetSalesTotalSales = "Net Sales/Total Sales"
    case KPIS
    case AverageRevenueSale = "Average Revenue sale"
    case AverageRevenueSaleBy = "Average Revenue sale by…"
    case TopCountriesBySales = "Top countries by Sales"
    case TopProducts = "Top products"
    case TransactionsByStatus = "Transactions by Status"
    case PendingByType = "Pending by Type"
    case RecentExpenses = "Recent Expenses"
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
    case none = ""
    case Sales
    case Procurement
    case Projects
    case FinancialManagement = "Financial management"
    case Staff
}
