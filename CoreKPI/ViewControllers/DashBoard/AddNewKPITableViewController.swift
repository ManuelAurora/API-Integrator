//
//  AddNewKPITableViewController.swift
//  CoreKPI
//
//  Created by Семен on 23.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class AddNewKPITableViewController: UITableViewController {
    
    var model: ModelCoreKPI!
    var kpiListVC: KPIsListTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "ChooseSuggested":
            let destinationVC = segue.destination as! ChooseSuggestedKPITableViewController
            destinationVC.model = ModelCoreKPI(model: self.model)
            destinationVC.KPIListVC = self.kpiListVC
        case "createKPI":
            let destinationVC = segue.destination as! CreateNewKPITableViewController
            destinationVC.model = ModelCoreKPI(model: self.model)
            destinationVC.KPIListVC = self.kpiListVC
        default:
            break
        }
    }
    
}
