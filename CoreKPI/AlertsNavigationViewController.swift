//
//  AlertsNavigationViewController.swift
//  CoreKPI
//
//  Created by Семен on 29.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class AlertsNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
