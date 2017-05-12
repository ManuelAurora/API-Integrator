//
//  PayPalDataManager.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 24.03.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

class IntegratedServicesDataManager
{    
    var kpi: KPI!
    
    func createDataFromRequest(success: @escaping (resultArray)->()) {
        
        var dataForPresent: resultArray = []
        
        switch (IntegratedServices(rawValue: kpi.integratedKPI.serviceName!))! {
            
        case .GoogleAnalytics:
            getGoogleAnalyticsData(success: { report in
                guard report.data?.rowCount != nil else {
                    dataForPresent.append((leftValue: "",
                                           centralValue: "There is no data",
                                           rightValue: ""))
                    success(dataForPresent)
                    return
                }
                
                switch (GoogleAnalyticsKPIs(rawValue: self.kpi.integratedKPI.kpiName!))! {
                case .UsersSessions:
                    for i in 0..<(report.data?.rowCount)! {
                        let data = report.data?.rows[i]
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy/MM/"
                        
                        dataForPresent.append(("\(dateFormatter.string(from: Date()))\((data?.dimensions[0])!)", "", "\((data?.metrics[0].values[0])!)"))
                    }
                    success(dataForPresent)
                    
                case .AudienceOverview:
                    for i in 0..<(report.data?.rowCount)! {
                        let data = report.data?.rows[i]
                        dataForPresent.append(("\((data?.dimensions[1])!)", "\((data?.dimensions[2])!)", "\((data?.dimensions[0])!)"))
                    }
                    
                    success(dataForPresent)
                case .GoalOverview:
                    for _ in 0..<(report.data?.rowCount)! {
                        for data in (report.data?.totals)! {
                            dataForPresent.append(("Goal", "", "\(data.values[0])"))
                        }
                    }
                    success(dataForPresent)
                case .TopPagesByPageviews:
                    for i in 0..<(report.data?.rowCount)! {
                        let data = report.data?.rows[i]
                        dataForPresent.append(("\((data?.dimensions[0])!)", "", "\((data?.metrics[0].values[0])!)"))
                    }
                    success(dataForPresent)
                    
                case .TopSourcesBySessions:
                    for i in 0..<(report.data?.rowCount)! {
                        let data = report.data?.rows[i]
                        dataForPresent.append(("\((data?.dimensions[0])!)", "", "\((data?.metrics[0].values[0])!)"))
                    }
                    success(dataForPresent)
                case .TopOrganicKeywordsBySession:
                    for i in 0..<(report.data?.rowCount)! {
                        let data = report.data?.rows[i]
                        dataForPresent.append(("\((data?.dimensions[0])!)", "", "\((data?.metrics[0].values[0])!)"))
                    }
                    success(dataForPresent)
                case .TopChannelsBySessions:
                    for i in 0..<(report.data?.rowCount)! {
                        let data = report.data?.rows[i]
                        dataForPresent.append(("\((data?.dimensions[0])!)", "", "\((data?.metrics[0].values[0])!)"))
                    }
                    success(dataForPresent)
                case .RevenueTransactions:
                    dataForPresent.append(("Revenue", "", "\((report.data?.totals[0].values[0])!)"))
                    success(dataForPresent)
                case .EcommerceOverview:
                    for values in (report.data?.totals)! {
                        for number in values.values {
                            dataForPresent.append(("OverView", "", "\(number)"))
                        }
                    }
                    success(dataForPresent)
                case .RevenueByLandingPage:
                    dataForPresent.append(("Revenue", "", "\((report.data?.totals[0].values[0])!)"))
                    success(dataForPresent)
                case .RevenueByChannels:
                    dataForPresent.append(("Revenue", "", "\((report.data?.totals[0].values[0])!)"))
                    success(dataForPresent)
                case .TopKeywordsByRevenue:
                    dataForPresent.append(("Revenue", "", "\((report.data?.totals[0].values[0])!)"))
                    success(dataForPresent)
                case .TopSourcesByRevenue:
                    dataForPresent.append(("Revenue", "", "\((report.data?.totals[0].values[0])!)"))
                    success(dataForPresent)
                }
            }
            )
        case .PayPal:
            let external = kpi.integratedKPI
            let request = PayPal(apiUsername: (external?.payPalKPI?.apiUsername)!, apiPassword: (external?.payPalKPI?.apiPassword)!, apiSignature: (external?.payPalKPI?.apiSignature)!)
            switch (PayPalKPIs(rawValue: (external?.kpiName)!))! {
            case .Balance:
                request.getBalance(success: { balance in
                    dataForPresent.append(("Balance", "", balance))
                    success(dataForPresent)
                }, failure: {error in
                    print(error)
                })
            case .NetSalesTotalSales:
                request.getSales(success: {sales in
                    for sale in sales {
                        dataForPresent.append((sale.payer , "\(sale.netAmount)&\(sale.amount)", sale.date))                        
                    }
                    
                    success(dataForPresent)
                }, failure: {error in
                    print(error)
                })
            case .KPIS:
                request.getKPIS(success: { kpis in
                    for kpi in kpis {
                        dataForPresent.append((kpi.kpiName , kpi.value, "\(kpi.percent)"))
                    }
                    success(dataForPresent)
                })
            case .AverageRevenueSale:
                request.getAverageRevenue(success: { revenue in
                    dataForPresent.append(("Average", "", revenue))
                    success(dataForPresent)
                }, failure: {error in
                    print(error)
                })
            case .AverageRevenueSaleByPeriod:
                request.getAverageRevenueSaleByPeriod(success: {revenues in
                    for revenue in revenues {
                        dataForPresent.append((revenue.period , revenue.revenue, "\(revenue.total)"))
                    }
                    success(dataForPresent)
                }, failure: {error in
                    print(error)
                })
            case .TopCountriesBySales:
                request.getTopCountriesBySales(success: {countries in
                    for country in countries {
                        dataForPresent.append((country.country , "\(country.sale)", "\(country.total)"))
                    }
                    success(dataForPresent)
                }, failure: {error in
                    print(error)
                })
            case .TopProducts:
                request.getTopProduct(success: {products in
                    for product in products {
                        dataForPresent.append((product.product , "\(product.size)", "\(product.total)"))
                    }
                    success(dataForPresent)
                }, failure: {error in
                    print(error)
                })
            case .TransactionsByStatus:
                request.getTransactionsByStatus(success: {transactionsSize in
                    for status in transactionsSize {
                        dataForPresent.append((status.status , "", "\(status.size)"))
                    }
                    success(dataForPresent)
                }, failure: {error in
                    print(error)
                })
            case .PendingByType:
                request.getPendingByType(success: { pending in
                    for value in pending {
                        dataForPresent.append((value.status , "", "\(value.count)"))
                    }
                    success(dataForPresent)
                }, failure: {error in
                    print(error)
                })
            case .RecentExpenses:
                request.getRecentExpenses(success: {expenses in
                    for expense in expenses {
                        dataForPresent.append((expense.payer , "", expense.netAmount))
                    }
                    success(dataForPresent)
                }, failure: {error in
                    print(error)
                })
            }
        case .SalesForce:
            break
        //TODO: Add request
        default:
            break
        }
    }
    
    //MARK: - get analytics data
    func getGoogleAnalyticsData(success: @escaping (_ report: Report) -> ()) {
        
        let external = kpi.integratedKPI
        let request = GoogleAnalytics(oauthToken: (external?.googleAnalyticsKPI?.oAuthToken)!, oauthRefreshToken: (external?.googleAnalyticsKPI?.oAuthRefreshToken)!, oauthTokenExpiresAt: (external?.googleAnalyticsKPI?.oAuthTokenExpiresAt)! as Date)
        let param = ReportRequest()
        param.viewId = (external?.googleAnalyticsKPI?.viewID)!
        
        var ranges:[ReportRequest.DateRange] = []
        var metrics: [ReportRequest.Metric] = []
        var dimentions: [ReportRequest.Dimension] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let curentDate = dateFormatter.string(from: Date())
        let sevenDaysAgo = dateFormatter.string(from: Date(timeIntervalSinceNow: -(7*24*3600)))
        let mounthAgo = dateFormatter.string(from: Date(timeIntervalSinceNow: -(30*24*3600)))
        
        switch (GoogleAnalyticsKPIs(rawValue: (external?.kpiName)!))! {
        case .UsersSessions:
            ranges.append(ReportRequest.DateRange(startDate: "2017-02-14", endDate: "2017-02-21"))
            metrics.append(ReportRequest.Metric(expression: "ga:7dayUsers/ga:sessions", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:day"))
        case .AudienceOverview:
            metrics.append(ReportRequest.Metric(expression: "ga:users", formattingType: .FLOAT))
            ranges.append(ReportRequest.DateRange(startDate: mounthAgo, endDate: curentDate))
            dimentions.append(ReportRequest.Dimension(name: "ga:interestInMarketCategory"))
            dimentions.append(ReportRequest.Dimension(name: "ga:userAgeBracket"))
            dimentions.append(ReportRequest.Dimension(name: "ga:userGender"))
            
        case .GoalOverview:
            ranges.append(ReportRequest.DateRange(startDate: sevenDaysAgo, endDate: curentDate))
            metrics.append(ReportRequest.Metric(expression: "ga:goalCompletionsAll", formattingType: .INTEGER))
        case .TopPagesByPageviews:
            ranges.append(ReportRequest.DateRange(startDate: sevenDaysAgo, endDate: curentDate))
            metrics.append(ReportRequest.Metric(expression: "ga:pageviews", formattingType: .INTEGER))
            dimentions.append(ReportRequest.Dimension(name: "ga:pagePath"))
        case .TopSourcesBySessions:
            ranges.append(ReportRequest.DateRange(startDate: sevenDaysAgo, endDate: curentDate))
            metrics.append(ReportRequest.Metric(expression: "ga:sessions", formattingType: .INTEGER))
            dimentions.append(ReportRequest.Dimension(name: "ga:source"))
        case .TopOrganicKeywordsBySession:
            ranges.append(ReportRequest.DateRange(startDate: sevenDaysAgo, endDate: curentDate))
            metrics.append(ReportRequest.Metric(expression: "ga:sessions", formattingType: .INTEGER))
            dimentions.append(ReportRequest.Dimension(name: "ga:keyword"))
        case .TopChannelsBySessions:
            ranges.append(ReportRequest.DateRange(startDate: sevenDaysAgo, endDate: curentDate))
            metrics.append(ReportRequest.Metric(expression: "ga:sessions", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:channelGrouping"))
        case .RevenueTransactions:
            ranges.append(ReportRequest.DateRange(startDate: sevenDaysAgo, endDate: curentDate))
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue/ga:transactions", formattingType: .FLOAT))
        case .EcommerceOverview:
            ranges.append(ReportRequest.DateRange(startDate: sevenDaysAgo, endDate: curentDate))
            metrics.append(ReportRequest.Metric(expression: "ga:itemQuantity", formattingType: .FLOAT))
            metrics.append(ReportRequest.Metric(expression: "ga:uniquePurchases", formattingType: .FLOAT))
            metrics.append(ReportRequest.Metric(expression: "ga:localTransactionShipping", formattingType: .FLOAT))
            metrics.append(ReportRequest.Metric(expression: "ga:localRefundAmount", formattingType: .FLOAT))
            metrics.append(ReportRequest.Metric(expression: "ga:productListViews", formattingType: .FLOAT))
            metrics.append(ReportRequest.Metric(expression: "ga:productListClicks", formattingType: .FLOAT))
            metrics.append(ReportRequest.Metric(expression: "ga:productAddsToCart", formattingType: .FLOAT))
            metrics.append(ReportRequest.Metric(expression: "ga:revenuePerUser", formattingType: .FLOAT))
            metrics.append(ReportRequest.Metric(expression: "ga:transactionsPerUser", formattingType: .FLOAT))
        case .RevenueByLandingPage:
            ranges.append(ReportRequest.DateRange(startDate: sevenDaysAgo, endDate: curentDate))
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:landingPagePath"))
        case .RevenueByChannels:
            ranges.append(ReportRequest.DateRange(startDate: sevenDaysAgo, endDate: curentDate))
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:channelGrouping"))
        case .TopKeywordsByRevenue:
            ranges.append(ReportRequest.DateRange(startDate: sevenDaysAgo, endDate: curentDate))
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:keyword"))
        case .TopSourcesByRevenue:
            ranges.append(ReportRequest.DateRange(startDate: mounthAgo, endDate: curentDate))
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:source"))
        }
        
        param.dateRanges = ranges
        param.metrics = metrics
        param.dimensions = dimentions
        
        request.getAnalytics(param: param, success: { report, token in
            if token != nil {
                let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
                external?.googleAnalyticsKPI?.setValue(token, forKey: "oAuthToken")
                do {
                    try context.save()
                } catch {
                    print(error)
                    return
                }
            }
            success(report)
        }, failure: { error in
            if error == "403" {
                //user has not rules for this view
                //self.autorisationAgain(external: external!)
            }
        })
    }
}
