//
//  ChartsPageViewController.swift
//  CoreKPI
//
//  Created by Семен on 17.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit
import OAuthSwift
import OAuthSwiftAlamofire
import Alamofire

class ChartsPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var kpi: KPI!
    let stateMachine = UserStateMachine.shared
    let nCenter = NotificationCenter.default
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(self.handleRefresh), for: UIControlEvents.valueChanged)
        rc.tintColor = .clear
        return rc
    }()
    
    lazy var reportDataManipulator = {
        return ReportDataManipulator()
    }()
    
    lazy var webViewChartOneVC: WebViewChartViewController =  {
        return self.storyboard?.instantiateViewController(withIdentifier: .webViewController) as! WebViewChartViewController
    }()
    
    lazy var webViewChartTwoVC: WebViewChartViewController = {
        return self.storyboard?.instantiateViewController(withIdentifier: .webViewController) as! WebViewChartViewController
    }()
    
    lazy var tableViewChartVC: TableViewChartController = {
        return self.storyboard?.instantiateViewController(withIdentifier: .chartTableVC) as! TableViewChartController
    }()
    
    var providedControllers = [UIViewController]()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        Alamofire.SessionManager.default.session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
        
        removeWaitingSpinner()
        print("DEBUG: ChartPageVC deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate   = self
        dataSource = self
        navigationItem.title = "Reports"
        tableViewChartVC.refreshControl = refreshControl
        
        formData()
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
        
        providedControllers.append(webViewChartTwoVC)
    }
    
    // MARK:- UIPageViewControllerDataSource & delegate Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return providedControllers[0] == viewController ? nil : providedControllers[0]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if providedControllers.count > 1, providedControllers[1] != viewController
        {
            guard let vc = providedControllers[1] as? WebViewChartViewController else { return nil }
            
            return vc.isAllowed ? vc : nil
        }        
        return nil
    }
    
    // MARK:- Other Methods
    @objc private func handleRefresh() {
        
        tableViewChartVC.dataArray.removeAll()
        tableViewChartVC.reportArray.removeAll()
        webViewChartOneVC.lineChartData.removeAll()
        webViewChartOneVC.pieChartData.removeAll()
        webViewChartOneVC.rawDataArray.removeAll()
        webViewChartTwoVC.rawDataArray.removeAll()
        reportDataManipulator.dataToPresent.removeAll()
        
        tableViewChartVC.reloadTableView()
        formData()
    }
    
    private func firstReportIsTable() -> Bool
    {
        return kpi.KPIViewOne == .Numbers && !webViewChartTwoVC.isAllowed
    }
    
    private func formData() {
        
        switch kpi.typeOfKPI
        {
        case .createdKPI:
            if firstReportIsTable()
            {
                kpi.createdKPI?.number.forEach { tableViewChartVC.reportArray.append($0) }
                tableViewChartVC.header = kpi.createdKPI?.KPI ?? ""
            }
            else { webViewChartOneVC.typeOfChart = kpi.KPIChartOne!; webViewChartOneVC.isAllowed = true }
            
            webViewChartTwoVC.isAllowed = true
            webViewChartTwoVC.typeOfChart = kpi.KPIChartTwo!
            
        case .IntegratedKPI:
            tableViewChartVC.typeOfKPI = .IntegratedKPI
            
            let kpiName  = kpi.integratedKPI.kpiName!
            let service  = IntegratedServices(rawValue: kpi.integratedKPI.serviceName!)!
            
            var chart: TypeOfChart = .PieChart
            webViewChartTwoVC.isAllowed = true
            
            switch service
            {
            case .PayPal:
                let kpiValue = PayPalKPIs(rawValue: kpiName)!
                
                switch kpiValue
                {
                case .TransactionsByStatus, .PendingByType: chart = .PieChart
                case .NetSalesTotalSales: chart = .LineChart
                default: break
                }
                
            case .Quickbooks:
                let kpiValue = QiuckBooksKPIs(rawValue: kpiName)!
                
                switch kpiValue
                {
                case .NetIncome: chart = .LineChart
                case .NonPaidInvoices, .PaidInvoices: chart = .PieChart
                default: break
                }
                
            case .GoogleAnalytics:
                let kpiValue = GoogleAnalyticsKPIs(rawValue: kpiName)!
                
                switch kpiValue
                {
                case .TopChannelsBySessions, .RevenueByChannels: chart = .PieChart
                case .RevenueTransactions, .UsersSessions:       chart = .LineChart
                default: break
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
                case .VisitsContacts: chart = .LineChart
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
            
            var point = view.center
            point.y -= 80
            
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
        
        nCenter.addObserver(forName: .errorDownloadingFile, object: nil, queue: nil) {
            [weak self] _ in
            self?.removeWaitingSpinner()
            self?.refreshControl.endRefreshing()
        }
    }
    
    @objc private func prepareDataForReportFromHubspot() {
        
        removeWaitingSpinner()
        refreshControl.endRefreshing()
        var data: resultArray = []
        
        if let kpiName  = kpi.integratedKPI.kpiName
        {
            if let kpiValue = HubSpotCRMKPIs(rawValue: kpiName)
            {
                data = reportDataManipulator.hubspotDataManager.getDataForReport(kpi: kpiValue,
                                                                                 pipelineId: kpi.integratedKPI.hsPipelineID)
            }
            else if let kpiValue = HubSpotMarketingKPIs(rawValue: kpiName)
            {
                data = reportDataManipulator.hubspotDataManager.getDataForReport(kpi: kpiValue,
                                                                                 pipelineId: kpi.integratedKPI.hsPipelineID)
            }            
            
            tableViewChartVC.dataArray.append(contentsOf: data)
            tableViewChartVC.reloadTableView()
        }
        
        if webViewChartTwoVC.isAllowed
        {
            if let _ = HubSpotCRMKPIs(rawValue: kpi.integratedKPI.kpiName!)
            {
                webViewChartTwoVC.service = .HubSpotCRM
            }
            else if let _ = HubSpotMarketingKPIs(rawValue: kpi.integratedKPI.kpiName!)
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
        
        tableViewChartVC.dataArray.append(contentsOf: reportDataManipulator.dataToPresent)
        tableViewChartVC.reloadTableView()
        
        if webViewChartTwoVC.isAllowed
        {
            webViewChartTwoVC.service = .GoogleAnalytics
            webViewChartTwoVC.rawDataArray.append(contentsOf: reportDataManipulator.dataToPresent)
            webViewChartTwoVC.refreshView()
        }
        
        if webViewChartOneVC.isAllowed
        {
            webViewChartTwoVC.service = .GoogleAnalytics
            webViewChartOneVC.rawDataArray.append(contentsOf: reportDataManipulator.dataToPresent)
            webViewChartOneVC.refreshView()
        }
    }
    
    @objc private func prepareDataForReportFromPayPal() {
        
        removeWaitingSpinner()
        refreshControl.endRefreshing()
        
        tableViewChartVC.dataArray.append(contentsOf: reportDataManipulator.dataToPresent)
        tableViewChartVC.reloadTableView()
        
        if webViewChartTwoVC.isAllowed 
        {
            webViewChartTwoVC.service = .PayPal
            webViewChartTwoVC.rawDataArray.append(contentsOf: reportDataManipulator.dataToPresent)
            webViewChartTwoVC.refreshView()
        }
        
        if webViewChartOneVC.isAllowed
        {
            webViewChartTwoVC.service = .PayPal
            webViewChartOneVC.rawDataArray.append(contentsOf: reportDataManipulator.dataToPresent)
            webViewChartOneVC.refreshView()
        }
    }
    
    @objc private func prepareDataForReportFromQB() {
        
        removeWaitingSpinner()
        refreshControl.endRefreshing()
        
        let kpiName  = kpi.integratedKPI.kpiName!
        let kpiValue = QiuckBooksKPIs(rawValue: kpiName)!
        let data     = reportDataManipulator.quickBooksDataManager.dataFor(kpi: kpiValue)
        
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
            webViewChartOneVC.rawDataArray.append(contentsOf: reportDataManipulator.quickBooksDataManager.paidInvoices)
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
        let alertVC = UIAlertController(title: "Sorry", message: "You should autorisation again", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            let request = ExternalRequest()
            request.oAuthAutorisation(servise: IntegratedServices(rawValue: external.serviceName!)!, viewController: self, success: { objects in
                switch IntegratedServices(rawValue: external.serviceName!)! {
                case .GoogleAnalytics:
                    external.googleAnalyticsKPI = objects.googleAnalyticsObject
                case .SalesForce:
                    external.saleForceKPI = objects.salesForceObject
                default:
                    break
                }
            }, failure: { error in
                self.showAlert(title: "Sorry", errorMessage: error)
            })
        }))
    }
}
