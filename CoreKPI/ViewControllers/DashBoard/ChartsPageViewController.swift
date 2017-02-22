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
                
            case .Quickbooks:
                navigationItem.title = "Quickbooks"
                
                let kpiName = kpi.integratedKPI.kpiName!
                
                switch QiuckBooksKPIs(rawValue: kpiName)!
                {
                case .Balance:
                    tableViewChartVC.titleOfTable = (kpiName, "", "Value")
                    
                    createDataFromRequest(success: { dataToPresent in
                        tableViewChartVC.dataArray = dataToPresent
                        tableViewChartVC.tableView.reloadData()
                    })                    
                    
                default:
                    break
                }
                
            case .GoogleAnalytics:
                navigationItem.title = "Google Analytics"
                switch (GoogleAnalyticsKPIs(rawValue: kpi.integratedKPI.kpiName!))! {
                case .UsersSessions:
                    //tableViewChartVC.header = kpi.integratedKPI.kpiName!
                    tableViewChartVC.titleOfTable = ("Users/sessions","","Value")
                    //tableViewChartVC.index = 0
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
                    //return tableViewChartVC
                case .AudienceOverview:
                    tableViewChartVC.titleOfTable = ("Users/sessions","","Value")
                    showAlert(title: "Sorry", message: "Coming soon")
                    //return tableViewChartVC
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
                case .TopOrganicKeywordsBySession:
                    tableViewChartVC.titleOfTable = ("Top Keywords","","Value")
                    createDataFromRequest(success: { dataForPresent in
                        tableViewChartVC.dataArray = dataForPresent
                        tableViewChartVC.tableView.reloadData()
                    }
                    )
                    
                default:
                    break
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
        
        let ranges:[ReportRequest.DateRange] = [ReportRequest.DateRange(startDate: "2017-01-01", endDate: "2017-01-31")]
        var metrics: [ReportRequest.Metric] = []
        var dimentions: [ReportRequest.Dimension] = []
        
        switch (GoogleAnalyticsKPIs(rawValue: (external?.kpiName)!))! {
        case .UsersSessions:
            metrics.append(ReportRequest.Metric(expression: "ga:users/ga:sessions", formattingType: .FLOAT))
        case .AudienceOverview:
            metrics.append(ReportRequest.Metric(expression: "ga:sessionsPerUser", formattingType: .FLOAT))
        //TODO: уточнить у заказчика
        case .GoalOverview:
            metrics.append(ReportRequest.Metric(expression: "ga:goalCompletionsAll", formattingType: .FLOAT))
        case .TopPagesByPageviews:
            metrics.append(ReportRequest.Metric(expression: "ga:pageviews", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:pagePath"))
        case .TopSourcesBySessions:
            metrics.append(ReportRequest.Metric(expression: "ga:sessions", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:source"))
        case .TopOrganicKeywordsBySession:
            metrics.append(ReportRequest.Metric(expression: "ga:sessions", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:keyword"))
        case .TopChannelsBySessions:
            metrics.append(ReportRequest.Metric(expression: "ga:sessions", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:channelGrouping"))
        case .RevenueTransactions:
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue/ga:transactions", formattingType: .FLOAT))
        case .EcommerceOverview:
            metrics.append(ReportRequest.Metric(expression: "ga:sessionsPerUser", formattingType: .FLOAT))
        case .RevenueByLandingPage:
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:landingPagePath"))
        case .RevenueByChannels:
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:channelGrouping"))
        case .TopKeywordsByRevenue:
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:keyword"))
        case .TopSourcesByRevenue:
            metrics.append(ReportRequest.Metric(expression: "ga:totalValue", formattingType: .FLOAT))
            dimentions.append(ReportRequest.Dimension(name: "ga:source"))
        }
        
        param.dateRanges = ranges
        param.metrics = metrics
        
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
            
        case .Quickbooks:
            dataForPresent.append(contentsOf: QuickBookDataManager.shared().getInfoFor(kpi: .Balance))
            
            success(dataForPresent)
            
        case .GoogleAnalytics:
            getGoogleAnalyticsData(success: { report in
                switch (GoogleAnalyticsKPIs(rawValue: self.kpi.integratedKPI.kpiName!))! {
                case .UsersSessions:
                    for _ in 0..<(report.data?.rowCount)! {
                        for data in (report.data?.totals)! {
                            dataForPresent.append(("Users", "", "\(data.values[0])"))
                        }
                    }
                    success(dataForPresent)
                case .AudienceOverview:
                    break //TODO: AudienceOverview
                case .GoalOverview:
                    for _ in 0..<(report.data?.rowCount)! {
                        for data in (report.data?.totals)! {
                            dataForPresent.append(("Goal", "", "\(data.values[0])"))
                        }
                    }
                    success(dataForPresent)
                case .TopPagesByPageviews:
                    for _ in 0..<(report.data?.rowCount)! {
                        for data in (report.data?.totals)! {
                            dataForPresent.append(("Goal", "", "\(data.values[0])"))
                        }
                    }
                    success(dataForPresent)
                case .TopSourcesBySessions:
                    break //TODO: доделать
                default:
                    break
                }
            })
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
