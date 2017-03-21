//
//  MainTabBarViewController.swift
//  CoreKPI
//
//  Created by Семен on 16.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    //MARK: *Properties.
    var model: ModelCoreKPI!
    var appDelegate: AppDelegate!  
    
    //MARK: *Properties. Navigation controllers & children
    //Navigation controllers
    var dashboardNavController: DashboardsNavigationViewController {
        let dnc = viewControllers?[0] as! DashboardsNavigationViewController
        return dnc
    }
    
    var alertsNavController: AlertsNavigationViewController {
        let anc = viewControllers?[1] as! AlertsNavigationViewController
        return anc
    }
    
    var teamListNavController: TeamListViewController {
        let tlnc = viewControllers?[2] as! TeamListViewController
        return tlnc
    }
    
    var supportNavController: SupportNavigationViewController {
        let snc = viewControllers?[3] as! SupportNavigationViewController
        return snc
    }
    
    //*Child view controllers
    var dashboardViewController: KPIsListTableViewController {
        let dvc = dashboardNavController.childViewControllers[0] as! KPIsListTableViewController
        return dvc
    }
    
    var alertsViewController: AlertsListTableViewController {
        let avc = alertsNavController.childViewControllers[0] as! AlertsListTableViewController
        return avc
    }
    var teamListController: MemberListTableViewController {
        let tlc = teamListNavController.childViewControllers[0] as! MemberListTableViewController
        return tlc
    }
    
    var supportMainTableVC: SupportMainTableViewController {
        let smvc = supportNavController.childViewControllers[0] as! SupportMainTableViewController
        return smvc
    }
    
    //MARK: *Initializers    
    deinit {
        print("DEBUG: DEINITIALIZED TABBAR")
    }
    
    //MARK: *Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyInitialSettings()
    }
        
    //MARK: *Private functions
    private func applyInitialSettings() {
              
        dashboardViewController.model = model
        alertsViewController.model    = model
        teamListController.model      = model
        supportMainTableVC.model      = model
        
        dashboardViewController.loadKPIsFromServer()
        teamListController.loadTeamListFromServer()
        alertsViewController.loadAlerts()
    }
}
