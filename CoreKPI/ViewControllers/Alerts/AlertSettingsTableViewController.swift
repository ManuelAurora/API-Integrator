//
//  AlertSettingsTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 21.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

enum СreationMode
{
    case createNew
    case edit
}

class AlertSettingsTableViewController: UITableViewController, StoryboardInstantiation {
    
    weak var AlertListVC: AlertsListTableViewController!
    weak var ReminderViewVC: ReminderViewTableViewController!
    var indexOfDigit = 0
    
    @IBOutlet weak var savaButton: UIBarButtonItem!
    
    var model: ModelCoreKPI!
       
    var typeOfDigit: TypeOfDigit = .Reminder
    var datePickerIsVisible = false
    
    var typeOfSetting = Setting.none
    var settingsArray: [(SettingName: String, value: Bool)] = []
    
    var dataSource: Int?
    var dataSourceArray: [(SettingName: String, value: Bool)] = []
    var kpiDataArr: [(SettingName: String, dataId: Int, value: Bool)] {
        var dataArray = [(SettingName: String, dataId: Int, value: Bool)]()
        self.model.kpis.forEach { kpi in
            dataArray.append((model.getNameKPI(FromID: kpi.id)!,
                              kpi.id, false))
        }
        return dataArray
    }

    //MARK: Reminders
    var timeInterval = AlertTimeInterval.Daily
    var timeIntervalArray: [(SettingName: String, value: Bool)] = []
    var creationMode: СreationMode = .createNew
    var deliveryDay: String?
    var deliveryDayOfWeekArray: [(SettingName: String, value: Bool)] = []
    var deliveryDayOfMounthArray: [(SettingName: String, value: Bool)] = []
    
    var timeZone: String? {
        for timezone in timeZoneArray {
            if timezone.value == true {
                return timezone.SettingName
            }
        }
        return nil
    }
    var timeZoneArray: [(SettingName: String, value: Bool)] = [("Hawaii Time (HST)",false), ("Alaska Time (AKST)", false), ("Pacific Time (PST)",false), ("Mountain Time (MST)", false), ("Central Time (CST)", false), ("Eastern Time (EST)",false)]
    
    var deliveryTime: Date?
    
    //MARK: Alerts
    var condition = Condition.IsLessThan
    var conditionArray: [(SettingName: String, value: Bool)] = []
    
    var threshold: Double?
    
    var deliveryAt: String {
        get {
            for item in deliveryAtArray {
                if item.value == true {
                    return item.SettingName
                }
            }
            return ""
        }
        set {
            var newDeliveryAtArray: [(SettingName: String, value: Bool)] = []
            for item in deliveryAtArray {
                if newValue == item.SettingName {
                    newDeliveryAtArray.append((item.SettingName, true))
                } else {
                    newDeliveryAtArray.append((item.SettingName, false))
                }
            }
            deliveryAtArray = newDeliveryAtArray
        }
    }
    var deliveryAtArray: [(SettingName: String, value: Bool)] = [("At work hours", true),("AllTime", false)]
    
    var typeOfNotification: [TypeOfNotification] = []
    var typeOfNotificationArray: [(SettingName: String, value: Bool)] = [
        (TypeOfNotification.Email.rawValue, false)/*,
        (TypeOfNotification.SMS.rawValue, false),
        (TypeOfNotification.Push.rawValue, false)*/]
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        removeWaitingSpinner()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: .modelDidChanged, object:nil, queue:nil, using:catchNotification)
        
        createArrays()
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if dataSource == nil { navigationItem.title = "Source" }
        else { navigationItem.title = "Reminder" }
    }
    
    private func animateTableViewRealoadData() {
        
        let transition = CATransition()
        let funcName   = kCAMediaTimingFunctionEaseInEaseOut
        let timingFunc = CAMediaTimingFunction(name: funcName)
        
        transition.type = kCATransitionPush
        transition.timingFunction = timingFunc
        transition.fillMode = kCAFillModeForwards
        transition.duration = 0.4
        transition.subtype  = kCATransitionFromRight
        
        tableView.layer.add(transition, forKey: "UITableViewReloadAnimationKey")
    }

    
    //MARK: - CreateArrays
    func createArrays() {
        for kpi in model.kpis {
            if dataSource == kpi.id {
                dataSourceArray.append((model.getNameKPI(FromID: kpi.id)!, true))
            } else {
                dataSourceArray.append((model.getNameKPI(FromID: kpi.id)!, false))
            }
        }
        for timeInterval in iterateEnum(AlertTimeInterval.self) {
            if timeInterval == self.timeInterval {
                timeIntervalArray.append((timeInterval.rawValue, true))
            } else {
                timeIntervalArray.append((timeInterval.rawValue, false))
            }
        }
        for condition in iterateEnum(Condition.self) {
            if condition == self.condition {
                conditionArray.append((condition.rawValue, true))
            } else {
                conditionArray.append((condition.rawValue, false))
            }
        }
        
        for i in 1...31 {
            var deliveryDay: (String, Bool) = ("\(i)", false)
            if timeInterval == .Monthly && self.deliveryDay != nil && self.deliveryDay == "\(i)" {
                deliveryDay = ("\(i)", true)
            } else {
                deliveryDay = ("\(i)", false)
            }
            deliveryDayOfMounthArray.append(deliveryDay)
        }
        
        for days in iterateEnum(WeeklyInterval.self) {
            if timeInterval == .Weekly && deliveryDay == days.rawValue {
                deliveryDayOfWeekArray.append((days.rawValue, true))
            } else {
                deliveryDayOfWeekArray.append((days.rawValue, false))
            }
        }
        deliveryDayOfWeekArray.removeFirst()        
    }    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if dataSource == nil {
            return 1
        } else {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section
        {
        case 0:
            return dataSource == nil ? kpiDataArr.count : 1
            
        case 1:
            switch typeOfDigit
            {
            case .Alert:
                return 3
                
            case .Reminder:
                if timeInterval == AlertTimeInterval.Daily
                {
                    return datePickerIsVisible ? 4 : 3
                }
                else
                {
                    return datePickerIsVisible ? 5 : 4
                }
            }
        case 2:
            return 1
            
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertSettingCell",
                                                 for: indexPath) as! AlertSettingTableViewCell
        
        let segmentCell = tableView.dequeueReusableCell(withIdentifier: "AlertTypeSwitcherCell",
                                                        for: indexPath) as! AlertTypeSwitcherTableViewCell
        segmentCell.delegate = self
        
        switch indexPath.section
        {
        case 0:
            cell.headerCellLabel.text = "Data source"
            
            if ReminderViewVC != nil
            {
                cell.selectionStyle = .none
                cell.accessoryType = .none
                cell.headerCellLabel.isHidden = true 
                cell.headerCellLabel.textColor = UIColor.lightGray
                cell.descriptionCellLabel.text = model.getNameKPI(FromID: dataSource!)
            }
            else
            {
                var kpiName = ""
                
                if dataSource != nil && creationMode == .createNew
                {
                    return segmentCell
                }
                else
                {
                    kpiName = model.kpis[indexPath.row].createdKPI!.KPI
                    cell.accessoryType = .none
                    cell.descriptionCellLabel.isHidden = true
                    cell.headerCellLabel.text = kpiName
                }
            }
            
        case 1:
            switch typeOfDigit
            {
            case .Alert:
                switch indexPath.row {
                case 0:
                    cell.headerCellLabel.text = "Condition"
                    cell.descriptionCellLabel.text = condition.rawValue
                    cell.descriptionCellLabel.isHidden = false 
                    
                case 1:
                    cell.headerCellLabel.text = "Threshold"
                    if threshold == nil {
                        cell.descriptionCellLabel.text = "Add data"
                    } else {
                        let formatter: NumberFormatter = NumberFormatter()
                        formatter.numberStyle = .decimal
                        formatter.maximumFractionDigits = 10
                        let formatedStr: String = formatter.string(from: NSNumber(value: threshold!))!
                        cell.descriptionCellLabel.text = formatedStr
                        cell.descriptionCellLabel.isHidden = false
                        cell.descriptionCellLabel.textAlignment = .right
                    }
                case 2:
                    cell.headerCellLabel.text = "Delivery time"
                    cell.descriptionCellLabel.text = deliveryAt
                    cell.accessoryType = .disclosureIndicator
                    cell.descriptionCellLabel.textAlignment = .right
                    cell.descriptionCellLabel.isHidden = false
                default:
                    break
                }
            case .Reminder:
                if timeInterval == AlertTimeInterval.Daily
                {
                    switch indexPath.row
                    {
                    case 0:
                        cell.headerCellLabel.text = "Time interval"
                        cell.descriptionCellLabel.text = timeInterval.rawValue
                        cell.descriptionCellLabel.isHidden = false
                        
                    case 1:
                        cell.headerCellLabel.text  = "Time zone"
                        
                        if let tz = timeZone
                        {
                            cell.descriptionCellLabel.text = tz
                        }
                        else if let sourceId = dataSource
                        {
                            let kpi = model.kpis.filter {
                                Int($0.id) == sourceId
                            }
                            
                            guard kpi.count > 0 else {
                                cell.descriptionCellLabel.text = ""
                                break
                            }
                            
                            let choosenKpi = kpi[0]                            
                            let tz = choosenKpi.createdKPI!.timeZone
                            
                            let tzArray = timeZoneArray.map {
                                set -> semenSettingsTuple in
                                if set.SettingName == tz
                                {
                                    return (set.SettingName, true)
                                }
                                else
                                {
                                    return set
                                }
                            }
                            
                            timeZoneArray = tzArray
                            
                            cell.descriptionCellLabel.text = tz
                        }
                        
                        cell.descriptionCellLabel.isHidden = false
                        
                    case 2:
                        let labelText = timeToString()
                        
                        cell.headerCellLabel.text = "Delivery time"
                        cell.descriptionCellLabel.text = labelText
                        cell.descriptionCellLabel.isHidden = false
                        cell.descriptionCellLabel.textAlignment = .right
                        cell.accessoryType = .disclosureIndicator
                        
                    case 3:
                        let dateCell =  tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerTableViewCell
                        dateCell.datePicker.setDate(deliveryTime ?? Date(), animated: true)
                        dateCell.alertSettingVC = self
                        dateCell.prepareForReuse()
                        return dateCell
                    default:
                        break
                    }
                } else {
                    switch indexPath.row {
                    case 0:
                        cell.headerCellLabel.text = "Time interval"
                        cell.descriptionCellLabel.text = timeInterval.rawValue
                        cell.descriptionCellLabel.isHidden = false
                        
                    case 1:
                        cell.headerCellLabel.text = "Delivery day"
                        cell.descriptionCellLabel.text = ""
                        
                        if timeInterval == .Weekly {
                            if deliveryDay != nil {
                                cell.descriptionCellLabel.text = deliveryDay
                            }
                        } else {
                            if deliveryDay != nil && Int(deliveryDay!)! > 28 {
                                cell.descriptionCellLabel.text = deliveryDay! + " or last day"
                            } else {
                                cell.descriptionCellLabel.text = deliveryDay
                            }
                        }
                    case 2:
                        cell.headerCellLabel.text  = "Time zone"
                        cell.descriptionCellLabel.text = timeZone
                        cell.accessoryType = .disclosureIndicator
                    case 3:
                        cell.headerCellLabel.text = "Delivery time"
                        cell.descriptionCellLabel.text = timeToString()
                        cell.descriptionCellLabel.textAlignment = .center
                        cell.accessoryType = .none
                    case 4:
                        let dateCell =  tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerTableViewCell
                        dateCell.datePicker.setDate(deliveryTime ?? Date(), animated: true)
                        dateCell.alertSettingVC = self
                        dateCell.prepareForReuse()
                        return dateCell
                    default:
                        break
                    }
                }
            }
            
        case 2:
            cell.headerCellLabel.text = "Type of notification"
            cell.descriptionCellLabel.isHidden = false
            cell.descriptionCellLabel.text = "Email"
            cell.accessoryType = .none
//            switch self.typeOfNotification.count {
//            case 0:
//                cell.descriptionCellLabel.isHidden = true
//            case 1:
//                cell.descriptionCellLabel.isHidden = false
//                cell.descriptionCellLabel.text = self.typeOfNotification[0].rawValue
//            case 2:
//                cell.descriptionCellLabel.isHidden = false
//                cell.descriptionCellLabel.text = "2 selected"
//            case 3:
//                cell.descriptionCellLabel.isHidden = false
//                cell.descriptionCellLabel.text = "3 selected"
//            default:
//                break
//            }
        default:
            break
        }
        cell.prepareForReuse()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        
        switch indexPath.section
        {
        case 0:
            if ReminderViewVC == nil
            {
                if dataSource != nil
                {
                    tableView.deselectRow(at: indexPath, animated: false)
                }
                else
                {
                    typeOfSetting = .none
                    dataSource = kpiDataArr[indexPath.row].dataId
                    title = "Alert"
                    animateTableViewRealoadData()
                    tableView.reloadData()
                }
            }
            
        case 1:
            
            switch typeOfDigit {
            case .Alert:
                switch indexPath.row {
                case 0:
                    typeOfSetting = .Condition
                    settingsArray = conditionArray
                    showSelectSettingVC()
                case 1:
                    typeOfSetting = .Threshold
                    showSelectSettingVC()
                case 2:
                    typeOfSetting = .OnlyWorksHours
                    settingsArray = deliveryAtArray
                    showSelectSettingVC()
                default:
                    break
                }
                return
            case .Reminder:
                if timeInterval == AlertTimeInterval.Daily   {
                    switch indexPath.row {
                    case 0:
                        self.typeOfSetting = Setting.TimeInterval
                        self.settingsArray = self.timeIntervalArray
                        self.showSelectSettingVC()
                    case 1:
                        self.typeOfSetting = Setting.TimeZone
                        self.settingsArray = self.timeZoneArray
                        self.showSelectSettingVC()
                    case 2:
                        if datePickerIsVisible && deliveryTime == nil {
                            deliveryTime = Date()
                            let cell = tableView.cellForRow(at: indexPath) as! AlertSettingTableViewCell
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeStyle = .short
                            cell.descriptionCellLabel.text = dateFormatter.string(from: Date())
                        }
                        showDatePicker(row: indexPath.row)
                        tableView.deselectRow(at: indexPath, animated: true)
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
                        self.typeOfSetting = Setting.DeliveryDay
                        if timeInterval == .Weekly {
                            settingsArray = deliveryDayOfWeekArray
                        } else {
                            settingsArray = deliveryDayOfMounthArray
                        }
                        self.showSelectSettingVC()
                    case 2:
                        self.typeOfSetting = Setting.TimeZone
                        self.settingsArray = self.timeZoneArray
                        self.showSelectSettingVC()
                    case 3:
                        if datePickerIsVisible && deliveryTime == nil {
                            deliveryTime = Date()
                            let cell = tableView.cellForRow(at: indexPath) as! AlertSettingTableViewCell
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeStyle = .short
                            cell.descriptionCellLabel.text = dateFormatter.string(from: Date())
                        }
                        showDatePicker(row: indexPath.row)
                        tableView.deselectRow(at: indexPath, animated: true)
                    default:
                        break
                    }
                }
            }
        case 2:
            tableView.deselectRow(at: indexPath, animated: true)
            break
            //self.typeOfSetting = Setting.TypeOfNotification
            //self.settingsArray = self.typeOfNotificationArray
            //self.showSelectSettingVC()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section == 1 {
            
            var newIndexPath = IndexPath()
            
            if timeInterval == AlertTimeInterval.Daily {
                switch indexPath.row {
                case 2,3:
                    return indexPath
                default:
                    newIndexPath = IndexPath(item: 3, section: 1)
                }
            } else {
                switch indexPath.row {
                case 3,4:
                    return indexPath
                default:
                    newIndexPath = IndexPath(item: 4, section: 1)
                }
            }
            if datePickerIsVisible {
                datePickerIsVisible = false
                tableView.deleteRows(at: [newIndexPath], with: .top)
            }
        }
        return indexPath
    }
    
    
    //MARK: - Date Picker
    func showDatePicker (row: Int) {
        datePickerIsVisible = !datePickerIsVisible
        
        savaButton.isEnabled = checkInputValues() ? true : false
        
        let indexPath = IndexPath(item: row + 1, section: 1)
        
        if datePickerIsVisible {
            tableView.insertRows(at: [indexPath], with: .top)
            tableView.scrollToNearestSelectedRow(at: .top, animated: true)
        } else {
            tableView.deleteRows(at: [indexPath], with: .top)
            tableView.deselectRow(at: IndexPath(item: row, section: 1), animated: true)
        }
    }
    
    //MARK: - convert time to string
    func timeToString() -> String {
        if deliveryTime == nil {
            return "Add time"
        } else {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: deliveryTime!)
        }
    }
    
    //MARK: - Show alert method
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func checkInputValues() -> Bool {
        switch typeOfDigit {
        case .Alert:
            if threshold == nil {
                return false
            }
        case .Reminder:
            if timeZone == nil || deliveryTime == nil || (deliveryDay == nil && timeInterval != .Daily) {
                return false
            }
        }
        return true
    }
    
    //MARK: - Save button was taped
    @IBAction func tapSaveButton(_ sender: UIBarButtonItem) {
        
        addWaitingSpinner(at: navigationController!.view.center,
                          color: OurColors.cyan)
        
        sender.isEnabled = false
        
        if creationMode == .createNew { addNewDigit() }
        else { updateDigit() }        
    }
    
    func addNewDigit() {
        let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
        
        switch typeOfDigit {
        case .Alert:
            let alert = Alert(context: context)
            
            if checkInputValues() {
                alert.sourceID = Int64(dataSource!)
                alert.condition = condition.rawValue
                alert.threshold = threshold!
                
                alert.emailNotificationIsActive = true
//                alert.smsNotificationIsAcive = false
//                alert.pushNotificationIsActive = false
//                
//                for notification in typeOfNotification {
//                    switch notification {
//                    case .Email:
//                        alert.emailNotificationIsActive = true
//                    case .SMS:
//                        alert.smsNotificationIsAcive = true
//                    case .Push:
//                        alert.pushNotificationIsActive = true
//                    default:
//                        break
//                    }
                //}
                
                //Send data to server
                let request = AddAlert(model: model)
                request.addAlert(alert: alert, success: {
                    self.removeWaitingSpinner()
                    self.model.alerts.append(alert)
                    let nc = NotificationCenter.default
                    nc.post(name: .modelDidChanged,
                            object: nil,
                            userInfo:["model": self.model])
                    self.navigationController!.popViewController(animated: true)
                }, failure: { error in
                    self.removeWaitingSpinner()
                    self.showAlert(title: "Error Occured", message: error)
                }
                )
            }
            
        case .Reminder:
            let reminder = Reminder(context: context)
            
            if checkInputValues() {
                reminder.sourceID = Int64(dataSource!)
                reminder.timeInterval = timeInterval.rawValue
                
                switch timeInterval {
                case .Daily:
                    reminder.deliveryDay = 1
                case .Weekly:
                    var numberOfDay: Int64 = 0
                    switch (WeeklyInterval(rawValue: deliveryDay!))! {
                    case .Monday:
                        numberOfDay = 1
                    case .Tuesday:
                        numberOfDay = 2
                    case .Wednesday:
                        numberOfDay = 3
                    case .Thursday:
                        numberOfDay = 4
                    case .Friday:
                        numberOfDay = 5
                    case .Saturday:
                        numberOfDay = 6
                    case .Sunday:
                        numberOfDay = 7
                    default:
                        break
                    }
                    reminder.deliveryDay = numberOfDay
                case .Monthly:
                    reminder.deliveryDay = Int64(deliveryDay!)!
                }
                
                reminder.timeZone = timeZone
                reminder.deliveryTime = deliveryTime as NSDate?
                
                reminder.emailNotificationIsActive = false
                reminder.smsNotificationIsActive = false
                reminder.pushNotificationIsActive = false
                
                for notification in typeOfNotification {
                    switch notification {
                    case .Email:
                        reminder.emailNotificationIsActive = true
                    case .SMS:
                        reminder.smsNotificationIsActive = true
                    case .Push:
                        reminder.pushNotificationIsActive = true
                    default:
                        break
                    }
                }
                
                //Send data to server
                let request = AddReminder(model: model)
                request.addReminder(reminder: reminder, success: {
                    self.removeWaitingSpinner()
                    self.model.reminders.append(reminder)
                    let nc = NotificationCenter.default
                    nc.post(name: .modelDidChanged,
                            object: nil,
                            userInfo:nil)
                    self.navigationController?.popViewController(animated: true)
                }, failure: {error in
                    self.removeWaitingSpinner()
                    self.showAlert(title: "Error Occured", message: error)
                })
            }
        }
    }
    
    func updateDigit() {
        
        switch typeOfDigit {
        case .Alert:
            
            model.alerts[indexOfDigit].setValue(threshold!, forKey: "threshold")
            model.alerts[indexOfDigit].setValue(condition.rawValue, forKey: "condition")
            model.alerts[indexOfDigit].setValue(deliveryAt == "At work hours" ? true : false, forKey: "onlyWorkHours")
            
            
            model.alerts[indexOfDigit].setValue(false, forKey: "emailNotificationIsActive")
            model.alerts[indexOfDigit].setValue(false, forKey: "smsNotificationIsAcive")
            model.alerts[indexOfDigit].setValue(false, forKey: "pushNotificationIsActive")
            
            for notification in typeOfNotification {
                switch notification {
                case .Email:
                    model.alerts[indexOfDigit].setValue(true, forKey: "emailNotificationIsActive")
                case .SMS:
                    model.alerts[indexOfDigit].setValue(true, forKey: "smsNotificationIsAcive")
                case .Push:
                    model.alerts[indexOfDigit].setValue(true, forKey: "pushNotificationIsActive")
                default:
                    break
                }
            }
            
            let request = EditAlert(model: model)
            request.editAlert(alert: model.alerts[indexOfDigit], success: {
                self.removeWaitingSpinner()
                let nc = NotificationCenter.default
                nc.post(name: .modelDidChanged,
                        object: nil,
                        userInfo:["model": self.model])
                self.navigationController!.popViewController(animated: true)
            }, failure: {error in
                self.savaButton.isEnabled = true
                self.removeWaitingSpinner()
                self.showAlert(title: "Error Occured", message: error)
            })
        case .Reminder:
            switch timeInterval {
            case .Daily:
                model.reminders[indexOfDigit].setValue(1, forKey: "deliveryDay")
            case .Weekly:
                var numberOfDay: Int64 = 0
                switch (WeeklyInterval(rawValue: deliveryDay!))! {
                case .Monday:
                    numberOfDay = 1
                case .Tuesday:
                    numberOfDay = 2
                case .Wednesday:
                    numberOfDay = 3
                case .Thursday:
                    numberOfDay = 4
                case .Friday:
                    numberOfDay = 5
                case .Saturday:
                    numberOfDay = 6
                case .Sunday:
                    numberOfDay = 7
                default:
                    break
                }
                model.reminders[indexOfDigit].setValue(numberOfDay, forKey: "deliveryDay")
            case .Monthly:
                model.reminders[indexOfDigit].setValue(Int64(deliveryDay!)!, forKey: "deliveryDay")
            }
            
            model.reminders[indexOfDigit].setValue(timeZone, forKey: "timeZone")
            model.reminders[indexOfDigit].setValue(timeInterval.rawValue, forKey: "timeInterval")
            
            if let deliveryDayString = deliveryDay, let deliveryDayInt = Int64(deliveryDayString)
            {
                model.reminders[indexOfDigit].setValue(deliveryDayInt, forKey: "deliveryDay")
            }
            
            model.reminders[indexOfDigit].setValue(deliveryTime, forKey: "deliveryTime")
            
            model.reminders[indexOfDigit].setValue(false, forKey: "emailNotificationIsActive")
            model.reminders[indexOfDigit].setValue(false, forKey: "smsNotificationIsActive")
            model.reminders[indexOfDigit].setValue(false, forKey: "pushNotificationIsActive")
            
            for notification in typeOfNotification {
                switch notification {
                case .Email:
                    model.reminders[indexOfDigit].setValue(true, forKey: "emailNotificationIsActive")
                case .SMS:
                    model.reminders[indexOfDigit].setValue(true, forKey: "smsNotificationIsActive")
                case .Push:
                    model.reminders[indexOfDigit].setValue(true, forKey: "pushNotificationIsActive")
                default:
                    break
                }
            }
            
            let request = EditReminder(model: model)
            request.editReminder(reminder: model.reminders[indexOfDigit], success: {
                self.removeWaitingSpinner()
                let nc = NotificationCenter.default
                nc.post(name: .modelDidChanged,
                        object: nil,
                        userInfo:["model": self.model])
                self.navigationController?.popViewController(animated: true)
            }, failure: {error in
                self.removeWaitingSpinner()
                self.savaButton.isEnabled = true 
                self.showAlert(title: "Error Occured", message: error)
            }
            )

        }
    }
    
    //MARK: - Show AlertSelectSettingViewController method
    func showSelectSettingVC() {
        let destinatioVC = AlertSelectSettingTableViewController.storyboardInstance() { vc in
            vc.AlertSettingVC = self
            vc.selectSetting = self.settingsArray
        }
        
        switch typeOfSetting
        {
        case .TypeOfNotification:
            destinatioVC.selectSeveralEnable = true
            
        case .Threshold:
            destinatioVC.inputSettingCells = true
            if threshold != nil {
                destinatioVC.textFieldInputData = "\(threshold!)"
            }
            switch self.condition
            {
            case .PercentHasDecreasedByMoreThan, .PercentHasIncreasedOrDecreasedByMoreThan, .PercentHasIncreasedByMoreThan:
                destinatioVC.headerForTableView = "Add data %"
                
            default:
                destinatioVC.headerForTableView = "Add data"
            }
            
        case .DeliveryDay:
            destinatioVC.segueWithSelect = true
            destinatioVC.tableView.isScrollEnabled = true
            
        case .DataSource:
            destinatioVC.title = "Source"
            destinatioVC.segueWithSelect = true
            
        default: destinatioVC.segueWithSelect = true; break
        }
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
    //MARK: - update all parameters from AlertViewVC
    func updateParameters(index: Int) {
        
        indexOfDigit = index
        
        switch typeOfDigit {
        case .Alert:
            let alert = model.alerts[index]
            //dataSource
            dataSource = Int(alert.sourceID)
            for kpi in model.kpis {
                if dataSource == kpi.id {
                    dataSourceArray.append((model.getNameKPI(FromID: kpi.id)!, true))
                } else {
                    dataSourceArray.append((model.getNameKPI(FromID: kpi.id)!, false))
                }
            }
            
            //Condition
            if let alertCondition = alert.condition {
                condition = Condition(rawValue: alertCondition)!
                var newConditionArray: [(SettingName: String, value: Bool)] = []
                for condition in conditionArray {
                    if condition.SettingName == self.condition.rawValue {
                        newConditionArray.append((condition.SettingName, true))
                    } else {
                        newConditionArray.append((condition.SettingName, false))
                    }
                }
                conditionArray = newConditionArray
            }
            
            //Threshold
            threshold = alert.threshold
            
            //TipeOfNotification
            
            if alert.emailNotificationIsActive {
                typeOfNotification.append(.Email)
            }
            if alert.pushNotificationIsActive {
                typeOfNotification.append(.Push)
            }
            if alert.smsNotificationIsAcive {
                typeOfNotification.append(.SMS)
            }
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
            
        case .Reminder:
            let reminder = model.reminders[index]
            //dataSource
            dataSource = Int(reminder.sourceID)
            for kpi in model.kpis {
                if dataSource == kpi.id {
                    dataSourceArray.append((model.getNameKPI(FromID: kpi.id)!, true))
                } else {
                    dataSourceArray.append((model.getNameKPI(FromID: kpi.id)!, false))
                }
            }
            
            //TimeInterval
            if let reminderTimeInterval = reminder.timeInterval {
                timeInterval = AlertTimeInterval(rawValue: reminderTimeInterval)!
                var newTimeIntervalArray: [(SettingName: String, value: Bool)] = []
                for interval in timeIntervalArray {
                    if interval.SettingName == timeInterval.rawValue {
                        newTimeIntervalArray.append((interval.SettingName, true))
                    } else {
                        newTimeIntervalArray.append((interval.SettingName, false))
                    }
                }
                self.timeIntervalArray = newTimeIntervalArray
            }
            
            //DeliveryDay
            deliveryDay = String(reminder.deliveryDay)
            var newDeliveryDayArray: [(SettingName: String, value: Bool)] = []
            for day in deliveryDayOfMounthArray {
                if day.SettingName == deliveryDay {
                    newDeliveryDayArray.append((day.SettingName, true))
                } else {
                    newDeliveryDayArray.append((day.SettingName, false))
                }
            }
            self.deliveryDayOfMounthArray = newDeliveryDayArray
            
            //DeliveryTime
            deliveryTime = reminder.deliveryTime as Date?
            
            //TimeZone
            var newTimeZoneArray: [(SettingName: String, value: Bool)] = []
            for zone in timeZoneArray {
                if zone.SettingName == reminder.timeZone {
                    newTimeZoneArray.append((zone.SettingName, true))
                } else {
                    newTimeZoneArray.append((zone.SettingName, false))
                }
            }
            timeZoneArray = newTimeZoneArray
            
            //TipeOfNotification
            
            if reminder.emailNotificationIsActive {
                typeOfNotification.append(.Email)
            }
            if reminder.pushNotificationIsActive {
                typeOfNotification.append(.Push)
            }
            if reminder.smsNotificationIsActive {
                typeOfNotification.append(.SMS)
            }
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
    
    //MARK: - CatchNotification
    func catchNotification(notification:Notification) -> Void {
        
        if notification.name == .modelDidChanged {
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    
}

//MARK: - updateSettingsArrayDelegate methods
extension AlertSettingsTableViewController: updateSettingsDelegate {
    
    func updateDoubleValue(number: Double?) {
        switch typeOfSetting {
        case .Threshold:
            threshold = number
        default:
            return
        }
        savaButton.isEnabled = checkInputValues() ? true : false
        tableView.reloadData()
    }
    
    func updateSettingsArray(array: [(SettingName: String, value: Bool)]) {
        switch typeOfSetting {
        case .DataSource:
            dataSourceArray = array
            for source in array {
                if source.value == true {
                    for kpi in model.kpis {
                        if kpi.createdKPI?.KPI == source.SettingName {
                            dataSource = kpi.id
                        }
                    }
                }
            }
            for kpi in model.kpis {
                if kpi.id == dataSource {
                    if kpi.createdKPI?.executant == model.profile?.userId {
                        typeOfDigit = .Reminder
                        navigationItem.title = "Reminder"
                    } else {
                        typeOfDigit = .Alert
                        navigationItem.title = "Alert"
                    }
                }
            }
        case .TimeInterval:
            timeIntervalArray = array
            for interval in array {
                if interval.value == true {
                    timeInterval = AlertTimeInterval(rawValue: interval.SettingName)!
                }
            }
            deliveryDay = nil
        case .DeliveryDay:
            
            if timeInterval == .Weekly {
                deliveryDayOfWeekArray = array
                for day in array {
                    if day.value == true {
                        deliveryDay = day.SettingName
                    }
                }
            } else {
                deliveryDayOfMounthArray = array
                for day in array {
                    if day.value == true {
                        deliveryDay = day.SettingName
                    }
                }
            }
        case .TimeZone:
            timeZoneArray = array
        case .Condition:
            conditionArray = array
            for condition in array {
                if condition.value == true {
                    self.condition = Condition(rawValue:condition.SettingName)!
                }
            }
        case .OnlyWorksHours:
            deliveryAtArray = array
        case .TypeOfNotification:
            typeOfNotificationArray = array
            typeOfNotification.removeAll()
            for notification in array {
                if notification.value == true {
                    typeOfNotification.append(TypeOfNotification(rawValue: notification.SettingName)!)
                }
            }
        default:
            return
        }
        savaButton.isEnabled = checkInputValues() ? true : false
        tableView.reloadData()
        typeOfSetting = .none
    }
    
    func updateStringValue(string: String?) {
    }
    
    func setAlert(type: TypeOfDigit) {
                
        title = type.rawValue
        typeOfDigit = type
        savaButton.isEnabled = checkInputValues()
        tableView.reloadData()
    }
}

extension AlertSettingsTableViewController: UpdateTimeDelegate {
    func updateTime(newTime time: Date) {
        
        if datePickerIsVisible {
            deliveryTime = time
            
            let rowNumber = tableView.numberOfRows(inSection: 1) - 2
            
            let indexPath = IndexPath(item: rowNumber, section: 1)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
