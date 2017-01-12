//
//  ChooseSuggestedKPITableViewController.swift
//  CoreKPI
//
//  Created by Семен on 27.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

enum WeeklyInterval: String {
    case none = "Select day"
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
}

class ChooseSuggestedKPITableViewController: UITableViewController, updateSettingsDelegate {
    
    var model: ModelCoreKPI!
    var request: Request!
    weak var KPIListVC: KPIsListTableViewController!
    
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
    var saleForceKPIArray: [(SettingName: String, value: Bool)] = [(SalesForceKPIs.RevenueNewLeads.rawValue, false), (SalesForceKPIs.KeyMetrics.rawValue, false), (SalesForceKPIs.ConvertedLeads.rawValue, false), (SalesForceKPIs.OpenOpportunitiesByStage.rawValue, false), (SalesForceKPIs.TopSalesRep.rawValue, false), (SalesForceKPIs.NewLeadsByIndustry.rawValue, false), (SalesForceKPIs.CampaignROI.rawValue, false)]
    var quickBooksKPIs: [QiuckBooksKPIs] = []
    var quickBooksKPIArray: [(SettingName: String, value: Bool)] = [(QiuckBooksKPIs.Test.rawValue, true)]
    var googleAnalyticsKPIs: [GoogleAnalyticsKPIs] = []
    var googleAnalyticsKPIArray: [(SettingName: String, value: Bool)] = [(GoogleAnalyticsKPIs.Test.rawValue, true)]
    var hubspotCRMKPIs: [HubSpotCRMKPIs] = []
    var hubSpotCRMKPIArray: [(SettingName: String, value: Bool)] = [(HubSpotCRMKPIs.Test.rawValue, true)]
    var paypalKPIs: [PayPalKPIs] = []
    var payPalKPIArray: [(SettingName: String, value: Bool)] = [(PayPalKPIs.Test.rawValue, true)]
    var hubspotMarketingKPIs: [HubSpotMarketingKPIs] = []
    var hubSpotMarketingKPIArray: [(SettingName: String, value: Bool)] = [(HubSpotMarketingKPIs.Test.rawValue, true)]
    
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
    var memberlistArray: [Profile] = []
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
        for interval in weeklyArray {
            if interval.value == true {
                return WeeklyInterval(rawValue: interval.SettingName)!
            }
        }
        return WeeklyInterval.none
    }
    var weeklyArray: [(SettingName: String, value: Bool)] = [(WeeklyInterval.Monday.rawValue, false), (WeeklyInterval.Tuesday.rawValue, false), (WeeklyInterval.Wednesday.rawValue, false), (WeeklyInterval.Thursday.rawValue, false), (WeeklyInterval.Friday.rawValue, false), (WeeklyInterval.Saturday.rawValue, false), (WeeklyInterval.Sunday.rawValue, false)]
    
    var mounthlyInterval: Int? {
        for interval in mounthlyIntervalArray {
            if interval.value == true {
                return Int(interval.SettingName)
            }
        }
        return nil
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
    
    var deadline: String? = "10:15AM"
    
    var typeOfSetting = TypeOfSetting.none
    var settingArray: [(SettingName: String, value: Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        request = Request(model: self.model)
        self.getTeamListFromServer()
        
        // not use in app
        // self.getDepartmentsFromServer()
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        let data: [String : Any] = [:]
        
        request.getJson(category: "/kpi/getDepartments", data: data,
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
    
    //MARK: - get member list from server
    
    func getTeamListFromServer() {
        
        let data: [String : Any] = [ : ]
        
        request.getJson(category: "/team/getTeamList", data: data,
                        success: { json in
                            self.parsingTeamListJson(json: json)
        },
                        failure: { (error) in
                            print(error)
        })
    }
    
    func parsingTeamListJson(json: NSDictionary) {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSArray {
                    var teamListIsFull = false
                    var i = 0
                    while teamListIsFull == false {
                        
                        var profile: Profile!
                        
                        var firstName: String!
                        var lastName: String!
                        var mode: Int!
                        var typeOfAccount: TypeOfAccount!
                        var nickname: String?
                        var photo: String?
                        var position: String?
                        var userId: Int!
                        var userName: String!
                        
                        if let userData = dataKey[i] as? NSDictionary {
                            position = userData["position"] as? String
                            mode = userData["mode"] as? Int
                            mode == 0 ? (typeOfAccount = TypeOfAccount.Manager) : (typeOfAccount = TypeOfAccount.Admin)
                            nickname = userData["nickname"] as? String
                            lastName = userData["last_name"] as? String
                            userName = userData["username"] as? String
                            userId = userData["user_id"] as? Int
                            if (userData["photo"] as? String) != "" {
                                photo = userData["photo"] as? String
                            }
                            
                            firstName = userData["first_name"] as? String
                            
                            profile = Profile(userId: userId, userName: userName, firstName: firstName, lastName: lastName, position: position, photo: photo, phone: nil, nickname: nickname, typeOfAccount: typeOfAccount)
                            self.memberlistArray.append(profile)
                            
                            i+=1
                            
                            if dataKey.count == i {
                                teamListIsFull = true
                            }
                        }
                    }
                    self.createExecutantArray()
                } else {
                    print("Json data is broken")
                }
            } else {
                let errorMessage = json["message"] as! String
                print("Json error message: \(errorMessage)")
                //showAlert(errorMessage: errorMessage)
            }
        } else {
            print("Json file is broken!")
        }
    }
    
    //MARK: create executantArray
    
    func createExecutantArray() {
        for profile in self.memberlistArray {
            let executantName = profile.firstName + " " + profile.lastName
            self.executantArray.append((executantName, false))
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
                return 9
            default:
                return 10
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
                    SuggestedCell.headerOfCell.text = "Select suggested KPI"
                    SuggestedCell.descriptionOfCell.text = "(Optional)"
                case 3:
                    SuggestedCell.headerOfCell.text = "KPI Name"
                    SuggestedCell.descriptionOfCell.text = self.kpiName ?? "Add name"
                case 4:
                    let DescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! KPIDescriptionTableViewCell
                    DescriptionCell.headerOfCellLabel.text = "KPI Note"
                    DescriptionCell.descriptionOfCellLabel.text = self.kpiDescription == nil ? "Add note (Optional)" : ""
                    DescriptionCell.kpiInfoTextLabel.text = self.kpiDescription ?? ""
                    DescriptionCell.prepareForReuse()
                    return DescriptionCell
                case 5:
                    SuggestedCell.headerOfCell.text = "Executant"
                    SuggestedCell.descriptionOfCell.text = self.executant ?? "Choose"
                case 6:
                    SuggestedCell.headerOfCell.text = "Time Interval"
                    SuggestedCell.descriptionOfCell.text = timeInterval.rawValue
                case 7:
                    SuggestedCell.headerOfCell.text = "Time Zone"
                    SuggestedCell.descriptionOfCell.text = timeZone ?? "Select"
                case 8:
                    SuggestedCell.headerOfCell.text = "Deadline"
                    SuggestedCell.descriptionOfCell.text = "12:15AM"
                default:
                    break
                }
            default:
                switch indexPath.row {
                case 0:
                    SuggestedCell.headerOfCell.text = "Source"
                    SuggestedCell.descriptionOfCell.text = source.rawValue
                case 1:
                    SuggestedCell.headerOfCell.text = "Department"
                    SuggestedCell.descriptionOfCell.text = department.rawValue
                case 2:
                    SuggestedCell.headerOfCell.text = "KPI Name"
                    SuggestedCell.descriptionOfCell.text = kpiName ?? "Add name"
                case 3:
                    SuggestedCell.headerOfCell.text = "KPI Name"
                    SuggestedCell.descriptionOfCell.text = self.kpiName ?? "Add name"
                case 4:
                    let DescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! KPIDescriptionTableViewCell
                    DescriptionCell.headerOfCellLabel.text = "KPI Note"
                    DescriptionCell.descriptionOfCellLabel.text = self.kpiDescription == nil ? "Add note (Optional)" : ""
                    DescriptionCell.kpiInfoTextLabel.text = self.kpiDescription ?? ""
                    DescriptionCell.prepareForReuse()
                    return DescriptionCell
                case 5:
                    SuggestedCell.headerOfCell.text = "Executant"
                    SuggestedCell.descriptionOfCell.text = self.executant ?? "Choose"
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
                    SuggestedCell.descriptionOfCell.text = timeZone ?? "Select"
                case 9:
                    SuggestedCell.headerOfCell.text = "Deadline"
                    SuggestedCell.descriptionOfCell.text = "12:15AM"
                default:
                    break
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch source {
        case .none:
            self.typeOfSetting = .Source
            self.settingArray = self.sourceArray
            showSelectSettingVC()
        case .User:
            
            switch timeInterval {
            case .Daily:
                switch indexPath.row {
                case 0:
                    self.typeOfSetting = .Source
                    self.settingArray = self.sourceArray
                    showSelectSettingVC()
                case 1:
                    self.typeOfSetting = .Departament
                    self.settingArray = self.departmentArray
                    showSelectSettingVC()
                case 2:
                    if self.department == .none {
                        self.showAlert(title: "Error", message: "First select a department please")
                        tableView.deselectRow(at: indexPath, animated: true)
                    } else {
                        self.typeOfSetting = .SuggestedKPI
                        self.settingArray = self.kpiArray
                        showSelectSettingVC()
                    }
                case 3:
                    self.typeOfSetting = .KPIName
                    self.showSelectSettingVC()
                case 4:
                    self.typeOfSetting = .KPINote
                    self.showSelectSettingVC()
                case 5:
                    self.typeOfSetting = .Executant
                    self.settingArray = self.executantArray
                    showSelectSettingVC()
                case 6:
                    self.typeOfSetting = .TimeInterval
                    self.settingArray = self.timeIntervalArray
                    showSelectSettingVC()
                case 7:
                    self.typeOfSetting = .TimeZone
                    self.settingArray = self.timeZoneArray
                    showSelectSettingVC()
                    //                case 6:
                    //                    SuggestedCell.headerOfCell.text = "Deadline"
                //                    SuggestedCell.descriptionOfCell.text = "12:15AM"
                default:
                    break
                }
            default:
                switch indexPath.row {
                case 0:
                    self.typeOfSetting = .Source
                    self.settingArray = self.sourceArray
                    showSelectSettingVC()
                case 1:
                    self.typeOfSetting = .Departament
                    self.settingArray = self.departmentArray
                    showSelectSettingVC()
                case 2:
                    if self.department == .none {
                        self.showAlert(title: "Error", message: "First select a department please")
                        tableView.deselectRow(at: indexPath, animated: true)
                    } else {
                        self.typeOfSetting = .SuggestedKPI
                        self.settingArray = self.kpiArray
                        showSelectSettingVC()
                    }
                case 3:
                    break
                case 4:
                    break
                case 5:
                    self.typeOfSetting = .Executant
                    self.settingArray = self.executantArray
                    showSelectSettingVC()
                case 6:
                    self.typeOfSetting = .TimeInterval
                    self.settingArray = self.timeIntervalArray
                    showSelectSettingVC()
                case 7:
                    switch self.timeInterval {
                    case .Weekly:
                        self.typeOfSetting = .WeeklyInterval
                        self.settingArray = self.weeklyArray
                        showSelectSettingVC()
                    case .Monthly:
                        self.typeOfSetting = .MounthlyInterval
                        self.settingArray = self.mounthlyIntervalArray
                        showSelectSettingVC()
                    default:
                        break
                    }
                case 8:
                    self.typeOfSetting = .TimeZone
                    self.settingArray = self.timeZoneArray
                    showSelectSettingVC()
                default:
                    break
                }
            }
        case .Integrated:
            switch indexPath.row {
            case 0:
                self.typeOfSetting = .Source
                self.settingArray = self.sourceArray
                showSelectSettingVC()
            case 1:
                self.typeOfSetting = .Service
                self.showIntegratedServicesVC()
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
    
    //MARK: - Save KPI
    @IBAction func tapSaveButton(_ sender: UIBarButtonItem) {
        
        var kpi: KPI!
        
        switch source {
        case .Integrated:
            
            if source == .none || (source == .Integrated && integrated == .none) {
                self.showAlert(title: "Error", message: "One ore more parameters are not selected")
                return
            }
            
            let integratedKPI = IntegratedKPI(service: self.integrated, saleForceKPIs: saleForceKPIs, quickBookKPIs: quickBooksKPIs, googleAnalytics: googleAnalyticsKPIs, hubSpotCRMKPIs: hubspotCRMKPIs, payPalKPIs: paypalKPIs, hubSpotMarketingKPIs: hubspotMarketingKPIs)
            kpi = KPI(typeOfKPI: .IntegratedKPI, integratedKPI: integratedKPI, createdKPI: nil, imageBacgroundColour: UIColor.clear)
        case .User:
            if self.department == .none || self.kpiName == nil || self.executant == nil || (self.timeInterval != TimeInterval.Daily && (self.weeklyInterval == WeeklyInterval.none || self.mounthlyInterval == nil)) || self.timeZone == nil || self.deadline == nil {
                showAlert(title: "Error", message: "One ore more parameters are not selected")
                return
            }
            
            var executantProfile: Profile!
            
            for profile in memberlistArray {
                if self.executant?.components(separatedBy: " ")[0] == profile.firstName && self.executant?.components(separatedBy: " ")[1] == profile.lastName {
                    executantProfile = profile
                }
            }
            let userKPI = CreatedKPI(source: .User, department: self.department, KPI: self.kpiName!, descriptionOfKPI: self.kpiDescription, executant: executantProfile, timeInterval: self.timeInterval, timeZone: self.timeZone!, deadline: self.deadline!, number: [])
            kpi = KPI(typeOfKPI: .createdKPI, integratedKPI: nil, createdKPI: userKPI, imageBacgroundColour: UIColor.clear)
            
        default:
            self.showAlert(title: "Error", message: "Select a Sourse please")
            return
        }
        
        self.delegate = self.KPIListVC
        delegate.addNewKPI(kpi: kpi)
        
        let KPIListVC = self.navigationController?.viewControllers[0] as! KPIsListTableViewController
        _ = self.navigationController?.popToViewController(KPIListVC, animated: true)
    }
    
    //MARK: - Show KPISelectSettingTableViewController method
    func showSelectSettingVC() {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "SelectSettingForKPI") as! KPISelectSettingTableViewController
        destinatioVC.ChoseSuggestedVC = self
        destinatioVC.selectSetting = settingArray
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
        navigationController?.pushViewController(destinatioVC, animated: true)
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
    
    //MARK: - updateSettingArrayDelegate methods
    func updateSettingsArray(array: [(SettingName: String, value: Bool)]) {
        switch typeOfSetting {
        case .Source:
            self.sourceArray = array
            for source in array {
                if source.value == true {
                    self.source = Source(rawValue: source.SettingName)!
                }
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
