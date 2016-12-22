//
//  MainTabBarViewController.swift
//  CoreKPI
//
//  Created by Семен on 16.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController, updateModelDelegate {

    var model: ModelCoreKPI!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateModel(model: ModelCoreKPI) {
        self.model = model
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let destinationDashboardViewController = segue.destination
        //let destinationAlertsViewController = segue.destination
        let destinationTeamViewControler = segue.destination as!  MemberListTableViewController
        //let destinationSupportViewController = segue.destination as! SupportMainTableViewController
     
        destinationTeamViewControler.model = ModelCoreKPI(model: self.model)
    }
 

}
