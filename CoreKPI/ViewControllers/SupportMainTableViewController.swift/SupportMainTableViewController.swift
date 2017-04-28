//
//  SupportMainTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class SupportMainTableViewController: UITableViewController {

    var model: ModelCoreKPI!    
    var stateMachine = UserStateMachine.shared
    
    private var isRequestForNewIntegration = false
    
    @IBAction func didTapLogoutButton(_ sender: UIBarButtonItem) {
        
        stateMachine.logOut()
    }
      
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [NSForegroundColorAttributeName: OurColors.cyan]
                
        title = "Support"        
        tableView.backgroundColor = OurColors.gray
        tableView.tableFooterView = UIView(frame: .zero)
        navigationController?.navigationBar.titleTextAttributes = attributes
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? SendNewIntegrationViewController
        {
            vc.title = "New Request"
            vc.messageType = .request
        }
    }
}
