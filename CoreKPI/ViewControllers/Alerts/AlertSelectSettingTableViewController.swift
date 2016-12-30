//
//  AlertSelectSettingTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 27.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class AlertSelectSettingTableViewController: UITableViewController {
    
    weak var AlertSettingVC: AllertSettingsTableViewController!
    var selectSetting: [(SettingName: String, value: Bool)]!
    var delegate: updateSettingsArrayDelegate!
    
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
        return self.selectSetting.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSettingCell", for: indexPath)
        
        cell.textLabel?.text = selectSetting[indexPath.row].SettingName
        cell.accessoryType = selectSetting[indexPath.row].value ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSettingCell", for: indexPath)
        
        for i in 0..<selectSetting.count {
            selectSetting[i].value = false
        }
        selectSetting[indexPath.row].value = true
        cell.accessoryType = .checkmark
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    //MARK: - Send data to parent ViewController
    override func didMove(toParentViewController parent: UIViewController?) {
        if(!(parent?.isEqual(self.parent) ?? false)) {
            delegate = AlertSettingVC
            delegate.updateSettingsArray(array: selectSetting)
        }
    }
    
}
