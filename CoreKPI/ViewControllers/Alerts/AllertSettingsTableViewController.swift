//
//  AllertSettingsTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 21.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class AllertSettingsTableViewController: UITableViewController, updateSettingsArrayDelegate {
    
    var model: ModelCoreKPI!
    var request: Request!
    
    var dataSource = DataSource.MyShopSales
    var timeInterval = TimeInterval.Monthly
    var deliveryDay: String!
    var timeZone: String!
    var deliveryTime: Date!
    var typeOfNotification = TypeOfNotification.none
    
    enum Setting: String {
        case none
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
    
    enum TypeOfNotification: String {
        case none
        case SMS
        case Push
        case Email
    }
    
    var settingsArray: [(SettingName: String, value: Bool)]!
    var typeOfSetting = Setting.none
    
    //    var timeIntervalArray = [(TimeInterval.Daily.rawValue, true), (TimeInterval.Weekly.rawValue, false), (TimeInterval.Monthly.rawValue, false)]
    //    var dataSource  = [(DataSource.MyShopSales.rawValue, true), (DataSource.MyShopSales.rawValue, false)]
    //    var timeZones = [()]
    //    var typeOfNotification = [(TypeOfNotification.SMS.rawValue, true), (TypeOfNotification.Push.rawValue, false), (TypeOfNotification.Email.rawValue, false)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        request = Request(model: self.model)
        
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
            cell.descriptionCellLabel.text = self.dataSource.rawValue
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
                    cell.descriptionCellLabel.textAlignment = .center
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
                    cell.descriptionCellLabel.textAlignment = .center
                    cell.accessoryType = .none
                default:
                    break
                }
            }
        case 2:
            cell.headerCellLabel.text = "Type of notification"
            if self.typeOfNotification == .none {
                cell.descriptionCellLabel.isHidden = true
            } else {
                cell.descriptionCellLabel.isHidden = false
                cell.descriptionCellLabel.text = self.typeOfNotification.rawValue
            }
            
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
        case 0:
            self.typeOfSetting = Setting.DataSource
            self.settingsArray = dataSource == DataSource.MyShopSales ? [(DataSource.MyShopSales.rawValue, true), (DataSource.Balance.rawValue, false)] : [(DataSource.MyShopSales.rawValue, false), (DataSource.Balance.rawValue, true)]
            self.showSelectSettingVC()
        case 1:
            
            if timeInterval == TimeInterval.Daily {
                switch indexPath.row {
                case 0:
                    self.typeOfSetting = Setting.TimeInterval
                    switch self.timeInterval {
                    case TimeInterval.Monthly:
                        self.settingsArray = [(TimeInterval.Daily.rawValue, false), (TimeInterval.Weekly.rawValue, false), (TimeInterval.Monthly.rawValue, true)]
                    case TimeInterval.Weekly:
                        self.settingsArray = [(TimeInterval.Daily.rawValue, false), (TimeInterval.Weekly.rawValue, true), (TimeInterval.Monthly.rawValue, false)]
                    case TimeInterval.Daily:
                        self.settingsArray = [(TimeInterval.Daily.rawValue, true), (TimeInterval.Weekly.rawValue, false), (TimeInterval.Monthly.rawValue, false)]
                    default:
                        break
                    }
                    self.showSelectSettingVC()
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
                case 0:
                    self.typeOfSetting = Setting.TimeInterval
                    switch self.timeInterval {
                    case TimeInterval.Monthly:
                        self.settingsArray = [(TimeInterval.Daily.rawValue, false), (TimeInterval.Weekly.rawValue, false), (TimeInterval.Monthly.rawValue, true)]
                    case TimeInterval.Weekly:
                        self.settingsArray = [(TimeInterval.Daily.rawValue, false), (TimeInterval.Weekly.rawValue, true), (TimeInterval.Monthly.rawValue, false)]
                    case TimeInterval.Daily:
                        self.settingsArray = [(TimeInterval.Daily.rawValue, true), (TimeInterval.Weekly.rawValue, false), (TimeInterval.Monthly.rawValue, false)]
                    }
                    self.showSelectSettingVC()
                case 1: break
                    // cell.headerCellLabel.text = "Delivery day"
                    // cell.descriptionCellLabel.text = self.deliveryDay
                    
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
            
            
        case 2:
            self.typeOfSetting = Setting.TypeOfNotification
            switch self.typeOfNotification {
            case .none:
                self.settingsArray = [(TypeOfNotification.SMS.rawValue, false), (TypeOfNotification.Push.rawValue, false), (TypeOfNotification.Email.rawValue, false)]
            case .SMS:
                self.settingsArray = [(TypeOfNotification.SMS.rawValue, true), (TypeOfNotification.Push.rawValue, false), (TypeOfNotification.Email.rawValue, false)]
            case .Push:
                self.settingsArray = [(TypeOfNotification.SMS.rawValue, false), (TypeOfNotification.Push.rawValue, true), (TypeOfNotification.Email.rawValue, false)]
            case .Email:
                self.settingsArray = [(TypeOfNotification.SMS.rawValue, false), (TypeOfNotification.Push.rawValue, false), (TypeOfNotification.Email.rawValue, true)]
            }
            self.showSelectSettingVC()
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
        self.request = Request(model: model)
        let data: [String : Any] = [:]
        
        request.getJson(category: "/service/getTimeZones", data: data,
                        success: { json in
                            self.parsingJson(json: json)
        },
                        failure: { (error) in
                            print(error)
        })
    }
    
    func parsingJson(json: NSDictionary) {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSDictionary {
                    
                    //save time zones list
                    
                } else {
                    print("Json data is broken")
                }
            } else {
                let errorMessage = json["message"] as! String
                print("Json error message: \(errorMessage)")
                showAlert(title: "Error", message: "Can't load list of time zones")
            }
        } else {
            print("Json file is broken!")
        }
    }
    
    //MARK: - Show alert method
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - updateSettingsArrayDelegate method
    
    func updateSettingsArray(array: [(SettingName: String, value: Bool)]) {
        switch typeOfSetting {
        case .DataSource:
            for setting in array {
                switch setting.SettingName {
                case DataSource.MyShopSales.rawValue where setting.value == true:
                    self.dataSource = DataSource.MyShopSales
                case DataSource.Balance.rawValue where setting.value == true:
                    self.dataSource = DataSource.Balance
                default:
                    break
                }
            }
        case .TimeInterval:
            for setting in array {
                switch setting.SettingName {
                case TimeInterval.Monthly.rawValue where setting.value == true:
                    self.timeInterval = .Monthly
                case TimeInterval.Weekly.rawValue where setting.value == true:
                    self.timeInterval = .Weekly
                case TimeInterval.Daily.rawValue where setting.value == true:
                    self.timeInterval = .Daily
                default:
                    break
                }
            }
        case .TypeOfNotification:
            for setting in array {
                switch setting.SettingName {
                case TypeOfNotification.none.rawValue where setting.value == true:
                    self.typeOfNotification = .none
                case TypeOfNotification.SMS.rawValue where setting.value == true:
                    self.typeOfNotification = .SMS
                case TypeOfNotification.Push.rawValue where setting.value == true:
                    self.typeOfNotification  = .Push
                case TypeOfNotification.Email.rawValue where setting.value == true:
                    self.typeOfNotification = .Email
                default:
                    break
                }
            }
        default:
            break
        }
        tableView.reloadData()
    }
    
    //MARK: - Show AlertSelectSettingViewController method
    func showSelectSettingVC() {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "SelectSetting") as! AlertSelectSettingTableViewController
        destinatioVC.AlertSettingVC = self
        destinatioVC.selectSetting = settingsArray
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
}
