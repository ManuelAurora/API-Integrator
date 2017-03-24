//
//  ReportDataManipulator.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 24.03.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import OAuthSwift

class ReportDataManipulator
{
    var kpi: KPI!
    let quickBooksDataManager = QuickBookDataManager.shared()
    let integratedServicesDataManager = IntegratedServicesDataManager()
    var dataFromPaypalToPresent = resultArray()
    
    private func createDataFromRequestWith(qBMethod: QuickBookMethod?) {
        
        self.quickBooksDataManager.fetchDataFromIntuit(isCreation: false)
    }
    
    func dataForReport() {
        
        let kpiName  = kpi.integratedKPI.kpiName!
        
        switch (IntegratedServices(rawValue: kpi.integratedKPI.serviceName!))!
        {
        case .Quickbooks:
            var method: QuickBookMethod!
            let kpiValue = QiuckBooksKPIs(rawValue: kpiName)!
            
            switch kpiValue
            {
            case .Invoices, .NetIncome, .OverdueCustomers,
                 .PaidInvoices, .NonPaidInvoices,
                 .OpenInvoicesByCustomers: method = QBQuery(with: [:]);
            case .Balance:                 method = QBBalanceSheet(with: [:])
            case .BalanceByBankAccounts:   method = QBAccountList(with: [:])
            case .IncomeProfitKPIs:        method = QBProfitAndLoss(with: [:])
            case .PaidExpenses:            method = QBPaidExpenses(with: [:])
            case .PaidInvoicesByCustomers: method = QBPaidInvoicesByCustomers(with: [:])
            }
            
            quickBooksDataManager.listOfRequests.append((kpi.integratedKPI.requestJsonString!, method, kpiName: kpiValue))
            createDataFromRequestWith(qBMethod: method)
            
        case .PayPal:
            integratedServicesDataManager.kpi = kpi
            integratedServicesDataManager.createDataFromRequest(success: { dataForPresent in
                self.dataFromPaypalToPresent.append(contentsOf: dataForPresent)
                NotificationCenter.default.post(name: .paypalManagerRecievedData, object: nil)
            })
            
        default: break
        }
    }
}
//        case .GoogleAnalytics:
//            switch (GoogleAnalyticsKPIs(rawValue: kpi.integratedKPI.kpiName!))!
//            {
//            case .UsersSessions:
//
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .AudienceOverview:
//                tableViewChartVC.titleOfTable = ("Ages","Genders","Market category")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .GoalOverview:
//                tableViewChartVC.titleOfTable = ("Goal Overview","","Value")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .TopPagesByPageviews:
//                tableViewChartVC.titleOfTable = ("Top Pages","","Value")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .TopSourcesBySessions:
//                tableViewChartVC.titleOfTable = ("Top Source","","Value")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .TopOrganicKeywordsBySession:
//                tableViewChartVC.titleOfTable = ("Top Keywords","","Value")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .TopChannelsBySessions:
//                // tableViewChartVC.titleOfTable = ("Top Source","","Value")
//                createDataFromRequest(success: { dataForPresent in
//                    var pieData: [(number: String, rate: String)] = []
//                    for item in dataForPresent {
//                        let pie: (number: String, rate: String) = (item.leftValue, item.rightValue)
//                        pieData.append(pie)
//                    }
//                    webViewChartOneVC.pieChartData = pieData
//                    webViewChartOneVC.refreshView()
//                    //                        tableViewChartVC.dataArray = dataForPresent
//                    //                        tableViewChartVC.tableView.reloadData()
//                })
//                return webViewChartOneVC
//            case .RevenueTransactions:
//                tableViewChartVC.titleOfTable = ("Top Source","","Value")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .EcommerceOverview:
//                tableViewChartVC.titleOfTable = ("Top Source","","Value")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .RevenueByLandingPage:
//                tableViewChartVC.titleOfTable = ("Top Source","","Value")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .RevenueByChannels:
//                tableViewChartVC.titleOfTable = ("Top Source","","Value")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .TopKeywordsByRevenue:
//                tableViewChartVC.titleOfTable = ("Top Source","","Value")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .TopSourcesByRevenue:
//                tableViewChartVC.titleOfTable = ("Top Source","","Value")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            }
//            //debug->
//            return tableViewChartVC
//        //<-debug
//        case .SalesForce:
//            navigationItem.title = "SalesForce"
//            switch (SalesForceKPIs(rawValue: kpi.integratedKPI.kpiName!))! {
//            case .RevenueNewLeads:
//                tableViewChartVC.titleOfTable = ("Revenue","New leads","Date")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .KeyMetrics:
//                tableViewChartVC.titleOfTable = ("Metrics","","Month to date")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .ConvertedLeads:
//                tableViewChartVC.titleOfTable = ("Balance","","$")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .OpenOpportunitiesByStage:
//                tableViewChartVC.titleOfTable = ("Name","","Stage")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .TopSalesRep:
//                tableViewChartVC.titleOfTable = ("Name","Won","Revenue")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .NewLeadsByIndustry:
//                tableViewChartVC.titleOfTable = ("Industry","","Month to date")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            case .CampaignROI:
//                tableViewChartVC.titleOfTable = ("Metrics","","All time")
//                createDataFromRequest(success: { dataForPresent in
//                    tableViewChartVC.dataArray = dataForPresent
//                    tableViewChartVC.tableView.reloadData()
//                })
//            }
//        default:
//            break
//        }
//    }
//
//
//    //MARK: - Autorisation again method
//    func autorisationAgain(external: ExternalKPI) {
//        let alertVC = UIAlertController(title: "Sorry", message: "You should autorisation again", preferredStyle: .alert)
//        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
//            let request = ExternalRequest()
//            request.oAuthAutorisation(servise: IntegratedServices(rawValue: external.serviceName!)!, viewController: self, success: { objects in
//                switch IntegratedServices(rawValue: external.serviceName!)! {
//                case .GoogleAnalytics:
//                    external.googleAnalyticsKPI = objects.googleAnalyticsObject
//                case .SalesForce:
//                    external.saleForceKPI = objects.salesForceObject
//                default:
//                    break
//                }
//            }, failure: { error in
//                self.showAlert(title: "Sorry", errorMessage: error)
//            })
//        }
//        ))
//    }





