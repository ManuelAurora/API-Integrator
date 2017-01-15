//
//  AllertSettingsTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 21.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class AllertSettingsTableViewController: AlertsListTableViewController, updateSettingsDelegate {
    
    weak var AlertListVC: AlertsListTableViewController!
    weak var ReminderViewVC: ReminderViewTableViewController!
    var delegate: updateAlertListDelegate!
    
    var request: Request!
    
    var typeOfSetting = Setting.none
    var settingsArray: [(SettingName: String, value: Bool)] = []
    
    var dataSource = DataSource.MyShopSales
    var dataSourceArray: [(SettingName: String, value: Bool)] = [(DataSource.MyShopSales.rawValue, true),(DataSource.MyShopSupples.rawValue, false), (DataSource.Balance.rawValue, false)]
    
    var timeInterval = TimeInterval.Daily
    var timeIntervalArray: [(SettingName: String, value: Bool)] = [(TimeInterval.Daily.rawValue, true), (TimeInterval.Weekly.rawValue, false), (TimeInterval.Monthly.rawValue, false)]
    
    var deliveryDay: String!
    var deliveryDayArray: [(SettingName: String, value: Bool)] = []
    
    var timeZone: String? {
        for timezone in timeZoneArray {
            if timezone.value == true {
                return timezone.SettingName
            }
        }
        return nil
    }
    var timeZoneArray: [(SettingName: String, value: Bool)] = [("Hawaii Time (HST)",false), ("Alaska Time (AKST)", false), ("Pacific Time (PST)",false), ("Mountain Time (MST)", false), ("Central Time (CST)", false), ("Eastern Time (EST)",false)]
    
    var condition = Condition.IsLessThan
    var conditionArray: [(SettingName: String, value: Bool)] = [(Condition.IsLessThan.rawValue, true), (Condition.IncreasedOrDecreased.rawValue, false), (Condition.PercentHasIncreasedOrDecreasedByMoreThan.rawValue, false)]
    
    var threshold: String?
    
    var deliveryTime: String!//Date!
    
    var typeOfNotification: [TypeOfNotification] = []
    var typeOfNotificationArray: [(SettingName: String, value: Bool)] = [(TypeOfNotification.Email.rawValue, false), (TypeOfNotification.SMS.rawValue, false), (TypeOfNotification.Push.rawValue, false)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        request = Request(model: self.model)
        
        //NOT USE IN THIS VERSION
        //self.getTimeZonesList()
        
        //debug
        self.deliveryTime = "12:15 PM"
        
        for i in 1...31 {
            var deliveryDay: (String, Bool) = ("\(i)", false)
            if self.deliveryDay != nil && self.deliveryDay == "\(i)" {
                deliveryDay = ("\(i)", true)
            }
            self.deliveryDayArray.append(deliveryDay)
        }
        
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
            if timeInterval == TimeInterval.Daily || dataSource == .Balance {
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
            if timeInterval == TimeInterval.Daily || dataSource == .Balance {
                if dataSource == .Balance {
                    switch indexPath.row {
                    case 0:
                        cell.headerCellLabel.text = "Condition"
                        cell.descriptionCellLabel.text = condition.rawValue
                    case 1:
                        cell.headerCellLabel.text = "Threshold"
                        cell.descriptionCellLabel.text = threshold ?? "Add data"
                    case 2:
                        cell.headerCellLabel.text = "Delivery time"
                        cell.descriptionCellLabel.text = deliveryTime
                    default:
                        break
                    }
                } else {
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
                }
                
            } else {
                switch indexPath.row {
                case 0:
                    cell.headerCellLabel.text = "Time interval"
                    cell.descriptionCellLabel.text = self.timeInterval.rawValue
                case 1:
                    cell.headerCellLabel.text = "Delivery day"
                    if self.deliveryDay != nil && Int(self.deliveryDay)! > 28 {
                        cell.descriptionCellLabel.text = self.deliveryDay + " or last day"
                    } else {
                        cell.descriptionCellLabel.text = self.deliveryDay
                    }
                    
                    
                case 2:
                    cell.headerCellLabel.text  = "Time zone"
                    cell.descriptionCellLabel.text = timeZone
                    cell.accessoryType = .disclosureIndicator
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
            switch self.typeOfNotification.count {
            case 0:
                cell.descriptionCellLabel.isHidden = true
            case 1:
                cell.descriptionCellLabel.isHidden = false
                cell.descriptionCellLabel.text = self.typeOfNotification[0].rawValue
            case 2:
                cell.descriptionCellLabel.isHidden = false
                cell.descriptionCellLabel.text = "2 selected"
            case 3:
                cell.descriptionCellLabel.isHidden = false
                cell.descriptionCellLabel.text = "3 selected"
            default:
                break
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
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 13)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            self.typeOfSetting = Setting.DataSource
            self.settingsArray = self.dataSourceArray
            self.showSelectSettingVC()
        case 1:
            
            if timeInterval == TimeInterval.Daily || dataSource == .Balance {
                if dataSource == .Balance {
                    switch indexPath.row {
                    case 0:
                        self.typeOfSetting = .Condition
                        self.settingsArray = self.conditionArray
                        self.showSelectSettingVC()
                    case 1:
                        self.typeOfSetting = .Threshold
                        self.showSelectSettingVC()
                    case 2:
                        break
                    default:
                        break
                    }
                } else {
                    switch indexPath.row {
                    case 0:
                        self.typeOfSetting = Setting.TimeInterval
                        self.settingsArray = self.timeIntervalArray
                        self.showSelectSettingVC()
                    case 1:
                        self.typeOfSetting = Setting.TimeZone
                        self.settingsArray = self.timeZoneArray
                        self.showSelectSettingVC()
                    case 2: break
                        //cell.headerCellLabel.text = "Delivery time"
                        //cell.descriptionCellLabel.text = timeToString(/*(date: self.deliveryTime*/)
                    //cell.accessoryType = .none
                    default:
                        break
                    }
                }
                
                
            } else {
                switch indexPath.row {
                case 0:
                    self.typeOfSetting = Setting.TimeInterval
                    self.settingsArray = self.timeIntervalArray
                    self.showSelectSettingVC()
                case 1:
                    self.typeOfSetting = Setting.DeliveryDay
                    self.settingsArray = self.deliveryDayArray
                    self.showSelectSettingVC()
                case 2:
                    self.typeOfSetting = Setting.TimeZone
                    self.settingsArray = self.timeZoneArray
                    self.showSelectSettingVC()
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
            self.settingsArray = self.typeOfNotificationArray
            self.showSelectSettingVC()
        default:
            break
        }
    }
    
    //MARK: - convert time to string
    func timeToString(/*date: Date*/) -> String {
        return "12:15 PM"
    }
    
    //MARK: - update time zones from server - NOT USE IN THIS VERSION!
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
                    
                    print(dataKey)
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
    
    //MARK: - updateSettingsArrayDelegate methods
    
    func updateDoubleValue(number: Double?) {
    }
    
    func updateSettingsArray(array: [(SettingName: String, value: Bool)]) {
        switch typeOfSetting {
        case .DataSource:
            self.dataSourceArray = array
            for source in array {
                if source.value == true {
                    self.dataSource = DataSource(rawValue: source.SettingName)!
                }
            }
        case .TimeInterval:
            self.timeIntervalArray = array
            for interval in array {
                if interval.value == true {
                    self.timeInterval = TimeInterval(rawValue: interval.SettingName)!
                }
            }
        case .DeliveryDay:
            self.deliveryDayArray = array
            for day in array {
                if day.value == true {
                    self.deliveryDay = day.SettingName
                }
            }
        case .TimeZone:
            self.timeZoneArray = array
        case .Condition:
            self.conditionArray = array
            for condition in array {
                if condition.value == true {
                    self.condition = Condition(rawValue:condition.SettingName)!
                }
            }
        case .TypeOfNotification:
            self.typeOfNotificationArray = array
            self.typeOfNotification.removeAll()
            for notification in array {
                if notification.value == true {
                    self.typeOfNotification.append(TypeOfNotification(rawValue: notification.SettingName)!)
                }
            }
        default:
            return
        }
        tableView.reloadData()
        self.typeOfSetting = .none
    }
    
    func updateStringValue(string: String?) {
        switch typeOfSetting {
        case .Threshold:
            self.threshold = string
        default:
            return
        }
        tableView.reloadData()
    }
    
    @IBAction func tapSaveButton(_ sender: UIBarButtonItem) {
        let alert: Alert!
        switch dataSource {
        case .Balance:
            if threshold == nil || deliveryTime == nil {
                let alertController = UIAlertController(title: "Error", message: "One are more field(s) are empty", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            } else {
                alert = Alert(image: "", dataSource: self.dataSource, timeInterval: nil, deliveryDay: nil, timeZone: nil, condition: self.condition, threshold: self.threshold, deliveryTime: self.deliveryTime, typeOfNotification: self.typeOfNotification)
            }
        default:
            if timeZone == nil || deliveryTime == nil || typeOfNotification.isEmpty || (deliveryDay == nil && timeInterval != .Daily) {
                let alertController = UIAlertController(title: "Error", message: "One are more field(s) are empty", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            } else {
                alert = Alert(image: "", dataSource: self.dataSource, timeInterval: self.timeInterval, deliveryDay: self.deliveryDay, timeZone: self.timeZone, condition: nil, threshold: nil, deliveryTime: self.deliveryTime, typeOfNotification: self.typeOfNotification)
            }
        }
        if AlertListVC != nil {
            delegate = self.AlertListVC
            delegate.addAlert(alert: alert)
        }
        
        if ReminderViewVC != nil {
            delegate = self.ReminderViewVC
            delegate.addAlert(alert: alert)
        }
        
        self.navigationController!.popViewController(animated: true)
    }
    
    //MARK: - Show AlertSelectSettingViewController method
    func showSelectSettingVC() {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "SelectSetting") as! AlertSelectSettingTableViewController
        destinatioVC.AlertSettingVC = self
        destinatioVC.selectSetting = settingsArray
        switch typeOfSetting {
        case .TypeOfNotification:
            destinatioVC.selectSeveralEnable = true
        case .Threshold:
            destinatioVC.inputSettingCells = true
            destinatioVC.textFieldInputData = self.threshold
            switch self.condition {
            case .IncreasedOrDecreased:
                destinatioVC.headerForTableView = "Add data"
            case .IsLessThan:
                destinatioVC.headerForTableView = "Add data"
            case .PercentHasIncreasedOrDecreasedByMoreThan:
                destinatioVC.headerForTableView = "Add data %"
            }
        case .DeliveryDay:
            destinatioVC.tableView.isScrollEnabled = true
        default:
            break
        }
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
    //MARK: - update all parameters from Alert struct
    func updateParameters(alert: Alert) {
        //dataSource
        self.dataSource = alert.dataSource
        var newDataSourceArray: [(SettingName: String, value: Bool)] = []
        for source in self.dataSourceArray {
            if source.SettingName == self.dataSource.rawValue {
                newDataSourceArray.append((source.SettingName, true))
            } else {
                newDataSourceArray.append((source.SettingName, false))
            }
        }
        self.dataSourceArray = newDataSourceArray
        //TimeInterval
        if let alertTimeInterval = alert.timeInterval {
            self.timeInterval = alertTimeInterval
            var newTimeIntervalArray: [(SettingName: String, value: Bool)] = []
            for interval in self.timeIntervalArray {
                if interval.SettingName == self.timeInterval.rawValue {
                    newTimeIntervalArray.append((interval.SettingName, true))
                } else {
                    newTimeIntervalArray.append((interval.SettingName, false))
                }
            }
            self.timeIntervalArray = newTimeIntervalArray
        }

        //DeliveryDay
        if let alertDeliveryDay = alert.deliveryDay {
            self.deliveryDay = alertDeliveryDay
            var newDeliveryDayArray: [(SettingName: String, value: Bool)] = []
            for day in self.deliveryDayArray {
                if day.SettingName == self.deliveryDay {
                    newDeliveryDayArray.append((day.SettingName, true))
                } else {
                    newDeliveryDayArray.append((day.SettingName, false))
                }
            }
            self.deliveryDayArray = newDeliveryDayArray
        }
  
        //TimeZone
        var newTimeZoneArray: [(SettingName: String, value: Bool)] = []
        for zone in self.timeZoneArray {
            if zone.SettingName == alert.timeZone {
                newTimeZoneArray.append((zone.SettingName, true))
            } else {
                newTimeZoneArray.append((zone.SettingName, false))
            }
        }
        self.timeZoneArray = newTimeZoneArray
        //Condition
        if let alertCondition = alert.condition {
            self.condition = alertCondition
            var newConditionArray: [(SettingName: String, value: Bool)] = []
            for condition in self.conditionArray {
                if condition.SettingName == self.condition.rawValue {
                    newConditionArray.append((condition.SettingName, true))
                } else {
                    newConditionArray.append((condition.SettingName, false))
                }
            }
            self.conditionArray = newConditionArray
        }

        //Threshold
        self.threshold = alert.threshold
        //DeliveryTime
        self.deliveryTime = alert.deliveryTime
        //TipeOfNotification
        self.typeOfNotification = alert.typeOfNotification
        var newTypeOfNotificationArray: [(SettingName: String, value: Bool)] = []
        for notification in self.typeOfNotificationArray {
            var notificationDidSelected = false
            for selectedNotifications in self.typeOfNotification {
                if notification.SettingName == selectedNotifications.rawValue {
                    notificationDidSelected = true
                }
            }
            if notificationDidSelected {
                newTypeOfNotificationArray.append((notification.SettingName, true))
            } else {
                newTypeOfNotificationArray.append((notification.SettingName, false))
            }
        }
        self.typeOfNotificationArray = newTypeOfNotificationArray
    }
    
}
