//
//  ChooseSuggestedKPITableViewController.swift
//  CoreKPI
//
//  Created by Семен on 27.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import QuartzCore

enum WeeklyInterval: String
{
    case none = ""
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
}

class ChooseSuggestedKPITableViewController: UITableViewController
{
    var model: ModelCoreKPI!
    var kpi: KPI!
    
    weak var KPIListVC: KPIsListTableViewController!
    let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var animator: TransitionAnimator = {
        return TransitionAnimator()
    }()
    
    enum TypeOfSetting: String
    {
        case none
        case Source
        case Colour
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
        case firstChart = "Visualization 1"
        case secondChart = "Visualization 2"
        case Deadline
    }
    
    var delegate: updateKPIListDelegate!
    var center = CGPoint.zero
    var source = Source.none
    var sourceArray: [(SettingName: String, value: Bool)] = [
        (Source.User.rawValue, false),
        (Source.Integrated.rawValue, false)]
    var isColorSet = false
    
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
    var firstChartType: TypeOfKPIView?
    var secondChartType: TypeOfKPIView?
    
    var firstChartName = "" {
        didSet {
            
            if firstChartName == "Table" { firstChartType = .Numbers }
            else if firstChartName == "" { firstChartType = nil }
            else                         { firstChartType = .Graph }
        }
    }
    
    var secondChartName = "" {
        didSet {
            if secondChartName == "Table" { secondChartType = .Numbers }
            else if secondChartName == "" { secondChartType = nil }
            else                          { secondChartType = .Graph }
        }
    }
    
    var executant: String? {
        for member in executantArray
        {
            if member.value == true {
                return member.SettingName
            }
        }
        return nil
    }
    
    var executantArray:  [(SettingName: String, value: Bool)] = []
    
    var timeInterval: AlertTimeInterval {
        for interval in timeIntervalArray {
            if interval.value == true {
                return AlertTimeInterval(rawValue: interval.SettingName)!
            }
        }
        return AlertTimeInterval.Daily
    }
    
    var timeIntervalArray: [(SettingName: String, value: Bool)] = [(AlertTimeInterval.Daily.rawValue, true), (AlertTimeInterval.Weekly.rawValue, false), (AlertTimeInterval.Monthly.rawValue, false)]
    
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
    
    var colourArray: [(SettingName: String, value: Bool)] = [
        (Colour.Pink.rawValue,  false),
        (Colour.Green.rawValue, false),
        (Colour.Blue.rawValue,  true)]
    
    var colour: Colour {
        get {
            for colour in colourArray {
                if colour.value == true {
                    return Colour(rawValue: colour.SettingName)!
                }
            }
            return Colour.none
        }
        
        set {
            var newColourArray: [(SettingName: String, value: Bool)] = []
            for colour in colourArray {
                if colour.SettingName == newValue.rawValue {
                    newColourArray.append((colour.SettingName, true))
                } else {
                    newColourArray.append((colour.SettingName, false))
                }
            }
            colourArray.removeAll()
            colourArray = newColourArray
        }
    }
    
    var colourDictionary: [Colour : UIColor] = [
        Colour.Pink : UIColor(red: 251/255, green: 233/255, blue: 231/255, alpha: 1),
        Colour.Green : UIColor(red: 200/255, green: 247/255, blue: 197/255, alpha: 1),
        Colour.Blue : UIColor(red: 227/255, green: 242/255, blue: 253/255, alpha: 1)
    ]
    
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
    
    var typeOfVisualizationArray: [(SettingName: String, value: Bool)] = [
        ("Table", false),
        (TypeOfChart.PieChart.rawValue, false),
        (TypeOfChart.PointChart.rawValue, false),
        (TypeOfChart.LineChart.rawValue, false)
        ]
    
    var deadline: Date?
    
    var typeOfSetting = TypeOfSetting.none
    var settingArray: [(SettingName: String, value: Bool)] = []
    
    var datePickerIsVisible = false
    var dataPickerIsVisible = false
       
    @objc private func tappedCancelButton() {
        
        prepareAlertController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = nil        
        center = view.center
        
        createExecutantArray()
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkInputValues()
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
    
    private func prepareAlertController() {
        
        let alertController = UIAlertController(title: "Do you want to cancel?",
                                                message: "All entered data will be lost",
                                                preferredStyle: .actionSheet)
        
        let yesAction = UIAlertAction(title: "Yes, I'am sure",
                                      style: .default) { _ in
                                        self.ui(block: false)
                                        self.removeAllAlamofireNetworking()
                                        self.navigationController?.popViewController(animated: true)
        }
        
        let noAction = UIAlertAction(title: "No, I change my mind",
                                     style: .cancel) { _ in
                                        self.dismiss(animated: true,
                                                     completion: nil)
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - updateKPIArray method
    func updateKPIArray() {
        
        self.kpiArray.removeAll()
        let buildInKPI = BuildInKPI(department: self.department)
        var dictionary: [String:String] = [:]
        
        switch department
        {
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
                            self.showAlert(title: "Sorry!", errorMessage: error)
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
                showAlert(title: "Error geting list if departments", errorMessage: errorMessage)
            }
        } else {
            print("Json file is broken!")
        }
    }
    
    //MARK: create executantArray
    func createExecutantArray() {
        
        for profile in model.team {
            if let executantName = profile.firstName, let executantLastName = profile.lastName
            {
                self.executantArray.append(("\(executantName) \(executantLastName)", false))
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch source
        {
        case .none:
            return 2
            
        case .User:            
            switch timeInterval
            {
            case .Daily:
                return datePickerIsVisible ? 13 : 12
                
            case .Weekly, .Monthly:
                var cells = 13
                
                if dataPickerIsVisible { cells += 1 }
                if datePickerIsVisible { cells += 1 }
                
                return cells
                
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
        let colourCell = tableView.dequeueReusableCell(withIdentifier: "SelectColourCell", for: indexPath) as! KPIColourTableViewCell
       // colourCell.colourView.isHidden = !isColorSet
        
        colourCell.layoutIfNeeded()
        colourCell.layoutSubviews()
        colourCell.headerOfCell.text = "Colour"
        colourCell.descriptionOfCell.text = colour.rawValue
        for color in colourDictionary {
            if color.key == colour {
                colourCell.colourView.backgroundColor = color.value
                colourCell.prepareForReuse()
            }
        }
        
        switch source {
        case .none:
            title = "Source"
            
            SuggestedCell.descriptionOfCell.text = source.rawValue
            SuggestedCell.accessoryType = .none
            
            if indexPath.row == 0
            {
                SuggestedCell.headerOfCell.text = "User"
            }
            else
            {
                SuggestedCell.headerOfCell.text = "Integrated"
            }
            
        case .User:
            title = ""
            
            let selector = #selector(self.tappedCancelButton)
            let cancelB  = UIBarButtonItem(barButtonSystemItem: .cancel,
                                           target: self,
                                           action: selector)
            
            navigationItem.setHidesBackButton(true, animated: false)
            navigationItem.setLeftBarButton(cancelB, animated: false)
            SuggestedCell.accessoryType = .disclosureIndicator
            SuggestedCell.trailingToRightConstraint.constant = 0
            
            switch timeInterval
            {
            case .Daily:
                switch indexPath.row
                {
                case 0:
                    return colourCell
                    
                case 1:
                    SuggestedCell.headerOfCell.text = "Source"
                    SuggestedCell.descriptionOfCell.text = source.rawValue
                case 2:
                    SuggestedCell.headerOfCell.text = "Department"
                    SuggestedCell.descriptionOfCell.text = department.rawValue
                case 3:
                    SuggestedCell.headerOfCell.text = "Suggested KPI"
                    SuggestedCell.descriptionOfCell.text = self.kpiName ?? "(Optional)"
                case 4:
                    SuggestedCell.headerOfCell.text = "KPI Name"
                    SuggestedCell.descriptionOfCell.text = self.kpiName ?? ""
                case 5:
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
                case 6:
                    SuggestedCell.headerOfCell.text = "Executant"
                    SuggestedCell.descriptionOfCell.text = self.executant ?? ""
                case 7:
                    SuggestedCell.headerOfCell.text = "Time Interval"
                    SuggestedCell.descriptionOfCell.text = timeInterval.rawValue
                case 8:
                    SuggestedCell.headerOfCell.text = "Time Zone"
                    SuggestedCell.descriptionOfCell.text = timeZone ?? ""
                    
                case 9:
                    SuggestedCell.headerOfCell.text = "KPI's 1 st view"
                    SuggestedCell.descriptionOfCell.text = firstChartName
                    
                case 10:
                    SuggestedCell.headerOfCell.text = "KPI's 2 st view"
                    SuggestedCell.descriptionOfCell.text = secondChartName
                    
                case 11:
                    SuggestedCell.headerOfCell.text = "Deadline"
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .short
                    if deadline == nil {
                        SuggestedCell.descriptionOfCell.text = ""
                    } else {
                        SuggestedCell.descriptionOfCell.text = dateFormatter.string(for: deadline)
                    }
                    
                case 12:
                    let datePickerCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath)  as! DatePickerTableViewCell
                    datePickerCell.datePicker.setDate(deadline ?? Date(), animated: true)
                    datePickerCell.addKPIVC = self
                    return datePickerCell
                default:
                    break
                }
                
            case .Weekly, .Monthly:
                
                if dataPickerIsVisible
                {
                    switch indexPath.row
                    {
                    case 0:
                        return colourCell
                        
                    case 1:
                        SuggestedCell.headerOfCell.text = "Source"
                        SuggestedCell.descriptionOfCell.text = source.rawValue
                    case 2:
                        SuggestedCell.headerOfCell.text = "Department"
                        SuggestedCell.descriptionOfCell.text = department.rawValue
                    case 3:
                        SuggestedCell.headerOfCell.text = "Suggested KPI"
                        SuggestedCell.descriptionOfCell.text = "(Optional)"
                    case 4:
                        SuggestedCell.headerOfCell.text = "KPI Name"
                        SuggestedCell.descriptionOfCell.text = self.kpiName ?? ""
                    case 5:
                        let DescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! KPIDescriptionTableViewCell
                        DescriptionCell.headerOfCellLabel.text = "KPI Note"
                        DescriptionCell.descriptionOfCellLabel.text = self.kpiDescription == nil ? "Add note (Optional)" : ""
                        DescriptionCell.kpiInfoTextLabel.text = self.kpiDescription ?? ""
                        DescriptionCell.prepareForReuse()
                        return DescriptionCell
                    case 6:
                        SuggestedCell.headerOfCell.text = "Executant"
                        SuggestedCell.descriptionOfCell.text = self.executant ?? ""
                    case 7:
                        SuggestedCell.headerOfCell.text = "Time Interval"
                        SuggestedCell.descriptionOfCell.text = timeInterval.rawValue
                    case 8:
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
                        
                    case 9:
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
                    case 10:
                        SuggestedCell.headerOfCell.text = "Time Zone"
                        SuggestedCell.descriptionOfCell.text = timeZone ?? ""
                        
                    case 11:
                        SuggestedCell.headerOfCell.text = "KPI's 1 st view"
                        SuggestedCell.descriptionOfCell.text = firstChartName
                        
                    case 12:
                        SuggestedCell.headerOfCell.text = "KPI's 2 st view"
                        SuggestedCell.descriptionOfCell.text = secondChartName
                        
                    case 13:
                        SuggestedCell.headerOfCell.text = "Deadline"
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeStyle = .short
                        if deadline == nil {
                            SuggestedCell.descriptionOfCell.text = ""
                        } else {
                            SuggestedCell.descriptionOfCell.text = dateFormatter.string(for: deadline)
                        }
                        
                    case 14:
                        let datePickerCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerTableViewCell
                        datePickerCell.addKPIVC = self
                        return datePickerCell
                    default:
                        break
                    }
                } else {
                    switch indexPath.row
                    {
                    case 0:
                        return colourCell
                        
                    case 1:
                        SuggestedCell.headerOfCell.text = "Source"
                        SuggestedCell.descriptionOfCell.text = source.rawValue
                        
                    case 2:
                        SuggestedCell.headerOfCell.text = "Department"
                        SuggestedCell.descriptionOfCell.text = department.rawValue
                        
                    case 3:
                        SuggestedCell.headerOfCell.text = "Suggested KPI"
                        SuggestedCell.descriptionOfCell.text = "(Optional)"
                        
                    case 4:
                        SuggestedCell.headerOfCell.text = "KPI Name"
                        SuggestedCell.descriptionOfCell.text = self.kpiName ?? ""
                        
                    case 5:
                        let DescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! KPIDescriptionTableViewCell
                        DescriptionCell.headerOfCellLabel.text = "KPI Note"
                        DescriptionCell.descriptionOfCellLabel.text = self.kpiDescription == nil ? "Add note (Optional)" : ""
                        DescriptionCell.kpiInfoTextLabel.text = self.kpiDescription ?? ""
                        DescriptionCell.prepareForReuse()
                        return DescriptionCell
                        
                    case 6:
                        SuggestedCell.headerOfCell.text = "Executant"
                        SuggestedCell.descriptionOfCell.text = self.executant ?? ""
                        
                    case 7:
                        SuggestedCell.headerOfCell.text = "Time Interval"
                        SuggestedCell.descriptionOfCell.text = timeInterval.rawValue
                        
                    case 8:
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
                        
                    case 9:
                        SuggestedCell.headerOfCell.text = "Time Zone"
                        SuggestedCell.descriptionOfCell.text = timeZone ?? ""
                        
                    case 10:
                        SuggestedCell.headerOfCell.text = "KPI's 1 st view"
                        SuggestedCell.descriptionOfCell.text = firstChartName
                        
                    case 11:
                        SuggestedCell.headerOfCell.text = "KPI's 2 st view"
                        SuggestedCell.descriptionOfCell.text = secondChartName
                        
                    case 12:
                        SuggestedCell.headerOfCell.text = "Deadline"
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeStyle = .short
                        if deadline == nil {
                            SuggestedCell.descriptionOfCell.text = ""
                        } else {
                            SuggestedCell.descriptionOfCell.text = dateFormatter.string(for: deadline)
                        }
                        
                    case 13:
                        let datePickerCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerTableViewCell
                        datePickerCell.addKPIVC = self
                        return datePickerCell
                    default:
                        break
                    }
                }
            }
            
        case .Integrated:
            navigationItem.leftBarButtonItem = nil
            navigationItem.setHidesBackButton(false, animated: false)
            
            switch indexPath.row {
            case 0:
                SuggestedCell.headerOfCell.text = "Source"
                SuggestedCell.descriptionOfCell.text = source.rawValue
                SuggestedCell.accessoryType = .disclosureIndicator
                
            case 1:
                SuggestedCell.headerOfCell.text = "Service"
                SuggestedCell.descriptionOfCell.text = integrated.rawValue
                SuggestedCell.accessoryType = .disclosureIndicator
                
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
        
        switch source
        {
        case .none:
            break
            
        case .User:
            var newIndexPath = IndexPath()
            
            switch timeInterval
            {
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
    
    private func animateTableViewRealoadData() {
        
        let transition = CATransition()
        let funcName   = kCAMediaTimingFunctionEaseInEaseOut
        let timingFunc = CAMediaTimingFunction(name: funcName)
        
        transition.type = kCATransitionPush
        transition.timingFunction = timingFunc
        transition.fillMode = kCAFillModeForwards
        transition.duration = 0.4
        transition.subtype  = kCATransitionFromRight
        
        tableView.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch source
        {
        case .none:
            animateTableViewRealoadData()
            
            source = indexPath.row == 0 ? .User : .Integrated
            tableView.reloadData()
            tableView.isUserInteractionEnabled = true
            tableView.isScrollEnabled = true
            
        case .User:
            switch timeInterval
            {
            case .Daily:
                switch indexPath.row
                {
                case 0:
                    typeOfSetting = .Colour
                    settingArray = colourArray
                    showSelectSettingVC()
                    
                case 1:
                    typeOfSetting = .Source
                    settingArray = sourceArray                
                    showSelectSettingVC()
                    
                case 2:
                    typeOfSetting = .Departament
                    settingArray = departmentArray
                    showSelectSettingVC()
                    
                case 3:
                    if department == .none {
                        showAlert(title: "Error", errorMessage: "First select a department please")
                        tableView.deselectRow(at: indexPath, animated: true)
                    } else {
                        typeOfSetting = .SuggestedKPI
                        settingArray = kpiArray
                        showSelectSettingVC()
                    }
                    
                case 4:
                    typeOfSetting = .KPIName
                    showSelectSettingVC()
                    
                case 5:
                    typeOfSetting = .KPINote
                    showSelectSettingVC()
                    
                case 6:
                    typeOfSetting = .Executant
                    settingArray = executantArray
                    showSelectSettingVC()
                    
                case 7:
                    typeOfSetting = .TimeInterval
                    settingArray = timeIntervalArray
                    showSelectSettingVC()
                    
                case 8:
                    typeOfSetting = .TimeZone
                    settingArray = timeZoneArray
                    showSelectSettingVC()
                    
                case 9:
                    typeOfSetting = .firstChart
                    settingArray = typeOfVisualizationArray
                    showSelectSettingVC()

                case 10:
                    typeOfSetting = .secondChart
                    settingArray = typeOfVisualizationArray
                    showSelectSettingVC()
                    
                case 11:
                    showDatePicker(row: indexPath.row)
                    
                default:
                    break
                }
                tableView.deselectRow(at: indexPath, animated: true)
                
            case .Weekly, .Monthly:
                if dataPickerIsVisible
                {
                    switch indexPath.row
                    {
                    case 0:
                        typeOfSetting = .Colour
                        settingArray = colourArray
                        showSelectSettingVC()
                        
                    case 1:
                        typeOfSetting = .Source
                        settingArray = sourceArray
                        showSelectSettingVC()
                    case 2:
                        typeOfSetting = .Departament
                        settingArray = departmentArray
                        showSelectSettingVC()
                    case 3:
                        if department == .none {
                            showAlert(title: "Error", errorMessage: "First select a department please")
                            tableView.deselectRow(at: indexPath, animated: true)
                        } else {
                            typeOfSetting = .SuggestedKPI
                            settingArray = kpiArray
                            showSelectSettingVC()
                        }
                    case 4:
                        typeOfSetting = .KPIName
                        showSelectSettingVC()
                    case 5:
                        typeOfSetting = .KPINote
                        showSelectSettingVC()
                    case 6:
                        typeOfSetting = .Executant
                        settingArray = executantArray
                        showSelectSettingVC()
                    case 7:
                        typeOfSetting = .TimeInterval
                        settingArray = timeIntervalArray
                        showSelectSettingVC()
                    case 8:
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
                        typeOfSetting = .firstChart
                        settingArray = typeOfVisualizationArray
                        showSelectSettingVC()
                        
                    case 11:
                        typeOfSetting = .secondChart
                        settingArray = typeOfVisualizationArray
                        showSelectSettingVC()

                    case 12:
                        showDatePicker(row: indexPath.row)
                        tableView.deselectRow(at: indexPath, animated: true)
                        
                    default:
                        break
                    }
                } else {
                    switch indexPath.row {
                    case 0:
                        typeOfSetting = .Colour
                        settingArray = colourArray
                        showSelectSettingVC()
                        
                    case 1:
                        typeOfSetting = .Source
                        settingArray = sourceArray
                        showSelectSettingVC()
                        
                    case 2:
                        typeOfSetting = .Departament
                        settingArray = departmentArray
                        showSelectSettingVC()
                        
                    case 3:
                        if department == .none {
                            showAlert(title: "Error", errorMessage: "First select a department please")
                            tableView.deselectRow(at: indexPath, animated: true)
                        } else {
                            typeOfSetting = .SuggestedKPI
                            settingArray = kpiArray
                            showSelectSettingVC()
                        }
                        
                    case 4:
                        typeOfSetting = .KPIName
                        showSelectSettingVC()
                        
                    case 5:
                        typeOfSetting = .KPINote
                        showSelectSettingVC()
                        
                    case 6:
                        typeOfSetting = .Executant
                        settingArray = executantArray
                        showSelectSettingVC()
                        
                    case 7:
                        typeOfSetting = .TimeInterval
                        settingArray = timeIntervalArray
                        showSelectSettingVC()
                        
                    case 8:
                        tableView.deselectRow(at: indexPath, animated: true)
                        dataPickerIsVisible = true
                        let index = IndexPath(item: 9, section: 0)
                        tableView.insertRows(at: [index], with: .fade)
                        tableView.scrollToRow(at: index, at: .bottom, animated: true)
                        
                    case 9:
                        typeOfSetting = .TimeZone
                        settingArray = timeZoneArray
                        showSelectSettingVC()
                        
                    case 10:
                        typeOfSetting = .firstChart
                        settingArray = typeOfVisualizationArray
                        showSelectSettingVC()
                        
                    case 11:
                        typeOfSetting = .secondChart
                        settingArray = typeOfVisualizationArray
                        showSelectSettingVC()

                    case 12:
                        showDatePicker(row: indexPath.row)
                        tableView.deselectRow(at: indexPath, animated: true)
                        
                    default:
                        break
                    }
                }
            }
        case .Integrated:
            createExternalServicesArrays()
            
            switch indexPath.row
            {
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
    
    private func ui(block: Bool) {
      
        if block
        {
            center = navigationController!.view.center
            addWaitingSpinner(at: center, color: OurColors.cyan)
        }
        else     { removeWaitingSpinner() }
        tableView.isUserInteractionEnabled = !block
        navigationItem.rightBarButtonItem?.isEnabled = !block
    }
    
    func dataIsEntered() -> Bool {
        switch source {
        case .Integrated:
            if source == .none || (source == .Integrated && integrated == .none) {
                return false
            }
        case .User:
            if department == .none ||
                kpiName == nil ||
                executant == nil ||
                (timeInterval == AlertTimeInterval.Weekly && weeklyInterval == WeeklyInterval.none) ||
                (timeInterval == AlertTimeInterval.Monthly && mounthlyInterval == nil) ||
                timeZone == nil ||
                deadline == nil ||
                firstChartName == "" ||
                secondChartName == "" {
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
                    externalKPI.userID = Int64(model.profile.userId)
                    
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
            
            ui(block: true)
            
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
            
            let userKPI = CreatedKPI(source: .User,
                                     department: department,
                                     KPI: kpiName!,
                                     descriptionOfKPI: kpiDescription,
                                     executant: executantProfile,
                                     timeInterval: timeInterval,
                                     deadlineDay: deadlineDay,
                                     timeZone: timeZone!,
                                     deadlineTime: deadline!,
                                     number: [])
            
            var imageBacgroundColour: UIColor = .clear
            
            colourArray.forEach { color in
                guard color.value == true, let color = Colour(rawValue: color.SettingName),
                    let exactColor = colourDictionary[color]  else { return }
                
                imageBacgroundColour = exactColor
            }

            kpi = KPI(kpiID: 0,
                      typeOfKPI: .createdKPI,
                      integratedKPI: nil,
                      createdKPI: userKPI,
                      imageBacgroundColour: imageBacgroundColour)
            
            kpi.KPIViewOne  = firstChartType!
            kpi.KPIViewTwo  = secondChartType!
            kpi.KPIChartOne = firstChartName != "Table" ?
                TypeOfChart(rawValue: firstChartName)! : nil
            
            kpi.KPIChartTwo = secondChartName != "Table" ?
                TypeOfChart(rawValue: secondChartName)! : nil
            
            let request = AddKPI(model: model)
            
            request.addKPI(kpi: kpi, success: { id in
                kpi.id = id
                self.delegate = self.KPIListVC
                self.delegate.addNewKPI(kpi: kpi)
                self.ui(block: false)
                let kpiListVC = self.navigationController?.viewControllers[0] as! KPIsListTableViewController
                kpiListVC.loadKPIsFromServer()
                _ = self.navigationController?.popToViewController(kpiListVC, animated: true)
            }, failure: { error in
                self.ui(block: false)
                self.showAlert(title: "Error occured", errorMessage: error)
            })
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
        
        switch typeOfSetting
        {
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
            
        case .Source:
            destinatioVC.title = "Source"
            
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
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: .integratedServicesVC) as! SelectIntegratedServicesViewController
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
typealias semenSettingsTuple = (SettingName: String, value: Bool)
//MARK: - updateSettingArrayDelegate methods
extension ChooseSuggestedKPITableViewController: updateSettingsDelegate
{
    
    private func checkArrayContainsValues(_ array: [semenSettingsTuple]) ->
                                                          semenSettingsTuple? {
        
        let filteredArray = array.filter { $0.value == true }
        guard filteredArray.count > 0 else { return nil  }
        
        return filteredArray[0]
    }
    
    func updateSettingsArray(array: [semenSettingsTuple]) {
        
        switch typeOfSetting
        {
        case .Colour:
            colourArray = array
            if (array.filter { $0.value == true }).count > 0
            {
                isColorSet = true
            }
            
        case .firstChart:
            guard let visualization = checkArrayContainsValues(array) else {
                firstChartName = ""; return
            }
            
            let chartName = visualization.SettingName
            
            if chartName != secondChartName
            {
                if chartName != "Table"
                {
                    firstChartName = chartName
                }
                else { firstChartName = "Table" }
            }
            else
            {
                firstChartName = chartName
                secondChartName = ""
            }
            
        case .secondChart:
            guard let visualization = checkArrayContainsValues(array) else {
                secondChartName = "Table"; return
            }
            let chartName = visualization.SettingName
            
            if chartName != firstChartName
            {
                if chartName != "Table"
                {
                    secondChartName = chartName
                }
                else { secondChartName = "Table" }
            }
            else
            {
                firstChartName = chartName
                secondChartName = ""
            }
            
        case .Source:
            self.sourceArray = array
            for source in array {
                if source.value == true {
                    self.source = Source(rawValue: source.SettingName)!
                }
            }
            if source == .User {
                self.tableView.isScrollEnabled = true
                title = ""
                
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
        //self.typeOfSetting = .none
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
    
    func updateDoubleValue(number: Double?) { }
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
