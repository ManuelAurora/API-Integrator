//
//  ChartsPageViewController.swift
//  CoreKPI
//
//  Created by Семен on 17.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class ChartsPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var kpi: KPI!
    var quickBooksDataManager = QuickBookDataManager.shared()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("DEBUG: Did Appear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        self.setViewControllers([getViewController(AtIndex: 0)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.white    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
      //TODO: quickBooksDataManager.balanceSheet.removeAll()
    }
    
    // MARK:- UIPageViewControllerDataSource Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        var index = returnIndexForVC(vc: viewController)
        if (index == 0) || index == NSNotFound {
            return nil
        }
        
        index -= 1
        return getViewController(AtIndex: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        if self.kpi.typeOfKPI == .IntegratedKPI {
            return nil
        }
        
        var index = returnIndexForVC(vc: viewController)
        if (index == NSNotFound) || (index == 1) {
            return nil
        }
        index += 1
        return getViewController(AtIndex: index)
    }
    
    // MARK:- Other Methods
    func getViewController(AtIndex index: Int) -> UIViewController {
        let webViewChartOneVC = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewChartViewController
        let webViewChartTwoVC = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewChartViewController
        let tableViewChartVC = storyboard?.instantiateViewController(withIdentifier: "TableViewController") as! TableViewChartController
        
        switch kpi.typeOfKPI {
        case .createdKPI:
            navigationItem.title = "Report"
            
            if kpi.KPIViewOne == .Numbers && kpi.KPIViewTwo == .Graph {
                for i in (kpi.createdKPI?.number)! {
                    tableViewChartVC.reportArray.append(i)
                }
                tableViewChartVC.header = (kpi.createdKPI?.KPI)!
                tableViewChartVC.index = 0
                webViewChartOneVC.typeOfChart = kpi.KPIChartTwo!
                webViewChartOneVC.index = 1
                switch index {
                case 0:
                    return tableViewChartVC
                case 1:
                    return webViewChartOneVC
                default:
                    break
                }
            }
            if kpi.KPIViewOne == .Graph && kpi.KPIViewTwo == .Numbers {
                webViewChartOneVC.typeOfChart = kpi.KPIChartOne!
                webViewChartOneVC.index = 0
                for i in (kpi.createdKPI?.number)! {
                    tableViewChartVC.reportArray.append(i)
                }
                tableViewChartVC.header = (kpi.createdKPI?.KPI)!
                tableViewChartVC.index = 1
                switch index {
                case 0:
                    return webViewChartOneVC
                case 1:
                    return tableViewChartVC
                default:
                    break
                }
            }
            if kpi.KPIViewOne == .Graph && kpi.KPIViewTwo == .Graph {
                
                webViewChartOneVC.typeOfChart = kpi.KPIChartOne!
                webViewChartOneVC.index = 0
                
                webViewChartTwoVC.typeOfChart = kpi.KPIChartTwo!
                webViewChartTwoVC.index = 1
                switch index {
                case 0:
                    return webViewChartOneVC
                case 1:
                    return webViewChartTwoVC
                default:
                    break
                }
            }
        case .IntegratedKPI:
            
            tableViewChartVC.typeOfKPI = .IntegratedKPI
            
            //debug->
            tableViewChartVC.header = kpi.integratedKPI.kpiName!
            tableViewChartVC.index = 0
            //<-debug
            
            switch (IntegratedServices(rawValue: kpi.integratedKPI.serviceName!))! {
                
            case .Quickbooks:
                navigationItem.title = "Quickbooks"
                
                let kpiName = kpi.integratedKPI.kpiName!
                let kpiValue = QiuckBooksKPIs(rawValue: kpiName)!
                
                //TODO: Refine, too much repeated code!
                
                switch kpiValue
                {
                case .Invoices:
                    let method = QBQuery(with: [:])
                    
                    tableViewChartVC.titleOfTable = (kpiName, "", "Value")
                    quickBooksDataManager.listOfRequests.append((kpi.integratedKPI.requestJsonString!, method, kpiName: kpiValue))
                    
                    createDataFromRequestWith(qBMethod: method, success: { _ in
                        tableViewChartVC.kpiName = kpiValue
                        tableViewChartVC.qBMethod = .query
                    })
                    
                    return tableViewChartVC
                    
                case .Balance:
                    let method = QBBalanceSheet(with: [:])
                    
                    tableViewChartVC.titleOfTable = (kpiName, "", "Value")
                    quickBooksDataManager.listOfRequests.append((kpi.integratedKPI.requestJsonString!, method, kpiName: kpiValue))
                    
                    createDataFromRequestWith(qBMethod: method, success: { _ in
                        tableViewChartVC.qBMethod = .balanceSheet
                    })                    
                    
                    return tableViewChartVC
                    
                case .BalanceByBankAccounts:
                    let method = QBAccountList(with: [:])
                    
                    tableViewChartVC.titleOfTable = (kpiName, "", "Value")
                    quickBooksDataManager.listOfRequests.append((kpi.integratedKPI.requestJsonString!, method, kpiName: kpiValue))
                    
                    createDataFromRequestWith(qBMethod: method, success: { _ in
                        tableViewChartVC.qBMethod = .accountList
                    })
                    
                    return tableViewChartVC
                    
                case .IncomeProfitKPIs:
                    let method = QBProfitAndLoss(with: [:])
                    
                    tableViewChartVC.titleOfTable = (kpiName, "", "Value")
                    quickBooksDataManager.listOfRequests.append((kpi.integratedKPI.requestJsonString!, method, kpiName: kpiValue))
                    
                    createDataFromRequestWith(qBMethod: method, success: { _ in
                        tableViewChartVC.qBMethod = .profitLoss
                    })
                    
                    return tableViewChartVC
                    
                case .PaidExpenses:
                    let method = QBPaidExpenses(with: [:])
                    
                    tableViewChartVC.titleOfTable = (kpiName, "", "Value")
                    quickBooksDataManager.listOfRequests.append((kpi.integratedKPI.requestJsonString!, method, kpiName: kpiValue))
                    
                    createDataFromRequestWith(qBMethod: method, success: { _ in
                        tableViewChartVC.qBMethod = .paidExpenses
                    })
                    
                    return tableViewChartVC
                    
                case .PaidInvoicesByCustomers:
                    let method = QBPaidInvoicesByCustomers(with: [:])
                    
                    tableViewChartVC.titleOfTable = (kpiName, "", "Value")
                    quickBooksDataManager.listOfRequests.append((kpi.integratedKPI.requestJsonString!, method, kpiName: kpiValue))
                    
                    createDataFromRequestWith(qBMethod: method, success: { _ in
                        tableViewChartVC.qBMethod = .paidInvoicesByCustomers
                    })
                    
                    return tableViewChartVC
                    
                case .NetIncome:
                    let method = QBQuery(with: [:])
                    
                    tableViewChartVC.titleOfTable = (kpiName, "", "Value")
                    quickBooksDataManager.listOfRequests.append((kpi.integratedKPI.requestJsonString!, method, kpiName: kpiValue))
                    
                    createDataFromRequestWith(qBMethod: method, success: { _ in
                        tableViewChartVC.kpiName = kpiValue
                        tableViewChartVC.qBMethod = .query
                    })
                    
                    return tableViewChartVC
                    
                case .OverdueCustomers:
                    let method = QBQuery(with: [:])
                    
                    tableViewChartVC.titleOfTable = (kpiName, "", "Value")
                    quickBooksDataManager.listOfRequests.append((kpi.integratedKPI.requestJsonString!, method, kpiName: kpiValue))
                    
                    createDataFromRequestWith(qBMethod: method, success: { _ in
                        tableViewChartVC.kpiName = kpiValue
                        tableViewChartVC.qBMethod = .query
                    })
                    
                    return tableViewChartVC
                    
                case .PaidInvoices:
                    let method = QBQuery(with: [:])
                    
                    tableViewChartVC.titleOfTable = (kpiName, "", "Value")
                    quickBooksDataManager.listOfRequests.append((kpi.integratedKPI.requestJsonString!, method, kpiName: kpiValue))
                    
                    createDataFromRequestWith(qBMethod: method, success: { _ in
                        tableViewChartVC.kpiName = kpiValue
                        tableViewChartVC.qBMethod = .query
                    })
                    
                    return tableViewChartVC
                    
                    
                case .NonPaidInvoices:
                    let method = QBQuery(with: [:])
                    
                    tableViewChartVC.titleOfTable = (kpiName, "", "Value")
                    quickBooksDataManager.listOfRequests.append((kpi.integratedKPI.requestJsonString!, method, kpiName: kpiValue))
                    
                    createDataFromRequestWith(qBMethod: method, success: { _ in
                        tableViewChartVC.kpiName = kpiValue
                        tableViewChartVC.qBMethod = .query
                    })
                    
                    return tableViewChartVC
                 
                case .OpenInvoicesByCustomers:
                    let method = QBQuery(with: [:])
                    
                    tableViewChartVC.titleOfTable = (kpiName, "", "Value")
                    quickBooksDataManager.listOfRequests.append((kpi.integratedKPI.requestJsonString!, method, kpiName: kpiValue))
                    
                    createDataFromRequestWith(qBMethod: method, success: { _ in
                        tableViewChartVC.kpiName = kpiValue
                        tableViewChartVC.qBMethod = .query
                    })
                    
                     return tableViewChartVC
               
                }
                
            case .GoogleAnalytics:
                navigationItem.title = "Google Analytics"
                switch (GoogleAnalyticsKPIs(rawValue: kpi.integratedKPI.kpiName!))! {
                case .UsersSessions:
                    tableViewChartVC.titleOfTable = ("Date","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    })
                case .AudienceOverview:
                    tableViewChartVC.titleOfTable = ("Ages","Genders","Market category")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    })
                case .GoalOverview:
                    tableViewChartVC.titleOfTable = ("Goal Overview","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    })
                case .TopPagesByPageviews:
                    tableViewChartVC.titleOfTable = ("Top Pages","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    })
                case .TopSourcesBySessions:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    })
                case .TopOrganicKeywordsBySession:
                    tableViewChartVC.titleOfTable = ("Top Keywords","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    })
                case .TopChannelsBySessions:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    })
                case .RevenueTransactions:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    })
                case .EcommerceOverview:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    })
                case .RevenueByLandingPage:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    })
                case .RevenueByChannels:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    })
                case .TopKeywordsByRevenue:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    })
                case .TopSourcesByRevenue:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    })
                }
                //debug->
                return tableViewChartVC
                //<-debug
            default:
                break
            }
        }
        return UIViewController()
    }
    
    func returnIndexForVC(vc: UIViewController) -> Int {
        if let webVC: WebViewChartViewController = vc as? WebViewChartViewController {
            return webVC.index
        }
        if let tableVC: TableViewChartController = vc as? TableViewChartController {
            return tableVC.index
        }
        return 0
    }
    
    func setIndexForVC(vc: UIViewController, index: Int) {
        if let webVC: WebViewChartViewController = vc as? WebViewChartViewController {
            webVC.index = index
        }
        if let tableVC: TableViewChartController = vc as? TableViewChartController {
            tableVC.index = index
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
    
}

//load data from external services
extension ChartsPageViewController {
    
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
                self.autorisationAgain(external: external!)
            }
        })
    }
    
    //MARK: - crate data from request
    func createDataFromRequestWith(qBMethod: QuickBookMethod?, success: @escaping () -> ()) {
        
        //var dataForPresent: [(leftValue: String, centralValue: String, rightValue: String)] = []
        
         quickBooksDataManager.doOAuthQuickbooks {
            self.quickBooksDataManager.fetchDataFromIntuit(isCreation: false)
            
            success()
        }
    }
    
    func createDataFromRequest(success: @escaping ([(leftValue: String, centralValue: String, rightValue: String)])->()) {
        
        var dataForPresent: [(leftValue: String, centralValue: String, rightValue: String)] = []
        
        switch (IntegratedServices(rawValue: kpi.integratedKPI.serviceName!))! {
            
        case .GoogleAnalytics:
            getGoogleAnalyticsData(success: { report in
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
        default:
            break
        }
    }
    
    //MARK: - Autorisation again method
    func autorisationAgain(external: ExternalKPI) {
        let alertVC = UIAlertController(title: "Sorry", message: "You should autorisation again", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            let request = ExternalRequest()
            request.oAuthAutorisation(servise: IntegratedServices(rawValue: external.serviceName!)!, viewController: self, success: { credential in
                external.setValue(credential.oauthToken, forKey: "oauthToken")
                external.setValue(credential.oauthRefreshToken, forKey: "oauthRefreshToken")
                external.setValue(credential.oauthTokenExpiresAt, forKey: "oauthTokenExpiresAt")
            }, failure: { error in
                self.showAlert(title: "Sorry", message: error)
            }
            )
        }
        ))
    }
    
    //MARK: - Show alert method
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

}
