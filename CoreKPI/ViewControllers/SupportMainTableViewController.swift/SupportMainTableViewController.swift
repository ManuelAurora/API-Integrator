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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        
        nc.addObserver(forName: .modelDidChanged, object:nil, queue:nil, using:catchNotification)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)]
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
        return 4
    }
    
    //MARK: - CatchNotification
    func catchNotification(notification:Notification) -> Void {
        
            tableView?.reloadData()
    }
    
    @IBAction func didTapLogoutButton(_ sender: UIBarButtonItem) {
        
        let appDelegate = UIApplication.shared .delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        _ = model.team.map { context.delete($0) }
        
        UserDefaults.standard.set(nil, forKey: UserDefaultsKeys.pinCode)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.token)
        
        appDelegate.loggedIn = false
        
        let startVC = storyboard?.instantiateViewController(withIdentifier: "StartVC")
        present(startVC!, animated: true, completion: nil)
    }    
}
