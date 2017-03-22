//
//  DashboardsNavigationViewController.swift
//  CoreKPI
//
//  Created by Семен on 29.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class DashboardsNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : OurColors.cyan]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
