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
    let hubspotDataManager = HubSpotManager.sharedInstance
    let salesForceDataManager = SalesforceRequestManager.shared
    
    var dataToPresent = resultArray()
    
    private func createDataFromRequestWith(qBMethod: QuickBookMethod?) {
        
        self.quickBooksDataManager.fetchDataFromIntuit(isCreation: false)
    }
    
    func dataForReport() {
        
        let kpiName  = kpi.integratedKPI.kpiName!
        integratedServicesDataManager.kpi = kpi
        
        switch (IntegratedServices(rawValue: kpi.integratedKPI.serviceName!))!
        {
        case .SalesForce:
            salesForceDataManager.requestData()
            
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
            
            let realmId = kpi.integratedKPI.quickbooksKPI?.realmId
            
            quickBooksDataManager.companyID = realmId!
            quickBooksDataManager.formListOfRequests(from: [(SettingName: kpiName,
                                                             value: true)])
            createDataFromRequestWith(qBMethod: method)
            
        case .PayPal:
            integratedServicesDataManager.createDataFromRequest(success: {
                dataForPresent in
                self.dataToPresent.append(contentsOf: dataForPresent)
                NotificationCenter.default.post(name: .paypalManagerRecievedData,
                                                object: nil)
            })
            
        case .GoogleAnalytics:
            integratedServicesDataManager.kpi = kpi
            integratedServicesDataManager.createDataFromRequest(success: {
                dataForPresent in
                self.dataToPresent = dataForPresent
                NotificationCenter.default.post(name: .googleManagerRecievedData,
                                                object: nil)
            })
            
        case .HubSpotCRM, .HubSpotMarketing:
            hubspotDataManager.connect()            
            
        default: break
        }
    }
}

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

