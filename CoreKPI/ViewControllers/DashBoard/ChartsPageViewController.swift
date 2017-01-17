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
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        self.setViewControllers([returnVC(index: 0)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK:- UIPageViewControllerDataSource Methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        if (index == 0) || index == NSNotFound {
            return nil
        }
        
        self.index -= 1
        return returnVC(index: self.index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        if (index == NSNotFound) || (index == 1) {
            return nil
        }
        index += 1
        return returnVC(index: self.index)
    }
    
    // MARK:- Other Methods
//    func getViewControllerAtIndex(_ index: NSInteger) -> PageContentViewController
//    {
//        // Create a new view controller and pass suitable data.
//        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageContentViewController") as! PageContentViewController
//        
//        pageContentViewController.strTitle = "\(arrPageTitle[index])"
//        pageContentViewController.strPhotoName = "\(arrPagePhoto[index])"
//        pageContentViewController.pageIndex = index
//        
//        return pageContentViewController
//    }
    
    func returnVC(index: Int) -> UIViewController {
        let webViewChartVC = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewChartViewController
        let tableViewChartVC = storyboard?.instantiateViewController(withIdentifier: "TableViewController") as! TableViewChartController
        
        webViewChartVC.typeOfChart = .PieChart
        tableViewChartVC.dataArray = [12.0, 157.2, 4554.0]
        tableViewChartVC.header = "My KPI"
        
        switch index {
        case 0:
            return tableViewChartVC
        case 1:
            return webViewChartVC
        default:
            return tableViewChartVC
        }
        
    }
    
}

