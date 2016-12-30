//
//  AllertSettingsTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 21.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class AllertSettingsTableViewController: UITableViewController, updateSettingsArrayDelegate {
    
    let selectADataSource = [""]
    var timeInterval: TimeInterval!
    var deliveryDay: String!
    var timeZone: String!
    var deliveryTime: Date!
    
    enum Setting: String {
        case DataSource
        case TimeInterval
        case DeliveryDay
        case TimeZone
        case DeliveryTime
        case TypeOfNotification
    }
    
    enum TimeInterval: String {
        case Daily
        case Weekly
        case Monthly
    }
    
    enum DataSource: String {
        case MyShopSales = "My shop sales"
        case Balance
    }
    
    var timeIntervalArray = [(TimeInterval.Daily.rawValue, true), (TimeInterval.Weekly.rawValue, false), (TimeInterval.Monthly.rawValue, false)]
    var dataSource  = [(DataSource.MyShopSales.rawValue, true), (DataSource.MyShopSales.rawValue, false)]
    var timeZones = [()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeInterval = TimeInterval.Monthly
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Parameters"
        } else {
            return " "
        }
    }
    
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
            switch indexPath.section {
            case 0: break
                //go to data source
            case 1:
    
                if timeInterval == TimeInterval.Daily {
                    switch indexPath.row {
                    case 0: break
                        //goto time interval
                    case 1: break
//                        cell.headerCellLabel.text  = "Time zone"
//                        cell.descriptionCellLabel.text = timeZone
                    case 2: break
//                        cell.headerCellLabel.text = "Delivery time"
//                        cell.descriptionCellLabel.text = timeToString(/*(date: self.deliveryTime*/)
//                        cell.accessoryType = .none
                    default:
                        break
                    }
    
                } else {
                    switch indexPath.row {
                    case 0: break
//                        cell.headerCellLabel.text = "Time interval"
//                        cell.descriptionCellLabel.text = self.timeInterval.rawValue
                    case 1: break
//                        cell.headerCellLabel.text = "Delivery day"
//                        cell.descriptionCellLabel.text = self.deliveryDay
    
                    case 2: break
//                        cell.headerCellLabel.text  = "Time zone"
//                        cell.descriptionCellLabel.text = timeZone
                    case 3: break
//                        cell.headerCellLabel.text = "Delivery time"
//                        cell.descriptionCellLabel.text = timeToString(/*date: self.deliveryTime*/)
//                        cell.accessoryType = .none
                    default:
                        break
                    }
                }
    
    
            case 2: break
//                cell.headerCellLabel.text = "Type of notification"
//                cell.descriptionCellLabel.isHidden = true
            default:
                break
            }
    
        }
    
    //MARK: - convert time to string
    func timeToString(/*date: Date*/) -> String {
        return "12:15 PM"
    }
    
    //MARK: - update time zones from server
    func getTimeZonesList() {
        
    }
    
    //MARK: - updateSettingsArrayDelegate method
    
    func updateSettingsArray(array: [(String, Bool)]) {
        print(array)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "123" {
            let destinatioVC = segue.destination as! AlertSelectSettingTableViewController
            destinatioVC.AlertSettingVC = self
            destinatioVC.selectSetting = timeIntervalArray
        }
    }
    
}
