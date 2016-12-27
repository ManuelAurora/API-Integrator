//
//  AllertSettingsTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 21.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class AllertSettingsTableViewController: UITableViewController {
    
    let selectADataSource = [""]
    var timeInterval: TimeInterval!
    var deliveryDay: String!
    var timeZone: String!
    var deliveryTime: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeInterval = TimeInterval.Monthly
        
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        switch section {
        case 0:
            return 1
        case 1:
            if timeInterval == TimeInterval.Daily {
                return 3
            } else {
                return 4
            }
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertSettingCell", for: indexPath) as! AlertSettingTableViewCell
        
        switch indexPath.section {
        case 0:
            cell.headerCellLabel.text = "Select a data source"
            cell.descriptionCellLabel.text = "My shop sales"
        case 1:
            
            if timeInterval == TimeInterval.Daily {
                switch indexPath.row {
                case 0:
                    cell.headerCellLabel.text = "Time interval"
                    cell.descriptionCellLabel.text = self.timeInterval.rawValue
                case 1:
                    cell.headerCellLabel.text  = "Time zone"
                    cell.descriptionCellLabel.text = timeZone
                case 2:
                    cell.headerCellLabel.text = "Delivery time"
                    cell.descriptionCellLabel.text = timeToString(/*(date: self.deliveryTime*/)
                    cell.accessoryType = .none
                default:
                    break
                }

            } else {
                switch indexPath.row {
                case 0:
                    cell.headerCellLabel.text = "Time interval"
                    cell.descriptionCellLabel.text = self.timeInterval.rawValue
                case 1:
                    cell.headerCellLabel.text = "Delivery day"
                    cell.descriptionCellLabel.text = self.deliveryDay
                    
                case 2:
                    cell.headerCellLabel.text  = "Time zone"
                    cell.descriptionCellLabel.text = timeZone
                case 3:
                    cell.headerCellLabel.text = "Delivery time"
                    cell.descriptionCellLabel.text = timeToString(/*date: self.deliveryTime*/)
                    cell.accessoryType = .none
                default:
                    break
                }
            }
            

        case 2:
            cell.headerCellLabel.text = "Type of notification"
            cell.descriptionCellLabel.isHidden = true
        default:
            break
        }
        return cell
    }
    
    func timeToString(/*date: Date*/) -> String {
        return "12:15 PM"
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Parameters"
        } else {
            return " "
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
