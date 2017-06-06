//
//  ChartsPageViewController.swift
//  CoreKPI
//
//  Created by Семен on 17.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire

class ChartsPageViewController:
    UIPageViewController, StoryboardInstantiation,
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate
{
    
    var kpi: KPI!
    let stateMachine = UserStateMachine.shared
    let nCenter = NotificationCenter.default
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(self.handleRefresh),
                     for: UIControlEvents.valueChanged)
        rc.tintColor = .clear
        return rc
    }()
    
    lazy var reportDataManipulator = {
        return ReportDataManipulator()
    }()
    
    lazy var webViewChartOneVC = WebViewChartViewController.storyboardInstance()
    lazy var webViewChartTwoVC = WebViewChartViewController.storyboardInstance()
    lazy var tableViewChartVC  = TableViewChartController.storyboardInstance()
    
    private var dataToPresent: resultArray {
        return reportDataManipulator.dataToPresent
    }
    
    var providedControllers = [UIViewController]()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        removeWaitingSpinner()
        print("DEBUG: ChartPageVC deinitialized")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeAllAlamofireNetworking()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate   = self
        dataSource = self
        navigationItem.title = "Reports"
        tableViewChartVC.refreshControl = refreshControl
        
        if kpi.createdKPI != nil
        {
            addWaitingSpinner(at: view.center, color: OurColors.cyan)
        }
        else
        {
            formData()
        }
        
        subscribeToNotifications()
        setInitialViewControllers()
        
        self.setViewControllers([providedControllers[0]],
                                direction: UIPageViewControllerNavigationDirection.forward,
                                animated: false,
                                completion: nil)
        
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.backgroundColor = .white
    }
    
    private func setInitialViewControllers() {
        
        if  firstReportIsTable() { providedControllers.append(tableViewChartVC)  }
        else if kpi.integratedKPI == nil { providedControllers.append(webViewChartOneVC) }
        
        if kpi.KPIChartTwo == nil
        {
            providedControllers.append(tableViewChartVC)
        }
        else
        {
            providedControllers.append(webViewChartTwoVC)
        }
    }
    
    // MARK:- UIPageViewControllerDataSource & delegate Methods
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return providedControllers[0] == viewController ? nil : providedControllers[0]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if providedControllers.count > 1, providedControllers[1] != viewController
        {
            guard let vc = providedControllers[1] as? WebViewChartViewController
                else { return providedControllers[1] as? TableViewChartController
            }
            
            return vc.isAllowed ? vc : nil
        }        
        return nil
    }
    
    // MARK:- Other Methods
    @objc private func handleRefresh() {
        
        guard refreshControl.isRefreshing else { return }
        
        tableViewChartVC.dataArray.removeAll()
        tableViewChartVC.reportArray.removeAll()
        webViewChartOneVC.lineChartData.removeAll()
        webViewChartOneVC.pieChartData.removeAll()
        webViewChartOneVC.rawDataArray.removeAll()
        webViewChartTwoVC.rawDataArray.removeAll()
        reportDataManipulator.dataToPresent.removeAll()
        
        formData()
        tableViewChartVC.reloadTableView()
                
        if kpi.typeOfKPI == .createdKPI
        {
            removeWaitingSpinner()
            refreshControl.endRefreshing()
        }
    }
    
    private func firstReportIsTable() -> Bool
    {
        if kpi.typeOfKPI == .createdKPI
        {
            return kpi.KPIViewOne == .Numbers
        }
        else
        {
            return kpi.KPIViewOne == .Numbers && !webViewChartTwoVC.isAllowed
        }
    }
    
    private func formData() {
        
        if let table = kpi.createdKPI?.number
        {
            
            table.forEach {
                let webChartObj = (leftValue:    "\($0.date)",
                                   centralValue: "",
                                   rightValue:   "\($0.number)")
                
                tableViewChartVC.reportArray.append($0)
                webViewChartTwoVC.rawDataArray.append(webChartObj)
                webViewChartOneVC.rawDataArray.append(webChartObj)
            }
        }
        
        switch kpi.typeOfKPI
        {
        case .createdKPI:
            tableViewChartVC.header = kpi.createdKPI?.KPI ?? ""
            
            if !firstReportIsTable()
            {
                webViewChartOneVC.typeOfChart = kpi.KPIChartOne!
                webViewChartOneVC.isAllowed = true
            }
            
            if kpi.KPIChartTwo != nil
            {
                webViewChartTwoVC.isAllowed = true
                webViewChartTwoVC.typeOfChart = kpi.KPIChartTwo!
            }           
            
        case .IntegratedKPI:
            tableViewChartVC.typeOfKPI = .IntegratedKPI
            
            let kpiName     = kpi.integratedKPI.kpiName!
            let serviceName = kpi.integratedKPI.serviceName!
            let service     = IntegratedServices(rawValue: serviceName)!
            
            var chart: TypeOfChart = .PieChart
            
            webViewChartTwoVC.isAllowed = true
            
            switch service
            {
            case .PayPal:
                let kpiValue = PayPalKPIs(rawValue: kpiName)!
                
                switch kpiValue
                {
                case .TransactionsByStatus, .PendingByType: chart = .PieChart
                case .NetSales, .TotalSales: chart = .LineChart
                default: webViewChartTwoVC.isAllowed = false; break
                }
                
            case .Quickbooks:
                let kpiValue = QiuckBooksKPIs(rawValue: kpiName)!
                
                switch kpiValue
                {
                case .NetIncome: chart = .LineChart
                case .NonPaidInvoices, .PaidInvoices: chart = .PieChart
                default: webViewChartTwoVC.isAllowed = false; break
                }
                
            case .GoogleAnalytics:
                let kpiValue = GoogleAnalyticsKPIs(rawValue: kpiName)!
                
                switch kpiValue
                {
                case .TopChannelsBySessions, .RevenueByChannels: chart = .PieChart
                case .RevenueTransactions, .UsersSessions:       chart = .LineChart
                default: webViewChartTwoVC.isAllowed = false; break
                }
                
            case .HubSpotCRM:
                let kpiValue = HubSpotCRMKPIs(rawValue: kpiName)!
                
                switch kpiValue
                {
                case .DealsRevenue: chart = .LineChart
                case .SalesFunnel: chart = .Funnel
                case .DealsClosedWonAndLost: chart = .PieChart
                default: webViewChartTwoVC.isAllowed = false; break
                }
                
            case .HubSpotMarketing:
                let kpiValue = HubSpotMarketingKPIs(rawValue: kpiName)!
                
                switch kpiValue
                {
                case .VisitsContacts:  chart = .LineChart
                case .MarketingFunnel: chart = .Funnel
                default: webViewChartTwoVC.isAllowed = false; break
                }
                
            case .SalesForce:
                let kpiValue = SalesForceKPIs(rawValue: kpiName)!
                
                switch kpiValue
                {
                case .RevenueNewLeads:          chart = .LineChart
                case .ConvertedLeads:           chart = .PositiveBar
                case .OpenOpportunitiesByStage: chart = .PieChart
                default: webViewChartTwoVC.isAllowed = false; break
                }            
                
            default: break
            }
            
            if firstReportIsTable() { tableViewChartVC.header  = kpiName }
            else                    { webViewChartOneVC.header = kpiName }
            
            webViewChartTwoVC.typeOfChart = chart
            webViewChartTwoVC.header  = kpiName
            reportDataManipulator.kpi = kpi
            reportDataManipulator.dataForReport()
            
            let point = view.center
            
            addWaitingSpinner(at: point, color: OurColors.cyan)
        }
    }
    
    private func subscribeToNotifications() {
        
        nCenter.addObserver(self,
                            selector: #selector(self.prepareDataForReportFromQB),
                            name: .qbManagerRecievedData,
                            object: nil)
        
        nCenter.addObserver(self,
                            selector: #selector(self.prepareDataForReportFromPayPal),
                            name: .paypalManagerRecievedData,
                            object: nil)
        
        nCenter.addObserver(self,
                            selector: #selector(self.prepareDataForReportFromGA),
                            name: .googleManagerRecievedData,
                            object: nil)
        
        nCenter.addObserver(self,
                            selector: #selector(self.prepareDataForReportFromHubspot),
                            name: .hubspotManagerRecievedData,
                            object: nil)
        
        nCenter.addObserver(self,
                            selector: #selector(self.prepareDataForReportFromSalesForce),
                            name: .salesForceManagerRecievedData,
                            object: nil)
        
        nCenter.addObserver(forName: .errorDownloadingFile,
                            object: nil,
                            queue: nil) {
                                [weak self] _ in
                                self?.removeWaitingSpinner()
                                self?.refreshControl.endRefreshing()
        }
        
        nCenter.addObserver(forName: .internetConnectionLost,
                            object: nil,
                            queue: nil) {
                                [weak self] _ in
                                self?.removeWaitingSpinner()
                                self?.refreshControl.endRefreshing()
                                self?.showAlert(title: "Error Occured",
                                                errorMessage: "Please, check your internet connection")
        }
        
        nCenter.addObserver(forName: .reportDataForKpiRecieved,
                            object: nil,
                            queue: nil) {
                                [weak self] _ in
                                self?.formData()
                                self?.removeWaitingSpinner()
                                self?.tableViewChartVC.reloadTableView()
                                self?.webViewChartOneVC.refreshView()
                                self?.webViewChartTwoVC.refreshView()
        }
    }
    
    @objc private func prepareDataForReportFromSalesForce() {
        
        removeWaitingSpinner()
        refreshControl.endRefreshing()
        
        var data: resultArray = []
        
        let sfManager = reportDataManipulator.salesForceDataManager
        
        if let kpiName = kpi.integratedKPI.kpiName
        {
            if let kpiValue = SalesForceKPIs(rawValue: kpiName)
            {
                data = sfManager.getDataForChart(kpi: kpiValue)
            }
        }
        
        if webViewChartTwoVC.isAllowed
        {
            webViewChartTwoVC.service = .SalesForce
            webViewChartTwoVC.rawDataArray.append(contentsOf: data)
            webViewChartTwoVC.refreshView()
        }
        else
        {
            tableViewChartVC.dataArray = data
            tableViewChartVC.reloadTableView()
        }
    }
    
    @objc private func prepareDataForReportFromHubspot() {
        
        removeWaitingSpinner()
        refreshControl.endRefreshing()
        var data: resultArray = []
        
        let hsManager  = reportDataManipulator.hubspotDataManager
        let pipeLineId = kpi.integratedKPI.hsPipelineID
        let kpiName    = kpi.integratedKPI.kpiName!
        
        if let kpiName  = kpi.integratedKPI.kpiName
        {
            if let kpiValue = HubSpotCRMKPIs(rawValue: kpiName)
            {
                data = hsManager.getDataForReport(kpi: kpiValue,
                                                  pipelineId: pipeLineId)
            }
            else if let kpiValue = HubSpotMarketingKPIs(rawValue: kpiName)
            {
                data = hsManager.getDataForReport(kpi: kpiValue,
                                                  pipelineId: pipeLineId)
            }
            
            tableViewChartVC.dataArray.append(contentsOf: data)
            tableViewChartVC.reloadTableView()
        }
        
        if webViewChartTwoVC.isAllowed
        {
            if let _ = HubSpotCRMKPIs(rawValue: kpiName)
            {
                webViewChartTwoVC.service = .HubSpotCRM
            }
            else if let _ = HubSpotMarketingKPIs(rawValue: kpiName)
            {
                webViewChartTwoVC.service = .HubSpotMarketing
            }
            
            webViewChartTwoVC.rawDataArray.append(contentsOf: data)
            webViewChartTwoVC.refreshView()
        }
        
        if webViewChartOneVC.isAllowed
        {
            webViewChartTwoVC.service = .HubSpotCRM
            webViewChartOneVC.rawDataArray.append(contentsOf: data)
            webViewChartOneVC.refreshView()
        }
    }
 
    @objc private func prepareDataForReportFromGA() {
        
        removeWaitingSpinner()
        refreshControl.endRefreshing()
        
        tableViewChartVC.dataArray.append(contentsOf: dataToPresent)
        tableViewChartVC.reloadTableView()
        
        if webViewChartTwoVC.isAllowed
        {
            webViewChartTwoVC.service = .GoogleAnalytics
            webViewChartTwoVC.rawDataArray.append(contentsOf: dataToPresent)
            webViewChartTwoVC.refreshView()
        }
        
        if webViewChartOneVC.isAllowed
        {
            webViewChartTwoVC.service = .GoogleAnalytics
            webViewChartOneVC.rawDataArray.append(contentsOf: dataToPresent)
            webViewChartOneVC.refreshView()
        }
    }
    
    @objc private func prepareDataForReportFromPayPal() {
        
        removeWaitingSpinner()
        refreshControl.endRefreshing()
        
        tableViewChartVC.dataArray.append(contentsOf: dataToPresent)
        tableViewChartVC.reloadTableView()
        
        if webViewChartTwoVC.isAllowed 
        {
            webViewChartTwoVC.service = .PayPal
            webViewChartTwoVC.rawDataArray.append(contentsOf: dataToPresent)
            webViewChartTwoVC.refreshView()
        }
        
        if webViewChartOneVC.isAllowed
        {
            webViewChartTwoVC.service = .PayPal
            webViewChartOneVC.rawDataArray.append(contentsOf: dataToPresent)
            webViewChartOneVC.refreshView()
        }
    }
    
    @objc private func prepareDataForReportFromQB() {
        
        removeWaitingSpinner()
        refreshControl.endRefreshing()
        
        let qbManager = reportDataManipulator.quickBooksDataManager
        let kpiName  = kpi.integratedKPI.kpiName!
        let kpiValue = QiuckBooksKPIs(rawValue: kpiName)!
        let data     = qbManager.dataFor(kpi: kpiValue)
        
        tableViewChartVC.dataArray.append(contentsOf: data)
        tableViewChartVC.reloadTableView()
        
        if webViewChartTwoVC.isAllowed
        {
            webViewChartTwoVC.service = .Quickbooks
            webViewChartTwoVC.rawDataArray.append(contentsOf: data)
            webViewChartTwoVC.refreshView()
        }
        
        if webViewChartOneVC.isAllowed
        {
            webViewChartTwoVC.service = .Quickbooks
            webViewChartOneVC.rawDataArray.append(contentsOf: data)
            webViewChartOneVC.refreshView()
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationController?.navigationBar.backgroundColor = .clear
    }    
}

//load data from external services
extension ChartsPageViewController {
    
    //MARK: - Autorisation again method
    func autorisationAgain(external: ExternalKPI) {
        let alertVC = UIAlertController(title: "Error Occured", message: "You should autorize again", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            let request = ExternalRequest()
            request.oAuthAutorisation(servise: IntegratedServices(rawValue: external.serviceName!)!, viewController: self, success: { objects in
                switch IntegratedServices(rawValue: external.serviceName!)! {
                case .GoogleAnalytics:
                    let siteURL = objects.googleAnalyticsObject?.siteURL
                    let entity = GAnalytics.googleAnalyticsEntity(for: siteURL)
                    external.googleAnalyticsKPI = entity
                    
                case .SalesForce:
                    external.saleForceKPI = objects.salesForceObject
                default:
                    break
                }
            }, failure: { error in
                self.showAlert(title: "Error Occured", errorMessage: error)
            })
        }))
    }
}
