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
            case .GoogleAnalytics:
                navigationItem.title = "Google Analytics"
                switch (GoogleAnalyticsKPIs(rawValue: kpi.integratedKPI.kpiName!))! {
                case .UsersSessions:
                    tableViewChartVC.titleOfTable = ("Users/sessions","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
                case .AudienceOverview:
                    tableViewChartVC.titleOfTable = ("Users/sessions","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
                case .GoalOverview:
                    tableViewChartVC.titleOfTable = ("Goal Overview","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
                case .TopPagesByPageviews:
                    tableViewChartVC.titleOfTable = ("Top Pages","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
                case .TopSourcesBySessions:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
                case .TopOrganicKeywordsBySession:
                    tableViewChartVC.titleOfTable = ("Top Keywords","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
                case .TopChannelsBySessions:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
                case .RevenueTransactions:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
                case .EcommerceOverview:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
                case .RevenueByLandingPage:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
                case .RevenueByChannels:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
                case .TopKeywordsByRevenue:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
                case .TopSourcesByRevenue:
                    tableViewChartVC.titleOfTable = ("Top Source","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
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
        let request = GoogleAnalytics(oauthToken: (external?.oauthToken)!, oauthRefreshToken: (external?.oauthRefreshToken)!, oauthTokenExpiresAt: (external?.oauthTokenExpiresAt)! as Date)
        let param = ReportRequest()
        param.viewId = (external?.googleAnalyticsKPI?.viewID)!
        
        var ranges:[ReportRequest.DateRange] = []
        var metrics: [ReportRequest.Metric] = []
        var dimentions: [ReportRequest.Dimension] = []
        var cohorts: [ReportRequest.Cohort] = []
        
        switch (GoogleAnalyticsKPIs(rawValue: (external?.kpiName)!))! {
        case .UsersSessions:
            ranges.append(ReportRequest.DateRange(startDate: "2017-02-12", endDate: "2017-02-19"))
            metrics.append(ReportRequest.Metric(expression: "ga:users/ga:sessions", formattingType: .FLOAT))
        case .AudienceOverview:
            metrics.append(ReportRequest.Metric(expression: "ga:interestInMarketCategory", formattingType: .FLOAT))
            metrics.append(ReportRequest.Metric(expression: "ga:userAgeBracket", formattingType: .FLOAT))
            metrics.append(ReportRequest.Metric(expression: "ga:userGender", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:cohort"))
            cohorts.append(ReportRequest.Cohort(name: "chogort1", type: ReportRequest.CohortType.FIRST_VISIT_DATE, startDate: "2017-02-12", endDate: "2017-02-19")!)
        case .GoalOverview:
            ranges.append(ReportRequest.DateRange(startDate: "2017-02-12", endDate: "2017-02-19"))
            metrics.append(ReportRequest.Metric(expression: "ga:goalCompletionsAll", formattingType: .FLOAT))
        case .TopPagesByPageviews:
            ranges.append(ReportRequest.DateRange(startDate: "2017-02-12", endDate: "2017-02-19"))
            metrics.append(ReportRequest.Metric(expression: "ga:pageviews", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:pagePath"))
        case .TopSourcesBySessions:
            ranges.append(ReportRequest.DateRange(startDate: "2017-02-12", endDate: "2017-02-19"))
            metrics.append(ReportRequest.Metric(expression: "ga:sessions", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:source"))
        case .TopOrganicKeywordsBySession:
            ranges.append(ReportRequest.DateRange(startDate: "2017-02-12", endDate: "2017-02-19"))
            metrics.append(ReportRequest.Metric(expression: "ga:sessions", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:keyword"))
        case .TopChannelsBySessions:
            ranges.append(ReportRequest.DateRange(startDate: "2017-02-12", endDate: "2017-02-19"))
            metrics.append(ReportRequest.Metric(expression: "ga:sessions", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:channelGrouping"))
        case .RevenueTransactions:
            ranges.append(ReportRequest.DateRange(startDate: "2017-02-12", endDate: "2017-02-19"))
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue/ga:transactions", formattingType: .FLOAT))
        case .EcommerceOverview:
            ranges.append(ReportRequest.DateRange(startDate: "2017-02-12", endDate: "2017-02-19"))
            metrics.append(ReportRequest.Metric(expression: "ga:sessionsPerUser", formattingType: .FLOAT))
        case .RevenueByLandingPage:
            ranges.append(ReportRequest.DateRange(startDate: "2017-02-12", endDate: "2017-02-19"))
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:landingPagePath"))
        case .RevenueByChannels:
            ranges.append(ReportRequest.DateRange(startDate: "2017-02-12", endDate: "2017-02-19"))
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:channelGrouping"))
        case .TopKeywordsByRevenue:
            ranges.append(ReportRequest.DateRange(startDate: "2017-02-12", endDate: "2017-02-19"))
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:keyword"))
        case .TopSourcesByRevenue:
            ranges.append(ReportRequest.DateRange(startDate: "2017-02-12", endDate: "2017-02-19"))
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:source"))
        }
        
        param.dateRanges = ranges
        param.metrics = metrics
        param.dimensions = dimentions
        param.cohortGroup = ReportRequest.CohortGroup(cohorts: cohorts)
        
        request.getAnalytics(param: param, success: { report in
            success(report)
        }, failure: { error in
            if error == "401" {
                self.refreshAccessToken()
            }
        }
        )
    }
    
    //MARK: - crate data from request
    func createDataFromRequest(success: @escaping ([(leftValue: String, centralValue: String, rightValue: String)])->()) {
        
        var dataForPresent: [(leftValue: String, centralValue: String, rightValue: String)] = []
        
        switch (IntegratedServices(rawValue: kpi.integratedKPI.serviceName!))! {
        case .GoogleAnalytics:
            getGoogleAnalyticsData(success: { report in
                switch (GoogleAnalyticsKPIs(rawValue: self.kpi.integratedKPI.kpiName!))! {
                case .UsersSessions:
                    dataForPresent.append(("users", "", "\((report.data?.totals[0].values[0])!)"))
                    success(dataForPresent)
                case .AudienceOverview:
                    for i in 0..<(report.data?.rowCount)! {
                        let data = report.data?.rows[i]
                        dataForPresent.append(("\((data?.dimensions[0])!)", "", "\((data?.metrics[0].values[0])!)"))
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
                    for i in 0..<(report.data?.rowCount)! {
                        let data = report.data?.rows[i]
                        dataForPresent.append(("\((data?.dimensions[0])!)", "", "\((data?.metrics[0].values[0])!)"))
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
    
    //TODO: load data again
    //MARK: - refresh token method
    func refreshAccessToken() {
        let request = ExternalRequest(oauthToken: kpi.integratedKPI.oauthToken!, oauthRefreshToken: kpi.integratedKPI.oauthRefreshToken!, oauthTokenExpiresAt: kpi.integratedKPI.oauthTokenExpiresAt as! Date)
        request.updateAccessToken(servise: IntegratedServices(rawValue: kpi.integratedKPI.serviceName!)!, success: { accessToken in
            print(accessToken)
            self.kpi.integratedKPI.oauthToken = accessToken
            //self.getGoogleAnalyticsData(index: index, success: {})
        }, failure: { error in
            print(error)
            self.autorisationAgain(external: self.kpi.integratedKPI)
        }
        )
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
