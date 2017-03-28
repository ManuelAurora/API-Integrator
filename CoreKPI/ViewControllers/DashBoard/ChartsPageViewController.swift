//
//  ChartsPageViewController.swift
//  CoreKPI
//
//  Created by Семен on 17.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit
import OAuthSwift

class ChartsPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var kpi: KPI!
    var reportDataManipulator = ReportDataManipulator()
    let stateMachine = UserStateMachine.shared
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate   = self
        dataSource = self
        navigationItem.title = "Reports"
        subscribeToNotifications()
        setInitialViewControllers()
        formData()
        
        self.setViewControllers([providedControllers[0]],
                                direction: UIPageViewControllerNavigationDirection.forward,
                                animated: false,
                                completion: nil)
        
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.backgroundColor = .white
    }
    
    private func setInitialViewControllers() {
        
        if  firstReportIsTable() { providedControllers.append(tableViewChartVC)  }
        else                     { providedControllers.append(webViewChartOneVC) }
        
        providedControllers.append(webViewChartTwoVC)
    }
    
    // MARK:- UIPageViewControllerDataSource & delegate Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return providedControllers[0] == viewController ? nil : providedControllers[0]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if providedControllers[1] != viewController
        {
            guard let vc = providedControllers[1] as? WebViewChartViewController else { return nil }
            
            return vc.isAllowed ? vc : nil
        }
        
        return nil
    }
    
    // MARK:- Other Methods
    private func firstReportIsTable() -> Bool
    {
        return kpi.KPIViewOne == .Numbers
    }
    
    private func formData() {
        
        switch kpi.typeOfKPI
        {
        case .createdKPI:
            if firstReportIsTable()
            {
                _ = kpi.createdKPI?.number.map { tableViewChartVC.reportArray.append($0) }
                tableViewChartVC.header = kpi.createdKPI?.KPI ?? ""
            }
            else { webViewChartOneVC.typeOfChart = kpi.KPIChartOne!; webViewChartOneVC.isAllowed = true }
            
            webViewChartTwoVC.isAllowed = true
            webViewChartTwoVC.typeOfChart = kpi.KPIChartTwo!
            
        case .IntegratedKPI:
            tableViewChartVC.typeOfKPI = .IntegratedKPI
            
            let kpiName = kpi.integratedKPI.kpiName!
            let service = IntegratedServices(rawValue: kpi.integratedKPI.serviceName!)!
            var chart: TypeOfChart = .PieChart
            
            switch service
            {
            case .PayPal:
                let kpiValue = PayPalKPIs(rawValue: kpiName)!
                 
                switch kpiValue
                {
                case .TransactionsByStatus, .PendingByType:
                    chart = .PieChart
                    webViewChartTwoVC.isAllowed = true
                    
                case .NetSalesTotalSales:
                    chart = .LineChart
                    webViewChartTwoVC.isAllowed = true
                    
                default: break
                }
                
            default: break
            }
            
            if firstReportIsTable() { tableViewChartVC.header  = kpiName }
            else                    { webViewChartOneVC.header = kpiName }
            
            webViewChartTwoVC.typeOfChart = chart
            webViewChartTwoVC.header = kpiName
            reportDataManipulator.kpi = kpi
            reportDataManipulator.dataForReport()
            
            var point = view.center
            point.y -= 80
            
            addWaitingSpinner(at: point, color: OurColors.cyan)
        }
    }
    
    private func subscribeToNotifications() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ChartsPageViewController.prepareDataForReportFromQB),
                                               name: .qbManagerRecievedData,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ChartsPageViewController.prepareDataForReportFromPayPal),
                                               name: .paypalManagerRecievedData,
                                               object: nil)
    }
 
    @objc private func prepareDataForReportFromPayPal() {
        
        tableViewChartVC.dataArray.append(contentsOf: reportDataManipulator.dataFromPaypalToPresent)
        webViewChartOneVC.rawDataArray.append(contentsOf: reportDataManipulator.dataFromPaypalToPresent)
        webViewChartTwoVC.rawDataArray.append(contentsOf: reportDataManipulator.dataFromPaypalToPresent)
        
        removeWaitingSpinner()
                
        tableViewChartVC.reloadTableView()
        if webViewChartTwoVC.isAllowed { webViewChartTwoVC.refreshView() }
        if webViewChartOneVC.isAllowed { webViewChartOneVC.refreshView() }
    }
    
    @objc private func prepareDataForReportFromQB() {
        
        let kpiName = kpi.integratedKPI.kpiName!
        let kpiValue = QiuckBooksKPIs(rawValue: kpiName)!
        let data = reportDataManipulator.quickBooksDataManager.dataFor(kpi: kpiValue)
        
        tableViewChartVC.dataArray.append(contentsOf: data)
        
        removeWaitingSpinner()
        
        tableViewChartVC.reloadTableView()        
        if webViewChartTwoVC.isAllowed { webViewChartTwoVC.refreshView() }
        if webViewChartOneVC.isAllowed { webViewChartOneVC.refreshView() }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
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
