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
        
        switch kpi.typeOfKPI {
        case .createdKPI:
            self.navigationItem.title = "Report"
        case .IntegratedKPI:
            self.navigationItem.title = kpi.integratedKPI?.serviceName
        }
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
            if kpi.KPIViewOne == .Numbers && kpi.KPIViewTwo == .Graph {
                for i in (kpi.createdKPI?.number)! {
                    tableViewChartVC.dataArray.append(i)
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
                    tableViewChartVC.dataArray.append(i)
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
            break
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

