//
//  ChooseSuggestedKPITableViewController.swift
//  CoreKPI
//
//  Created by Семен on 27.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

enum WeeklyInterval: String {
    case none = ""
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
}

class ChooseSuggestedKPITableViewController: UITableViewController {
    
    var model: ModelCoreKPI!
    weak var KPIListVC: KPIsListTableViewController!
    let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
    
    enum TypeOfSetting: String {
        case none
        case Source
        case Service
        case Departament
        case SuggestedKPI = "Suggested KPI"
        case KPIName = "KPI name"
        case KPINote = "KPI note"
        case Executant
        case TimeInterval = "Time interval"
        case WeeklyInterval
        case MounthlyInterval
        case TimeZone = "Time zone"
        case Deadline
    }
    
    var delegate: updateKPIListDelegate!
    
    var source = Source.none
    var sourceArray: [(SettingName: String, value: Bool)] = [(Source.User.rawValue, false), (Source.Integrated.rawValue, false)]
    
    //MARK: - integarted services
    var integrated = IntegratedServices.none
    var saleForceKPIs: [SalesForceKPIs] = []
    var saleForceKPIArray: [(SettingName: String, value: Bool)] = []
    var quickBooksKPIs: [QiuckBooksKPIs] = []
    var quickBooksKPIArray: [(SettingName: String, value: Bool)] = []
    var googleAnalyticsKPIs: [GoogleAnalyticsKPIs] = []
    var googleAnalyticsKPIArray: [(SettingName: String, value: Bool)] = []
    var hubspotCRMKPIs: [HubSpotCRMKPIs] = []
    var hubSpotCRMKPIArray: [(SettingName: String, value: Bool)] = []
    var paypalKPIs: [PayPalKPIs] = []
    var payPalKPIArray: [(SettingName: String, value: Bool)] = []
    var hubspotMarketingKPIs: [HubSpotMarketingKPIs] = []
    var hubSpotMarketingKPIArray: [(SettingName: String, value: Bool)] = []
    
//    var oauthToken: String?
//    var oauthRefreshToken: String?
//    var oauthTokenExpiresAt: Date?
//    var viewID: String?
    
    var googleKPI: GoogleKPI?
    var payPalKPI: PayPalKPI?
    var salesForceKPI: SalesForceKPI?
    
    //MARK: User's KPI
    var department: Departments {
        for department in departmentArray {
            if department.value == true {
                return Departments(rawValue: department.SettingName)!
            }
        }
        return Departments.none
    }
    var departmentArray: [(SettingName: String, value: Bool)] = [(Departments.Sales.rawValue, false), (Departments.Procurement.rawValue, false), (Departments.Projects.rawValue, false), (Departments.FinancialManagement.rawValue, false), (Departments.Staff.rawValue, false)]
    var kpiName: String?
    var kpiArray: [(SettingName: String, value: Bool)] = []
    var kpiDescription: String?
    
    var executant: String? {
        for member in executantArray {
            if member.value == true {
                return member.SettingName
            }
        }
        return nil
    }
    
    var executantArray:  [(SettingName: String, value: Bool)] = []
    
    var timeInterval: TimeInterval {
        for interval in timeIntervalArray {
            if interval.value == true {
                return TimeInterval(rawValue: interval.SettingName)!
            }
        }
        return TimeInterval.Daily
    }
    var timeIntervalArray: [(SettingName: String, value: Bool)] = [(TimeInterval.Daily.rawValue, true), (TimeInterval.Weekly.rawValue, false), (TimeInterval.Monthly.rawValue, false)]
    
    var weeklyInterval: WeeklyInterval {
        get {
            for interval in weeklyArray {
                if interval.value == true {
                    return WeeklyInterval(rawValue: interval.SettingName)!
                }
            }
            return WeeklyInterval.none
        }
        set {
            var newWeeklyArray: [(SettingName: String, value: Bool)] = []
            for interval in weeklyArray {
                if interval.SettingName == newValue.rawValue {
                   newWeeklyArray.append((interval.SettingName, true))
                } else {
                    newWeeklyArray.append((interval.SettingName, false))
                }
            }
            weeklyArray = newWeeklyArray
        }

    }
    var weeklyArray: [(SettingName: String, value: Bool)] = [(WeeklyInterval.Monday.rawValue, false), (WeeklyInterval.Tuesday.rawValue, false), (WeeklyInterval.Wednesday.rawValue, false), (WeeklyInterval.Thursday.rawValue, false), (WeeklyInterval.Friday.rawValue, false), (WeeklyInterval.Saturday.rawValue, false), (WeeklyInterval.Sunday.rawValue, false)]
    
    var mounthlyInterval: Int? {
        get {
            for interval in mounthlyIntervalArray {
                if interval.value == true {
                    return Int(interval.SettingName)
                }
            }
            return nil
        }
        set {
            var newMounthlyIntervalArray: [(SettingName: String, value: Bool)] = []
            for interval in mounthlyIntervalArray {
                if interval.SettingName == "\(newValue!)" {
                    newMounthlyIntervalArray.append((interval.SettingName, true))
                } else {
                    newMounthlyIntervalArray.append((interval.SettingName, false))
                }
            }
            mounthlyIntervalArray = newMounthlyIntervalArray
        }

    }
    var mounthlyIntervalArray: [(SettingName: String, value: Bool)] = []
    
    var timeZone: String? {
        for timezone in timeZoneArray {
            if timezone.value == true {
                return timezone.SettingName
            }
        }
        return nil
    }
    var timeZoneArray: [(SettingName: String, value: Bool)] = [("Hawaii Time (HST)",false), ("Alaska Time (AKST)", false), ("Pacific Time (PST)",false), ("Mountain Time (MST)", false), ("Central Time (CST)", false), ("Eastern Time (EST)",false)]
    
    var deadline: Date?
    
    var typeOfSetting = TypeOfSetting.none
    var settingArray: [(SettingName: String, value: Bool)] = []
    
    let modelDidChangeNotification = Notification.Name(rawValue:"modelDidChange")
    
    var datePickerIsVisible = false
    var dataPickerIsVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(forName:modelDidChangeNotification, object:nil, queue:nil, using:catchNotification)
        
        createExecutantArray()
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkInputValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Create arrays for external services KPI
    func createExternalServicesArrays() {
        
        for saleforceKPI in iterateEnum(SalesForceKPIs.self) {
            saleForceKPIArray.append((saleforceKPI.rawValue, false))
        }
        for quickbookKPI in iterateEnum(QiuckBooksKPIs.self) {
            quickBooksKPIArray.append((quickbookKPI.rawValue, false))
        }
        for googleAnalyticsKPI in iterateEnum(GoogleAnalyticsKPIs.self) {
            googleAnalyticsKPIArray.append((googleAnalyticsKPI.rawValue, false))
        }
        for hubSpotmarketingKPI in iterateEnum(HubSpotMarketingKPIs.self) {
            hubSpotMarketingKPIArray.append((hubSpotmarketingKPI.rawValue, false))
        }
        for payPalKPI in iterateEnum(PayPalKPIs.self) {
            payPalKPIArray.append((payPalKPI.rawValue, false))
        }
        for hubSpotCrmKPI in iterateEnum(HubSpotCRMKPIs.self) {
            hubSpotCRMKPIArray.append((hubSpotCrmKPI.rawValue, false))
        }
    }
    
    //MARK: Enum iterator method
    func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafePointer(to: &i) {
                $0.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
            }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }
    
    
    
    //MARK: - updateKPIArray method
    func updateKPIArray() {
        self.kpiArray.removeAll()
        let buildInKPI = BuildInKPI(department: self.department)
        var dictionary: [String:String] = [:]
        
        switch department {
        case .none:
            return
        case .Sales:
            dictionary = buildInKPI.salesDictionary
        case .Procurement:
            dictionary = buildInKPI.procurementDictionary
        case .Projects:
            dictionary = buildInKPI.projectDictionary
        case .FinancialManagement:
            dictionary = buildInKPI.financialManagementDictionary
        case .Staff:
            dictionary = buildInKPI.staffDictionary
        }
        for kpi in dictionary {
            let arrayElement = (kpi.key, false)
            self.kpiArray.append(arrayElement)
        }
    }
    
    //MARK: - get Department list from server
    //MARK: not use in App
    func getDepartmentsFromServer() {
        
        let request = Request(model: model)
        
        let data: [String : Any] = [:]
        
        request.getJson(category: "/kpi/getDepartments", data: data,
                        success: { json in
                            self.parsingJson(json: json)
        },
                        failure: { (error) in
                            print(error)
                            self.showAlert(title: "Sorry!", message: error)
        }
        )
    }
    
    func parsingJson(json: NSDictionary) {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSArray {
                    
                    print(dataKey)
                    //Save data from json
                    
                } else {
                    print("Json data is broken")
                }
            } else {
                let errorMessage = json["message"] as! String
                print("Json error message: \(errorMessage)")
                showAlert(title: "Error geting list if departments", message: errorMessage)
            }
        } else {
            print("Json file is broken!")
        }
    }
    
    //MARK: create executantArray
    func createExecutantArray() {
        for profile in model.team {
            let executantName = profile.firstName! + " " + profile.lastName!
            self.executantArray.append((executantName, false))
        }
    }
    
    //MARK: - catchNotification
    func catchNotification(notification:Notification) -> Void {
        
        if notification.name == self.modelDidChangeNotification {
            self.model.team = model.team
            executantArray.removeAll()
            createExecutantArray()
            tableView.reloadData()
        }
    }
    
    //MARK: - Show alert method
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch source {
        case .none:
            return 1
        case .User:
            switch timeInterval {
            case .Daily:
                return datePickerIsVisible == false ? 9 : 10
            default:
                if dataPickerIsVisible {
                    return datePickerIsVisible == false ? 11 : 12
                } else {
                    return datePickerIsVisible == false ? 10 : 11
                }
            }
        case .Integrated:
            var numberOfKPIs = 0
            var arrayOfKPIs: [(SettingName: String, value: Bool)] = []
            
            switch integrated {
            case .none:
                return 2
            case .SalesForce:
                arrayOfKPIs = saleForceKPIArray
            case .Quickbooks:
                arrayOfKPIs = quickBooksKPIArray
            case .GoogleAnalytics:
                arrayOfKPIs = googleAnalyticsKPIArray
            case .HubSpotCRM:
                arrayOfKPIs = hubSpotCRMKPIArray
            case .PayPal:
                arrayOfKPIs = payPalKPIArray
            case .HubSpotMarketing:
                arrayOfKPIs = hubSpotMarketingKPIArray
            }
            for value in arrayOfKPIs {
                if value.value == true {
                    numberOfKPIs += 1
                }
            }
            return 2 + numberOfKPIs
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let SuggestedCell = tableView.dequeueReusableCell(withIdentifier: "SuggestedKPICell", for: indexPath) as! DashboardSetingTableViewCell
        
        switch source {
        case .none:
            SuggestedCell.headerOfCell.text = "Source"
            SuggestedCell.descriptionOfCell.text = source.rawValue
        case .User:
            SuggestedCell.accessoryType = .disclosureIndicator
            SuggestedCell.trailingToRightConstraint.constant = 0
            switch timeInterval {
            case .Daily:
                switch indexPath.row {
                case 0:
                    SuggestedCell.headerOfCell.text = "Source"
                    SuggestedCell.descriptionOfCell.text = source.rawValue
                case 1:
                    SuggestedCell.headerOfCell.text = "Department"
                    SuggestedCell.descriptionOfCell.text = department.rawValue
                case 2:
                    SuggestedCell.headerOfCell.text = "Suggested KPI"
                    SuggestedCell.descriptionOfCell.text = "(Optional)"
                case 3:
                    SuggestedCell.headerOfCell.text = "KPI Name"
                    SuggestedCell.descriptionOfCell.text = self.kpiName ?? ""
                case 4:
                    let DescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! KPIDescriptionTableViewCell
                    DescriptionCell.headerOfCellLabel.text = "KPI Note"
                    DescriptionCell.descriptionOfCellLabel.text = self.kpiDescription == nil ? "Add note (Optional)" : ""
                    if self.kpiDescription == nil {
                        DescriptionCell.kpiInfoTextLabel.isHidden = true
                    } else {
                        DescriptionCell.kpiInfoTextLabel.isHidden = false
                        DescriptionCell.kpiInfoTextLabel.text = self.kpiDescription
                    }
                    DescriptionCell.prepareForReuse()
                    return DescriptionCell
                case 5:
                    SuggestedCell.headerOfCell.text = "Executant"
                    SuggestedCell.descriptionOfCell.text = self.executant ?? ""
                case 6:
                    SuggestedCell.headerOfCell.text = "Time Interval"
                    SuggestedCell.descriptionOfCell.text = timeInterval.rawValue
                case 7:
                    SuggestedCell.headerOfCell.text = "Time Zone"
                    SuggestedCell.descriptionOfCell.text = timeZone ?? ""
                case 8:
                    SuggestedCell.headerOfCell.text = "Deadline"
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .short
                    if deadline == nil {
                        SuggestedCell.descriptionOfCell.text = ""
                    } else {
                        SuggestedCell.descriptionOfCell.text = dateFormatter.string(for: deadline)
                    }
                case 9:
                    let datePickerCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath)  as! DatePickerTableViewCell
                    datePickerCell.datePicker.setDate(deadline ?? Date(), animated: true)
                    datePickerCell.addKPIVC = self
                    return datePickerCell
                default:
                    break
                }
            case .Weekly, .Monthly:
                
                if dataPickerIsVisible {
                    switch indexPath.row {
                    case 0:
                        SuggestedCell.headerOfCell.text = "Source"
                        SuggestedCell.descriptionOfCell.text = source.rawValue
                    case 1:
                        SuggestedCell.headerOfCell.text = "Department"
                        SuggestedCell.descriptionOfCell.text = department.rawValue
                    case 2:
                        SuggestedCell.headerOfCell.text = "Suggested KPI"
                        SuggestedCell.descriptionOfCell.text = "(Optional)"
                    case 3:
                        SuggestedCell.headerOfCell.text = "KPI Name"
                        SuggestedCell.descriptionOfCell.text = self.kpiName ?? ""
                    case 4:
                        let DescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! KPIDescriptionTableViewCell
                        DescriptionCell.headerOfCellLabel.text = "KPI Note"
                        DescriptionCell.descriptionOfCellLabel.text = self.kpiDescription == nil ? "Add note (Optional)" : ""
                        DescriptionCell.kpiInfoTextLabel.text = self.kpiDescription ?? ""
                        DescriptionCell.prepareForReuse()
                        return DescriptionCell
                    case 5:
                        SuggestedCell.headerOfCell.text = "Executant"
                        SuggestedCell.descriptionOfCell.text = self.executant ?? ""
                    case 6:
                        SuggestedCell.headerOfCell.text = "Time Interval"
                        SuggestedCell.descriptionOfCell.text = timeInterval.rawValue
                    case 7:
                        SuggestedCell.headerOfCell.text = "Day"
                        var text = ""
                        switch timeInterval {
                        case .Weekly:
                            text = self.weeklyInterval.rawValue
                        case .Monthly:
                            if self.mounthlyInterval != nil && self.mounthlyInterval! > 28 {
                                text = "\(self.mounthlyInterval!) or last day"
                            } else if self.mounthlyInterval != nil{
                                text = "\(self.mounthlyInterval!)"
                            } else {
                                text = ""
                            }
                        default:
                            break
                        }
                        SuggestedCell.descriptionOfCell.text = text
                    case 8:
                        let dataPickerCell = tableView.dequeueReusableCell(withIdentifier: "DataPickerCell", for: indexPath)  as! DataPickerTableViewCell
                        dataPickerCell.dataPicker.reloadAllComponents()
                        switch timeInterval {
                        case .Daily:
                            break
                        case .Weekly:
                            if weeklyInterval == .none {
                                dataPickerCell.dataPicker.selectRow(0, inComponent: 0, animated: false)
                            }
                        case .Monthly:
                            if mounthlyInterval == nil {
                                dataPickerCell.dataPicker.selectRow(0, inComponent: 0, animated: false)
                            }
                        }
                        dataPickerCell.dataPicker.selectedRow(inComponent: 0)
                        return dataPickerCell
                    case 9:
                        SuggestedCell.headerOfCell.text = "Time Zone"
                        SuggestedCell.descriptionOfCell.text = timeZone ?? ""
                    case 10:
                        SuggestedCell.headerOfCell.text = "Deadline"
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeStyle = .short
                        if deadline == nil {
                            SuggestedCell.descriptionOfCell.text = ""
                        } else {
                            SuggestedCell.descriptionOfCell.text = dateFormatter.string(for: deadline)
                        }
                    case 11:
                        let datePickerCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerTableViewCell
                        datePickerCell.addKPIVC = self
                        return datePickerCell
                    default:
                        break
                    }
                } else {
                    switch indexPath.row {
                    case 0:
                        SuggestedCell.headerOfCell.text = "Source"
                        SuggestedCell.descriptionOfCell.text = source.rawValue
                    case 1:
                        SuggestedCell.headerOfCell.text = "Department"
                        SuggestedCell.descriptionOfCell.text = department.rawValue
                    case 2:
                        SuggestedCell.headerOfCell.text = "Suggested KPI"
                        SuggestedCell.descriptionOfCell.text = "(Optional)"
                    case 3:
                        SuggestedCell.headerOfCell.text = "KPI Name"
                        SuggestedCell.descriptionOfCell.text = self.kpiName ?? ""
                    case 4:
                        let DescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! KPIDescriptionTableViewCell
                        DescriptionCell.headerOfCellLabel.text = "KPI Note"
                        DescriptionCell.descriptionOfCellLabel.text = self.kpiDescription == nil ? "Add note (Optional)" : ""
                        DescriptionCell.kpiInfoTextLabel.text = self.kpiDescription ?? ""
                        DescriptionCell.prepareForReuse()
                        return DescriptionCell
                    case 5:
                        SuggestedCell.headerOfCell.text = "Executant"
                        SuggestedCell.descriptionOfCell.text = self.executant ?? ""
                    case 6:
                        SuggestedCell.headerOfCell.text = "Time Interval"
                        SuggestedCell.descriptionOfCell.text = timeInterval.rawValue
                    case 7:
                        SuggestedCell.headerOfCell.text = "Day"
                        var text = ""
                        switch timeInterval {
                        case .Weekly:
                            text = self.weeklyInterval.rawValue
                        case .Monthly:
                            if self.mounthlyInterval != nil && self.mounthlyInterval! > 28 {
                                text = "\(self.mounthlyInterval!) or last day"
                            } else if self.mounthlyInterval != nil{
                                text = "\(self.mounthlyInterval!)"
                            } else {
                                text = "Add day"
                            }
                        default:
                            break
                        }
                        SuggestedCell.descriptionOfCell.text = text
                    case 8:
                        SuggestedCell.headerOfCell.text = "Time Zone"
                        SuggestedCell.descriptionOfCell.text = timeZone ?? ""
                    case 9:
                        SuggestedCell.headerOfCell.text = "Deadline"
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeStyle = .short
                        if deadline == nil {
                            SuggestedCell.descriptionOfCell.text = ""
                        } else {
                            SuggestedCell.descriptionOfCell.text = dateFormatter.string(for: deadline)
                        }
                    case 10:
                        let datePickerCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerTableViewCell
                        datePickerCell.addKPIVC = self
                        return datePickerCell
                    default:
                        break
                    }
                }
                

            }
        case .Integrated:
            switch indexPath.row {
            case 0:
                SuggestedCell.headerOfCell.text = "Source"
                SuggestedCell.descriptionOfCell.text = source.rawValue
            case 1:
                SuggestedCell.headerOfCell.text = "Service"
                SuggestedCell.descriptionOfCell.text = integrated.rawValue
            default:
                SuggestedCell.headerOfCell.text = "KPI \(indexPath.row - 1)"
                SuggestedCell.accessoryType = .none
                SuggestedCell.selectionStyle = .none
                SuggestedCell.trailingToRightConstraint.constant = 16.0
                switch integrated {
                case .SalesForce:
                    SuggestedCell.descriptionOfCell.text = saleForceKPIs[indexPath.row - 2].rawValue
                case .Quickbooks:
                    SuggestedCell.descriptionOfCell.text = quickBooksKPIs[indexPath.row - 2].rawValue
                case .GoogleAnalytics:
                    SuggestedCell.descriptionOfCell.text = googleAnalyticsKPIs[indexPath.row - 2].rawValue
                case .HubSpotCRM:
                    SuggestedCell.descriptionOfCell.text = hubspotCRMKPIs[indexPath.row - 2].rawValue
                case .PayPal:
                    SuggestedCell.descriptionOfCell.text = paypalKPIs[indexPath.row - 2].rawValue
                case .HubSpotMarketing:
                    SuggestedCell.descriptionOfCell.text = hubspotMarketingKPIs[indexPath.row - 2].rawValue
                default:
                    break
                }
            }
        }
        SuggestedCell.prepareForReuse()
        return SuggestedCell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch source {
        case .none:
            break
        case .User:
            var newIndexPath = IndexPath()
            switch timeInterval {
            case .Daily:
                switch indexPath.row {
                case 8,9:
                    return indexPath
                default:
                    newIndexPath = IndexPath(item: 9, section: 0)
                }
            case .Weekly, .Monthly:
                if dataPickerIsVisible {
                    switch indexPath.row {
                    case 7,8:
                        return indexPath
                    default:
                        newIndexPath = IndexPath(item: 8, section: 0)
                    }
                } else {
                    switch indexPath.row {
                    case 9,10:
                        return indexPath
                    default:
                        newIndexPath = IndexPath(item: 10, section: 0)
                    }
                }
            }
            
            if datePickerIsVisible {
                datePickerIsVisible = false
                tableView.deleteRows(at: [newIndexPath], with: .top)
            }
            if dataPickerIsVisible {
                dataPickerIsVisible = false
                tableView.deleteRows(at: [newIndexPath], with: .top)
                if indexPath.row > 7 {
                    newIndexPath = IndexPath(item: indexPath.row - 1, section: 0)
                    return newIndexPath
                }
            }
        case .Integrated:
            break
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch source {
        case .none:
            typeOfSetting = .Source
            settingArray = sourceArray
            showSelectSettingVC()
        case .User:
            
            switch timeInterval {
            case .Daily:
                switch indexPath.row {
                case 0:
                    typeOfSetting = .Source
                    settingArray = sourceArray
                    showSelectSettingVC()
                case 1:
                    typeOfSetting = .Departament
                    settingArray = departmentArray
                    showSelectSettingVC()
                case 2:
                    if department == .none {
                        showAlert(title: "Error", message: "First select a department please")
                        tableView.deselectRow(at: indexPath, animated: true)
                    } else {
                        typeOfSetting = .SuggestedKPI
                        settingArray = kpiArray
                        showSelectSettingVC()
                    }
                case 3:
                    typeOfSetting = .KPIName
                    showSelectSettingVC()
                case 4:
                    typeOfSetting = .KPINote
                    showSelectSettingVC()
                case 5:
                    typeOfSetting = .Executant
                    settingArray = executantArray
                    showSelectSettingVC()
                case 6:
                    typeOfSetting = .TimeInterval
                    settingArray = timeIntervalArray
                    showSelectSettingVC()
                case 7:
                    typeOfSetting = .TimeZone
                    settingArray = timeZoneArray
                    showSelectSettingVC()
                case 8:
                    showDatePicker(row: indexPath.row)
                    tableView.deselectRow(at: indexPath, animated: true)
                default:
                    break
                }
            case .Weekly, .Monthly:
                if dataPickerIsVisible {
                    switch indexPath.row {
                    case 0:
                        typeOfSetting = .Source
                        settingArray = sourceArray
                        showSelectSettingVC()
                    case 1:
                        typeOfSetting = .Departament
                        settingArray = departmentArray
                        showSelectSettingVC()
                    case 2:
                        if department == .none {
                            showAlert(title: "Error", message: "First select a department please")
                            tableView.deselectRow(at: indexPath, animated: true)
                        } else {
                            typeOfSetting = .SuggestedKPI
                            settingArray = kpiArray
                            showSelectSettingVC()
                        }
                    case 3:
                        typeOfSetting = .KPIName
                        showSelectSettingVC()
                    case 4:
                        typeOfSetting = .KPINote
                        showSelectSettingVC()
                    case 5:
                        typeOfSetting = .Executant
                        settingArray = executantArray
                        showSelectSettingVC()
                    case 6:
                        typeOfSetting = .TimeInterval
                        settingArray = timeIntervalArray
                        showSelectSettingVC()
                    case 7:
                        tableView.deselectRow(at: indexPath, animated: true)
                        dataPickerIsVisible = false
                        let index = IndexPath(item: 8, section: 0)
                        tableView.deleteRows(at: [index], with: .fade)
                        switch timeInterval {
                        case .Daily:
                            break
                        case .Weekly:
                            if weeklyInterval == .none {
                                weeklyInterval = .Monday
                            }
                        case .Monthly:
                            if mounthlyInterval == nil {
                                mounthlyInterval = 1
                            }
                        }
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    case 9:
                        typeOfSetting = .TimeZone
                        settingArray = timeZoneArray
                        showSelectSettingVC()
                    case 10:
                        showDatePicker(row: indexPath.row)
                        tableView.deselectRow(at: indexPath, animated: true)
                        
                    default:
                        break
                    }
                } else {
                    switch indexPath.row {
                    case 0:
                        typeOfSetting = .Source
                        settingArray = sourceArray
                        showSelectSettingVC()
                    case 1:
                        typeOfSetting = .Departament
                        settingArray = departmentArray
                        showSelectSettingVC()
                    case 2:
                        if department == .none {
                            showAlert(title: "Error", message: "First select a department please")
                            tableView.deselectRow(at: indexPath, animated: true)
                        } else {
                            typeOfSetting = .SuggestedKPI
                            settingArray = kpiArray
                            showSelectSettingVC()
                        }
                    case 3:
                        typeOfSetting = .KPIName
                        showSelectSettingVC()
                    case 4:
                        typeOfSetting = .KPINote
                        showSelectSettingVC()
                    case 5:
                        typeOfSetting = .Executant
                        settingArray = executantArray
                        showSelectSettingVC()
                    case 6:
                        typeOfSetting = .TimeInterval
                        settingArray = timeIntervalArray
                        showSelectSettingVC()
                    case 7:
                        tableView.deselectRow(at: indexPath, animated: true)
                        dataPickerIsVisible = true
                        let index = IndexPath(item: 8, section: 0)
                        tableView.insertRows(at: [index], with: .fade)
                        tableView.scrollToRow(at: index, at: .bottom, animated: true)
                    case 8:
                        typeOfSetting = .TimeZone
                        settingArray = timeZoneArray
                        showSelectSettingVC()
                    case 9:
                        showDatePicker(row: indexPath.row)
                        tableView.deselectRow(at: indexPath, animated: true)
                        
                    default:
                        break
                    }
                }
            }
        case .Integrated:
            switch indexPath.row {
            case 0:
                typeOfSetting = .Source
                settingArray = sourceArray
                showSelectSettingVC()
            case 1:
                typeOfSetting = .Service
                showIntegratedServicesVC()
                tableView.deselectRow(at: indexPath, animated: true)
                
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 13)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK: - Date Picker
    
    func showDatePicker (row: Int) {
        datePickerIsVisible = !datePickerIsVisible
        
        let indexPath = IndexPath(item: row + 1, section: 0)
        
        if datePickerIsVisible {
            tableView.insertRows(at: [indexPath], with: .top)
            tableView.scrollToNearestSelectedRow(at: .top, animated: true)
        } else {
            tableView.deleteRows(at: [indexPath], with: .top)
            tableView.deselectRow(at: IndexPath(item: row, section: 0), animated: true)
            if deadline == nil {
                deadline = Date()
                tableView.reloadRows(at: [IndexPath(item: row, section: 0)], with: .none)
            }
            checkInputValues()
        }
    }
    
    //MARK: - Check input values
    func checkInputValues() {
        if dataIsEntered() {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func dataIsEntered() -> Bool {
        switch source {
        case .Integrated:
            if source == .none || (source == .Integrated && integrated == .none) {
                return false
            }
        case .User:
            if department == .none || kpiName == nil || executant == nil || (timeInterval == TimeInterval.Weekly && weeklyInterval == WeeklyInterval.none) || (timeInterval == TimeInterval.Monthly && mounthlyInterval == nil) || timeZone == nil || deadline == nil {
                return false
            }
        default:
            return false
        }
        return true
    }
    
    //MARK: - Save KPI
    @IBAction func tapSaveButton(_ sender: UIBarButtonItem) {
        
        if !dataIsEntered() {
            return
        }
        
        var kpi: KPI!
        
        switch source {
        case .Integrated:
            var arrayOfKPI: [(SettingName: String, value: Bool)] = []
            //var googleKPI: GoogleKPI?
            //var saleForceKPI: SalesForceKPI?
            
            switch integrated {
            case .SalesForce:
                arrayOfKPI = saleForceKPIArray
//                saleForceKPI = SalesForceKPI(context: context)
//                saleForceKPI?.oAuthToken = oauthToken
//                saleForceKPI?.oAuthRefreshToken = oauthRefreshToken
            case .Quickbooks:
                arrayOfKPI = quickBooksKPIArray
            case .GoogleAnalytics:
                arrayOfKPI = googleAnalyticsKPIArray
//                googleKPI = GoogleKPI(context: context)
//                googleKPI?.oAuthToken = oauthToken
//                googleKPI?.oAuthRefreshToken = oauthRefreshToken
//                googleKPI?.oAuthTokenExpiresAt = oauthTokenExpiresAt! as NSDate
//                googleKPI?.viewID = viewID
            case .PayPal:
                arrayOfKPI = payPalKPIArray
            case .HubSpotCRM:
                arrayOfKPI = hubSpotCRMKPIArray
            case .HubSpotMarketing:
                arrayOfKPI = hubSpotMarketingKPIArray
            default:
                break
            }
            
            for extKpi in arrayOfKPI {
                if extKpi.value {
                    let externalKPI = ExternalKPI(context: context)
                    externalKPI.serviceName = integrated.rawValue
                    externalKPI.kpiName = extKpi.SettingName
                    externalKPI.googleAnalyticsKPI = googleKPI
                    externalKPI.payPalKPI = payPalKPI
                    externalKPI.saleForceKPI = salesForceKPI
                    
                    do {
                        try self.context.save()
                    } catch {
                        print(error)
                        return
                    }
                    
                    kpi = KPI(kpiID: -1, typeOfKPI: .IntegratedKPI, integratedKPI: externalKPI, createdKPI: nil, imageBacgroundColour: UIColor(hex: "D8F7D7".hex!))
                    
                    self.delegate = self.KPIListVC
                    self.delegate.addNewKPI(kpi: kpi)
                    
                }
            }
            
            let KPIListVC = self.navigationController?.viewControllers[0] as! KPIsListTableViewController
            _ = self.navigationController?.popToViewController(KPIListVC, animated: true)
        case .User:
            var executantProfile: Int!
            
            for profile in model.team {
                if executant?.components(separatedBy: " ")[0] == profile.firstName && executant?.components(separatedBy: " ")[1] == profile.lastName {
                    executantProfile = Int(profile.userID)
                }
            }
            
            var deadlineDay = 1
            switch timeInterval {
            case .Daily:
                deadlineDay = 1
            case .Weekly:
                switch weeklyInterval {
                case .Monday:
                    deadlineDay = 1
                case .Tuesday:
                    deadlineDay = 2
                case .Wednesday:
                    deadlineDay = 3
                case .Thursday:
                    deadlineDay = 4
                case .Friday:
                    deadlineDay = 5
                case .Saturday:
                    deadlineDay = 6
                case .Sunday:
                    deadlineDay = 7
                case .none:
                    break
                }
            case .Monthly:
                if let day = mounthlyInterval {
                    deadlineDay = day
                }
            }
            
            let userKPI = CreatedKPI(source: .User, department: department, KPI: kpiName!, descriptionOfKPI: kpiDescription, executant: executantProfile, timeInterval: timeInterval, deadlineDay: deadlineDay, timeZone: timeZone!, deadlineTime: deadline!, number: [])
            var imageBacgroundColour: UIColor = .clear
            if userKPI.executant == model.profile?.userId {
                imageBacgroundColour = UIColor(hex: "E3F2FD".hex!)
            } else {
                imageBacgroundColour = UIColor(hex: "FBE9E7".hex!)
            }
            
            kpi = KPI(kpiID: 0, typeOfKPI: .createdKPI, integratedKPI: nil, createdKPI: userKPI, imageBacgroundColour: imageBacgroundColour)
            
            let request = AddKPI(model: model)
            request.addKPI(kpi: kpi, success: { id in
                kpi.id = id
                self.delegate = self.KPIListVC
                self.delegate.addNewKPI(kpi: kpi)
                let KPIListVC = self.navigationController?.viewControllers[0] as! KPIsListTableViewController
                _ = self.navigationController?.popToViewController(KPIListVC, animated: true)
            }, failure: { error in
                self.showAlert(title: "Sorry", message: error)
                
            }
            )
        default:
            break
        }
    }
    
    //MARK: - Show KPISelectSettingTableViewController method
    func showSelectSettingVC() {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "SelectSettingForKPI") as! KPISelectSettingTableViewController
        destinatioVC.ChoseSuggestedVC = self
        destinatioVC.selectSetting = settingArray
        destinatioVC.segueWithSelecting = true
        switch typeOfSetting {
        case .SuggestedKPI:
            destinatioVC.rowsWithInfoAccesory = true
            destinatioVC.department = self.department
        case .KPIName:
            destinatioVC.inputSettingCells = true
            destinatioVC.textFieldInputData = self.kpiName
            destinatioVC.headerForTableView = "KPI name"
        case .KPINote:
            destinatioVC.inputSettingCells = true
            destinatioVC.textFieldInputData = self.kpiDescription
            destinatioVC.headerForTableView = "KPI note"
        default:
            break
        }
        
        destinatioVC.navigationItem.rightBarButtonItem = nil
        let backItem = UIBarButtonItem()
        backItem.title = " "
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = " "
        navigationItem.backBarButtonItem = backItem
    }
    
    //MARK: - Show SelectIntegratedServicesViewController method
    func showIntegratedServicesVC() {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "SelectIntegratedServices") as! SelectIntegratedServicesViewController
        destinatioVC.chooseSuggestKPIVC = self
        
        destinatioVC.saleForceKPIArray = self.saleForceKPIArray
        destinatioVC.quickBooksKPIArray = self.quickBooksKPIArray
        destinatioVC.googleAnalyticsKPIArray = self.googleAnalyticsKPIArray
        destinatioVC.hubSpotCRMKPIArray = self.hubSpotCRMKPIArray
        destinatioVC.payPalKPIArray = self.payPalKPIArray
        destinatioVC.hubSpotMarketingKPIArray = self.hubSpotMarketingKPIArray
        
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
}

//MARK: - updateSettingArrayDelegate methods
extension ChooseSuggestedKPITableViewController: updateSettingsDelegate {
    func updateSettingsArray(array: [(SettingName: String, value: Bool)]) {
        switch typeOfSetting {
        case .Source:
            self.sourceArray = array
            for source in array {
                if source.value == true {
                    self.source = Source(rawValue: source.SettingName)!
                }
            }
            if source == .User {
                self.tableView.isScrollEnabled = true
            } else {
                self.tableView.isScrollEnabled = false
                createExternalServicesArrays()
            }
        case .Service:
            switch integrated {
            case .SalesForce:
                self.saleForceKPIArray = array
                self.saleForceKPIs.removeAll()
                for kpi in array{
                    if kpi.value == true {
                        saleForceKPIs.append(SalesForceKPIs(rawValue: kpi.SettingName)!)
                    }
                }
            case .Quickbooks:
                self.quickBooksKPIArray = array
                self.quickBooksKPIs.removeAll()
                for kpi in array{
                    if kpi.value == true {
                        quickBooksKPIs.append(QiuckBooksKPIs(rawValue: kpi.SettingName)!)
                    }
                }
            case .GoogleAnalytics:
                self.googleAnalyticsKPIArray = array
                self.googleAnalyticsKPIs.removeAll()
                for kpi in array{
                    if kpi.value == true {
                        googleAnalyticsKPIs.append(GoogleAnalyticsKPIs(rawValue: kpi.SettingName)!)
                    }
                }
            case .HubSpotCRM:
                self.hubSpotCRMKPIArray = array
                self.hubspotCRMKPIs.removeAll()
                for kpi in array{
                    if kpi.value == true {
                        hubspotCRMKPIs.append(HubSpotCRMKPIs(rawValue: kpi.SettingName)!)
                    }
                }
            case .PayPal:
                self.payPalKPIArray = array
                self.paypalKPIs.removeAll()
                for kpi in array{
                    if kpi.value == true {
                        paypalKPIs.append(PayPalKPIs(rawValue: kpi.SettingName)!)
                    }
                }
            case .HubSpotMarketing:
                self.hubSpotMarketingKPIArray = array
                self.hubspotMarketingKPIs.removeAll()
                for kpi in array{
                    if kpi.value == true {
                        hubspotMarketingKPIs.append(HubSpotMarketingKPIs(rawValue: kpi.SettingName)!)
                    }
                }
            default:
                break
            }
            self.tableView.isScrollEnabled = true
        case .Departament:
            let oldDepartmentValue = self.department
            self.departmentArray = array
            if oldDepartmentValue != self.department {
                self.updateKPIArray()
            }
        case .SuggestedKPI:
            self.kpiArray = array
            //update kpi name
            var kpiNameDidChanged = false
            for kpi in self.kpiArray {
                if kpi.value == true {
                    self.kpiName = kpi.SettingName
                    kpiNameDidChanged = true
                }
            }
            if !kpiNameDidChanged {
                self.kpiName = nil
            }
            //upadate kpi description
            let buildInKPI = BuildInKPI(department: self.department)
            var dictionary: [String: String]!
            switch department {
            case .none:
                self.kpiDescription = nil
            case .Sales:
                dictionary = buildInKPI.salesDictionary
            case .Procurement:
                dictionary = buildInKPI.procurementDictionary
            case .FinancialManagement:
                dictionary = buildInKPI.financialManagementDictionary
            case .Projects:
                dictionary = buildInKPI.projectDictionary
            case .Staff:
                dictionary = buildInKPI.staffDictionary
            }
            if self.kpiName != nil {
                self.kpiDescription = dictionary[self.kpiName!]
            } else {
                self.kpiDescription = nil
            }
        case .Executant:
            self.executantArray = array
        case .TimeInterval:
            let oldTimeIntervalValue = self.timeInterval
            self.timeIntervalArray = array
            if oldTimeIntervalValue != self.timeInterval {
                switch timeInterval {
                case .Weekly:
                    for day in 0..<self.weeklyArray.count {
                        self.weeklyArray[day].value = false
                    }
                case .Monthly:
                    self.mounthlyIntervalArray.removeAll()
                    for i in 1...31 {
                        let element = ("\(i)", false)
                        self.mounthlyIntervalArray.append(element)
                    }
                default:
                    break
                }
            }
        case .MounthlyInterval:
            self.mounthlyIntervalArray = array
        case .WeeklyInterval:
            self.weeklyArray = array
        case .TimeZone:
            self.timeZoneArray = array
        default:
            return
        }
        
        tableView.reloadData()
        self.typeOfSetting = .none
        self.settingArray.removeAll()
    }
    
    func updateStringValue(string: String?) {
        switch typeOfSetting {
        case .KPIName:
            self.kpiName = string
        case .KPINote:
            self.kpiDescription = string
        default:
            return
        }
        tableView.reloadData()
    }
    func updateDoubleValue(number: Double?) {
    }
    
}

extension ChooseSuggestedKPITableViewController: UpdateTimeDelegate {
    
    func updateTime(newTime time: Date) {
        if datePickerIsVisible {
            deadline = time
            let rowNumber = tableView.numberOfRows(inSection: 0) - 2
            let indexPath = IndexPath(item: rowNumber, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            checkInputValues()
        } else {
            return
        }
    }
}

extension ChooseSuggestedKPITableViewController: UpdateExternalKPICredentialsDelegate {
    func updateCredentials(googleAnalyticsObject: GoogleKPI?, payPalObject: PayPalKPI?, salesForceObject: SalesForceKPI?) {
        googleKPI = googleAnalyticsObject
        payPalKPI = payPalObject
        salesForceKPI = salesForceObject
    }
}
//extension ChooseSuggestedKPITableViewController: UpdateExternalTokensDelegate {
//    func updateTokens(oauthToken: String, oauthRefreshToken: String, oauthTokenExpiresAt: Date?, viewID: String?) {
//        self.oauthToken = oauthToken
//        self.oauthRefreshToken = oauthRefreshToken
//        self.oauthTokenExpiresAt = oauthTokenExpiresAt
//        self.viewID = viewID
//    }
//}

//MARK: - UIPickerViewDataSource and UIPickerViewDelegate methods
extension ChooseSuggestedKPITableViewController: UIPickerViewDataSource,UIPickerViewDelegate {
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch timeInterval {
        case .Daily:
            return 0
        case .Weekly:
            return weeklyArray.count
        case .Monthly:
            return mounthlyIntervalArray.count
        }
    }
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch timeInterval {
        case .Daily:
            return ""
        case .Weekly:
            return weeklyArray[row].SettingName
        case .Monthly:
            return mounthlyIntervalArray[row].SettingName
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            switch timeInterval {
            case .Daily:
                break
            case .Weekly:
               weeklyInterval =  WeeklyInterval(rawValue: weeklyArray[row].SettingName)!
            case .Monthly:
                mounthlyInterval =  Int(mounthlyIntervalArray[row].SettingName)
            }
        let indexPath = IndexPath(item: 7, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

//extension ChooseSuggestedKPITableViewController: UpdatePayPalAPICredentialsDelegate {
//    func updatePayPalCredentials(payPalObject: PayPalKPI) {
//        payPalKPI = payPalObject
//    }
//}
