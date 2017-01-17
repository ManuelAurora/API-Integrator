//
//  ReportAndViewKPITableViewController.swift
//  CoreKPI
//
//  Created by Семен Осипов on 08.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

enum ButtonDidTaped: String {
    case Report
    case Edit
}

enum Colour: String {
    case none = "Select colour"
    case Pink
    case Green
    case Blue
}

enum TypeOfKPIView: String {
    case Graph
    case Numbers
}



class ReportAndViewKPITableViewController: UITableViewController, updateSettingsDelegate {
    
    var model: ModelCoreKPI!
    var request: Request!
    weak var KPIListVC: KPIsListTableViewController!
    var delegate: updateKPIListDelegate!
    
    var kpiIndex: Int!
    var kpiArray: [KPI] = []
    var buttonDidTaped = ButtonDidTaped.Report
    
    //MARK: - Report property
    var report: Double?
    
    //MARK: - Edit property
    var typeOfAccount: TypeOfAccount {
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
            return TypeOfAccount.Admin
        } else {
            return TypeOfAccount.Manager
        }
    }
    //colour
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
    var colourArray: [(SettingName: String, value: Bool)] = [(Colour.Pink.rawValue, false), (Colour.Green.rawValue, false), (Colour.Blue.rawValue, false)]
    var colourDictionary: [Colour : UIColor] = [
        Colour.Pink : UIColor(red: 251/255, green: 233/255, blue: 231/255, alpha: 1),
        Colour.Green : UIColor(red: 200/255, green: 247/255, blue: 197/255, alpha: 1),
        Colour.Blue : UIColor(red: 227/255, green: 242/255, blue: 253/255, alpha: 1)
    ]
    //department
    var department: Departments? {
        get {
            for department in departmentArray {
                if department.value == true {
                    return Departments(rawValue: department.SettingName)!
                }
            }
            return Departments.none
        }
        set {
            var newDepartmentArray: [(SettingName: String, value: Bool)] = []
            for department in departmentArray {
                if department.SettingName == newValue?.rawValue {
                    newDepartmentArray.append((department.SettingName, true))
                } else {
                    newDepartmentArray.append((department.SettingName, false))
                }
            }
            departmentArray.removeAll()
            departmentArray = newDepartmentArray
        }
        
    }
    var departmentArray: [(SettingName: String, value: Bool)] = [(Departments.Sales.rawValue, false), (Departments.Procurement.rawValue, false), (Departments.Projects.rawValue, false), (Departments.FinancialManagement.rawValue, false), (Departments.Staff.rawValue, false)]
    //KPI name
    var kpiName: String = ""
    var kpiNameArray: [(SettingName: String, value: Bool)] = []
    //KPI description
    var kpiDescription: String?
    //Executant
    var executant: String? {
        get {
            for member in executantArray {
                if member.value == true {
                    return member.SettingName
                }
            }
            return nil
        }
        set {
            var newExecutantArray: [(SettingName: String, value: Bool)] = []
            for executant in executantArray {
                if executant.SettingName == newValue {
                    newExecutantArray.append((executant.SettingName, true))
                } else {
                    newExecutantArray.append((executant.SettingName, false))
                }
            }
            executantArray.removeAll()
            executantArray = newExecutantArray
        }
    }
    var memberlistArray: [Profile] = []
    var executantArray:  [(SettingName: String, value: Bool)] = []
    //TimeInterval
    var timeInterval: TimeInterval {
        get {
            for interval in timeIntervalArray {
                if interval.value == true {
                    return TimeInterval(rawValue: interval.SettingName)!
                }
            }
            return TimeInterval.Daily
        }
        set {
            var newTimeIntervalArray: [(SettingName: String, value: Bool)] = []
            for timeInterval in timeIntervalArray {
                if timeInterval.SettingName == newValue.rawValue {
                    newTimeIntervalArray.append((timeInterval.SettingName, true))
                } else {
                    newTimeIntervalArray.append((timeInterval.SettingName, false))
                }
            }
            timeIntervalArray.removeAll()
            timeIntervalArray = newTimeIntervalArray
        }
        
    }
    var timeIntervalArray: [(SettingName: String, value: Bool)] = [(TimeInterval.Daily.rawValue, true), (TimeInterval.Weekly.rawValue, false), (TimeInterval.Monthly.rawValue, false)]
    //WeeklyInterval
    var weeklyInterval: WeeklyInterval? {
        get {
            for interval in weeklyArray {
                if interval.value == true {
                    return WeeklyInterval(rawValue: interval.SettingName)!
                }
            }
            return WeeklyInterval.none
        }
        set {
            var newWeeklyIntervalArray: [(SettingName: String, value: Bool)] = []
            for timeInterval in weeklyArray {
                if timeInterval.SettingName == newValue?.rawValue {
                    newWeeklyIntervalArray.append((timeInterval.SettingName, true))
                } else {
                    newWeeklyIntervalArray.append((timeInterval.SettingName, false))
                }
            }
            weeklyArray.removeAll()
            weeklyArray = newWeeklyIntervalArray
        }
        
    }
    var weeklyArray: [(SettingName: String, value: Bool)] = [(WeeklyInterval.Monday.rawValue, false), (WeeklyInterval.Tuesday.rawValue, false), (WeeklyInterval.Wednesday.rawValue, false), (WeeklyInterval.Thursday.rawValue, false), (WeeklyInterval.Friday.rawValue, false), (WeeklyInterval.Saturday.rawValue, false), (WeeklyInterval.Sunday.rawValue, false)]
    //MountlyInterval
    var mounthlyInterval: Int? {
        get {
            for interval in mounthlyIntervalArray {
                if interval.value == true {
                    return Int(interval.SettingName)!
                }
            }
            return nil
        }
        set {
            var newMountlyIntervalArray: [(SettingName: String, value: Bool)] = []
            for timeInterval in mounthlyIntervalArray {
                if timeInterval.SettingName == "\(newValue)" {
                    newMountlyIntervalArray.append((timeInterval.SettingName, true))
                } else {
                    newMountlyIntervalArray.append((timeInterval.SettingName, false))
                }
            }
            mounthlyIntervalArray.removeAll()
            mounthlyIntervalArray = newMountlyIntervalArray
        }
        
    }
    var mounthlyIntervalArray: [(SettingName: String, value: Bool)] = []
    //TimeZone
    var timeZone: String {
        get {
            for timezone in timeZoneArray {
                if timezone.value == true {
                    return timezone.SettingName
                }
            }
            return "nil"
        }
        set {
            var newTimeZoneArray: [(SettingName: String, value: Bool)] = []
            for timeZone in timeZoneArray {
                if timeZone.SettingName == newValue {
                    newTimeZoneArray.append((timeZone.SettingName, true))
                } else {
                    newTimeZoneArray.append((timeZone.SettingName, false))
                }
            }
            timeZoneArray.removeAll()
            timeZoneArray = newTimeZoneArray
        }
    }
    var timeZoneArray: [(SettingName: String, value: Bool)] = [("Hawaii Time (HST)",false), ("Alaska Time (AKST)", false), ("Pacific Time (PST)",false), ("Mountain Time (MST)", false), ("Central Time (CST)", false), ("Eastern Time (EST)",false)]
    //Deadline
    var deadline: String = "10:15AM"
    //KPIOneView
    var KPIOneView: TypeOfKPIView {
        get {
            for type in KPIOneViewArray {
                if type.value == true {
                    return TypeOfKPIView(rawValue: type.SettingName)!
                }
            }
            return TypeOfKPIView.Numbers
        }
        set {
            var newKPIOneViewArray: [(SettingName: String, value: Bool)] = []
            for view in KPIOneViewArray {
                if view.SettingName == newValue.rawValue {
                    newKPIOneViewArray.append((view.SettingName, true))
                } else {
                    newKPIOneViewArray.append((view.SettingName, false))
                }
            }
            KPIOneViewArray.removeAll()
            KPIOneViewArray = newKPIOneViewArray
        }
    }
    var KPIOneViewArray: [(SettingName: String, value: Bool)] = [(TypeOfKPIView.Numbers.rawValue, true), (TypeOfKPIView.Graph.rawValue, false)]
    //TypeOfChartOne
    var typeOfChartOne: TypeOfChart? {
        get {
            for type in typeOfChartOneArray {
                if type.value == true {
                    return TypeOfChart(rawValue: type.SettingName)!
                }
            }
            return TypeOfChart.PieChart
        }
        set {
            var newTypeOfChartOneArray: [(SettingName: String, value: Bool)] = []
            for view in typeOfChartOneArray {
                if view.SettingName == newValue?.rawValue {
                    newTypeOfChartOneArray.append((view.SettingName, true))
                } else {
                    newTypeOfChartOneArray.append((view.SettingName, false))
                }
            }
            typeOfChartOneArray.removeAll()
            typeOfChartOneArray = newTypeOfChartOneArray
        }
    }
    var typeOfChartOneArray: [(SettingName: String, value: Bool)] = [(TypeOfChart.PieChart.rawValue, true), (TypeOfChart.PointChart.rawValue, false), (TypeOfChart.LineChart.rawValue, false), (TypeOfChart.BarChart.rawValue, false), (TypeOfChart.Funnel.rawValue, false)]
    //KPITwoView
    var KPITwoView: TypeOfKPIView? {
        get {
            for type in KPITwoViewArray {
                if type.value == true {
                    return TypeOfKPIView(rawValue: type.SettingName)!
                }
            }
            return TypeOfKPIView.Graph
        }
        set {
            var newKPITwoViewArray: [(SettingName: String, value: Bool)] = []
            for view in KPITwoViewArray {
                if view.SettingName == newValue?.rawValue {
                    newKPITwoViewArray.append((view.SettingName, true))
                } else {
                    newKPITwoViewArray.append((view.SettingName, false))
                }
            }
            KPITwoViewArray.removeAll()
            KPITwoViewArray = newKPITwoViewArray
        }
    }
    var KPITwoViewArray: [(SettingName: String, value: Bool)] = [(TypeOfKPIView.Numbers.rawValue, false), (TypeOfKPIView.Graph.rawValue, true)]
    //typeOfChartTwo
    var typeOfChartTwo: TypeOfChart? {
        get {
            for type in typeOfChartTwoArray {
                if type.value == true {
                    return TypeOfChart(rawValue: type.SettingName)!
                }
            }
            return TypeOfChart.PieChart
        }
        set {
            var newTypeOfChartTwoArray: [(SettingName: String, value: Bool)] = []
            for view in typeOfChartTwoArray {
                if view.SettingName == newValue?.rawValue {
                    newTypeOfChartTwoArray.append((view.SettingName, true))
                } else {
                    newTypeOfChartTwoArray.append((view.SettingName, false))
                }
            }
            typeOfChartTwoArray.removeAll()
            typeOfChartTwoArray = newTypeOfChartTwoArray
        }
    }
    var typeOfChartTwoArray: [(SettingName: String, value: Bool)] = [(TypeOfChart.PieChart.rawValue, true), (TypeOfChart.PointChart.rawValue, false), (TypeOfChart.LineChart.rawValue, false), (TypeOfChart.BarChart.rawValue, false), (TypeOfChart.Funnel.rawValue, false)]
    //Setting
    enum Setting: String {
        case none
        case Colour
        case KPIname
        case KPInote
        case Department
        case Executant
        case TimeInterval
        case DeliveryDay
        case TimeZone
        case Deadline
        case KPIViewOne
        case ChartOne
        case KPIViewTwo
        case ChartTwo
    }
    var typeOfSetting = Setting.none
    var settingArray: [(SettingName: String, value: Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch buttonDidTaped {
        case .Report:
            self.navigationItem.rightBarButtonItem?.title = "Report"
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationItem.title = "Report KPI"
        case .Edit:
            self.navigationItem.rightBarButtonItem?.title = "Save"
            self.navigationItem.title = "KPI Edit"
            tableView.isScrollEnabled = true
            self.request = Request(model: self.model)
            self.getTeamListFromServer()
            
            for i in 1...31 {
                self.mounthlyIntervalArray.append(("\(i)", false))
            }
        }
        tableView.autoresizesSubviews = true
        tableView.tableFooterView = UIView(frame: .zero)
        self.updateKPIInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateKPIInfo() {
        switch self.kpiArray[kpiIndex].typeOfKPI {
        case .createdKPI:
            let createdKPI = self.kpiArray[kpiIndex].createdKPI
            //Colour
            var tempColourDictionary = self.colourDictionary
            for _ in 0..<tempColourDictionary.count {
                let temp = tempColourDictionary.popFirst()
                if temp?.value == kpiArray[kpiIndex].imageBacgroundColour {
                    self.colour = (temp?.key)!
                }
            }
            //KPI name
            self.kpiName = (createdKPI?.KPI)!
            //KPI note
            self.kpiDescription = createdKPI?.descriptionOfKPI
            //KPI department
            self.department = (createdKPI?.department)!
            //Time interval
            self.timeInterval = (createdKPI?.timeInterval)!
            //Time Zone
            self.timeZone = (createdKPI?.timeZone)!
            //Deadline
            self.deadline = (createdKPI?.deadline)!
            //Charts
            self.KPIOneView = self.kpiArray[kpiIndex].KPIViewOne
            self.KPITwoView = self.kpiArray[kpiIndex].KPIViewTwo!
            self.typeOfChartOne = self.kpiArray[kpiIndex].KPIChartOne
            self.typeOfChartTwo = self.kpiArray[kpiIndex].KPIChartTwo
            
        case .IntegratedKPI:
            //let integratedKPI = self.kpiArray[kpiIndex].integratedKPI
            break
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
            if executantName == executant {
                self.executantArray.append((executantName, true))
            } else {
                self.executantArray.append((executantName, false))
            }
            
        }
        let createdKPI = self.kpiArray[kpiIndex].createdKPI
        self.executant = (createdKPI?.executant.firstName)! + " " + (createdKPI?.executant.lastName)!
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch buttonDidTaped {
        case .Report:
            return 2
        case .Edit:
            switch self.kpiArray[kpiIndex].typeOfKPI {
            case .IntegratedKPI:
                return 2
            case .createdKPI:
                switch typeOfAccount {
                case .Admin:
                    return 3
                case .Manager:
                    return 2
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch buttonDidTaped {
        case .Report:
            switch section {
            case 0:
                return 5
            case 1:
                return 1
            default:
                return 0
            }
        case .Edit:
            switch self.kpiArray[kpiIndex].typeOfKPI {
            case .IntegratedKPI:
                switch section {
                case 0:
                    return 1
                case 1:
                    return 3
                default:
                    return 0
                }
            case .createdKPI:
                switch typeOfAccount {
                case .Admin:
                    switch section {
                    case 0:
                        return 1
                    case 1:
                        return 3
                    case 2:
                        switch self.timeInterval {
                        case .Daily:
                            if KPIOneView == .Numbers && KPITwoView == .Graph || KPIOneView == .Graph && KPITwoView == .Numbers {
                                return 7
                            } else {
                                return 8
                            }
                        default:
                            if KPIOneView == .Numbers && KPITwoView == .Graph || KPIOneView == .Graph && KPITwoView == .Numbers {
                                return 8
                            } else {
                                return 9
                            }
                        }
                    default:
                        return 0
                    }
                case .Manager:
                    switch section {
                    case 0:
                        let interval = kpiArray[kpiIndex].createdKPI?.timeInterval
                        switch interval! {
                        case .Daily:
                            return 4
                        default:
                            return 5
                        }
                    case 1:
                        if KPIOneView == .Numbers && KPITwoView == .Graph || KPIOneView == .Graph && KPITwoView == .Numbers {
                            return 3
                        } else {
                            return 4
                        }
                        
                    default:
                        return 0
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "ReportAndViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ReportAndViewTableViewCell
        
        switch buttonDidTaped {
        case .Report:
            switch indexPath.section {
            case 0:
                cell.selectionStyle = .none
                cell.descriptionOfCell.text = ""
                switch indexPath.row {
                case 0:
                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.descriptionOfKPI
                    cell.headerOfCell.textColor = UIColor.gray
                    cell.headerOfCell.numberOfLines = 0
                case 1:
                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.department.rawValue
                case 2:
                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.timeInterval.rawValue
                case 3:
                    cell.headerOfCell.text = "Time zone: " + (kpiArray[kpiIndex].createdKPI?.timeZone)!
                case 4:
                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.deadline
                default:
                    break
                }
            case 1:
                cell.selectionStyle = .default
                cell.headerOfCell.text = "My Report"
                if self.report == nil {
                    cell.descriptionOfCell.text = "Add report"
                } else {
                    cell.descriptionOfCell.text = "\(self.report!)"
                }
                cell.accessoryType = .disclosureIndicator
            default:
                break
            }
        case .Edit:
            cell.accessoryType = .disclosureIndicator
            switch self.kpiArray[kpiIndex].typeOfKPI {
            case .IntegratedKPI: break
                //                switch section {
                //                case 0:
                //                    cell.headerOfCell.te
                //                case 1:
                //                    return 3
                //                default:
                //                    return 0
            //                }
            case .createdKPI:
                switch typeOfAccount {
                case .Admin:
                    switch indexPath.section {
                    case 0:
                        let colourCell = tableView.dequeueReusableCell(withIdentifier: "SelectColourCell", for: indexPath) as! KPIColourTableViewCell
                        colourCell.headerOfCell.text = "Colour"
                        colourCell.descriptionOfCell.text = self.colour.rawValue
                        colourCell.colourView.backgroundColor = self.kpiArray[kpiIndex].imageBacgroundColour
                        colourCell.prepareForReuse()
                        return colourCell
                    case 1:
                        cell.headerOfCell.textColor = UIColor.black
                        cell.descriptionOfCell.text = ""
                        switch indexPath.row {
                        case 0:
                            cell.headerOfCell.text = self.kpiName
                        case 1:
                            cell.headerOfCell.text = self.kpiDescription ?? "No description"
                            cell.headerOfCell.numberOfLines = 0
                            if self.kpiDescription == nil {
                                cell.headerOfCell.textColor = UIColor.lightGray
                            }
                        case 2:
                            cell.headerOfCell.text = (self.department?.rawValue)! + " Department"
                        default:
                            break
                        }
                    case 2:
                        switch self.timeInterval {
                        case .Daily:
                            if KPIOneView == .Numbers && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    let createdKPI = self.kpiArray[kpiIndex].createdKPI
                                    cell.headerOfCell.text = "Executant"
                                    cell.descriptionOfCell.text = self.executant ?? ((createdKPI?.executant.firstName)! + " " + (createdKPI?.executant.lastName)!)
                                case 1:
                                    cell.headerOfCell.text = "Time interval"
                                    cell.descriptionOfCell.text = self.timeInterval.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Time zone"
                                    cell.descriptionOfCell.text = self.timeZone
                                case 3:
                                    cell.headerOfCell.text = "Deadline"
                                    cell.descriptionOfCell.text = self.deadline
                                    cell.accessoryType = .none
                                case 4:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = self.KPIOneView.rawValue
                                case 5:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = self.KPITwoView?.rawValue
                                case 6:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartTwo?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Numbers {
                                switch indexPath.row {
                                case 0:
                                    let createdKPI = self.kpiArray[kpiIndex].createdKPI
                                    cell.headerOfCell.text = "Executant"
                                    cell.descriptionOfCell.text = self.executant ?? ((createdKPI?.executant.firstName)! + " " + (createdKPI?.executant.lastName)!)
                                case 1:
                                    cell.headerOfCell.text = "Time interval"
                                    cell.descriptionOfCell.text = self.timeInterval.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Time zone"
                                    cell.descriptionOfCell.text = self.timeZone
                                case 3:
                                    cell.headerOfCell.text = "Deadline"
                                    cell.descriptionOfCell.text = self.deadline
                                    cell.accessoryType = .none
                                case 4:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = self.KPIOneView.rawValue
                                case 5:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartOne?.rawValue
                                case 6:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = self.KPITwoView?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    let createdKPI = self.kpiArray[kpiIndex].createdKPI
                                    cell.headerOfCell.text = "Executant"
                                    cell.descriptionOfCell.text = self.executant ?? ((createdKPI?.executant.firstName)! + " " + (createdKPI?.executant.lastName)!)
                                case 1:
                                    cell.headerOfCell.text = "Time interval"
                                    cell.descriptionOfCell.text = self.timeInterval.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Time zone"
                                    cell.descriptionOfCell.text = self.timeZone
                                case 3:
                                    cell.headerOfCell.text = "Deadline"
                                    cell.descriptionOfCell.text = self.deadline
                                    cell.accessoryType = .none
                                case 4:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = self.KPIOneView.rawValue
                                case 5:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartOne?.rawValue
                                case 6:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = self.KPITwoView?.rawValue
                                case 7:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartTwo?.rawValue
                                default:
                                    break
                                }
                            }
                            
                        default:
                            if KPIOneView == .Numbers && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    let createdKPI = self.kpiArray[kpiIndex].createdKPI
                                    cell.headerOfCell.text = "Executant"
                                    cell.descriptionOfCell.text = self.executant ?? ((createdKPI?.executant.firstName)! + " " + (createdKPI?.executant.lastName)!)
                                case 1:
                                    cell.headerOfCell.text = "Time interval"
                                    cell.descriptionOfCell.text = self.timeInterval.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Day"
                                    switch timeInterval {
                                    case .Monthly:
                                        if self.mounthlyInterval != nil {
                                            if self.mounthlyInterval! > 28 {
                                                cell.descriptionOfCell.text = "\(self.mounthlyInterval!) or last day"
                                            } else {
                                                cell.descriptionOfCell.text = "\(self.mounthlyInterval!)"
                                            }
                                            
                                        } else {
                                            cell.descriptionOfCell.text = "Add day"
                                        }
                                    case .Weekly:
                                        cell.descriptionOfCell.text = self.weeklyInterval?.rawValue
                                    default:
                                        break
                                    }
                                case 3:
                                    cell.headerOfCell.text = "Time zone"
                                    cell.descriptionOfCell.text = self.timeZone
                                case 4:
                                    cell.headerOfCell.text = "Deadline"
                                    cell.descriptionOfCell.text = self.deadline
                                    cell.accessoryType = .none
                                case 5:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = self.KPIOneView.rawValue
                                case 6:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = self.KPITwoView?.rawValue
                                case 7:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartTwo?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Numbers {
                                switch indexPath.row {
                                case 0:
                                    let createdKPI = self.kpiArray[kpiIndex].createdKPI
                                    cell.headerOfCell.text = "Executant"
                                    cell.descriptionOfCell.text = self.executant ?? ((createdKPI?.executant.firstName)! + " " + (createdKPI?.executant.lastName)!)
                                case 1:
                                    cell.headerOfCell.text = "Time interval"
                                    cell.descriptionOfCell.text = self.timeInterval.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Day"
                                    switch timeInterval {
                                    case .Monthly:
                                        if self.mounthlyInterval != nil {
                                            if self.mounthlyInterval! > 28 {
                                                cell.descriptionOfCell.text = "\(self.mounthlyInterval!) or last day"
                                            } else {
                                                cell.descriptionOfCell.text = "\(self.mounthlyInterval!)"
                                            }
                                        } else {
                                            cell.descriptionOfCell.text = "Add day"
                                        }
                                    case .Weekly:
                                        cell.descriptionOfCell.text = self.weeklyInterval?.rawValue
                                    default:
                                        break
                                    }
                                case 3:
                                    cell.headerOfCell.text = "Time zone"
                                    cell.descriptionOfCell.text = self.timeZone
                                case 4:
                                    cell.headerOfCell.text = "Deadline"
                                    cell.descriptionOfCell.text = self.deadline
                                    cell.accessoryType = .none
                                case 5:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = self.KPIOneView.rawValue
                                case 6:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartOne?.rawValue
                                case 7:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = self.KPITwoView?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    let createdKPI = self.kpiArray[kpiIndex].createdKPI
                                    cell.headerOfCell.text = "Executant"
                                    cell.descriptionOfCell.text = self.executant ?? ((createdKPI?.executant.firstName)! + " " + (createdKPI?.executant.lastName)!)
                                case 1:
                                    cell.headerOfCell.text = "Time interval"
                                    cell.descriptionOfCell.text = self.timeInterval.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Day"
                                    switch timeInterval {
                                    case .Monthly:
                                        if self.mounthlyInterval != nil {
                                            if self.mounthlyInterval! > 28 {
                                                cell.descriptionOfCell.text = "\(self.mounthlyInterval!) or last day"
                                            } else {
                                                cell.descriptionOfCell.text = "\(self.mounthlyInterval!)"
                                            }
                                        } else {
                                            cell.descriptionOfCell.text = "Add day"
                                        }
                                    case .Weekly:
                                        cell.descriptionOfCell.text = self.weeklyInterval?.rawValue
                                    default:
                                        break
                                    }
                                case 3:
                                    cell.headerOfCell.text = "Time zone"
                                    cell.descriptionOfCell.text = self.timeZone
                                case 4:
                                    cell.headerOfCell.text = "Deadline"
                                    cell.descriptionOfCell.text = self.deadline
                                    cell.accessoryType = .none
                                case 5:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = self.KPIOneView.rawValue
                                case 6:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartOne?.rawValue
                                case 7:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = self.KPITwoView?.rawValue
                                case 8:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartTwo?.rawValue
                                default:
                                    break
                                }
                            }
                        }
                    default:
                        break
                    }
                case .Manager:
                    switch self.timeInterval {
                    case .Daily:
                        switch indexPath.section {
                        case 0:
                            cell.descriptionOfCell.isHidden = true
                            cell.selectionStyle = .none
                            cell.accessoryType = .none
                            switch indexPath.row {
                            case 0:
                                cell.headerOfCell.text = (self.department?.rawValue)! + " Department"
                            case 1:
                                cell.headerOfCell.text = self.timeInterval.rawValue
                            case 2:
                                cell.headerOfCell.text = "Time zone: " + self.timeZone
                            case 3:
                                cell.headerOfCell.text = "Before " + self.deadline
                            default:
                                break
                            }
                        case 1:
                            cell.descriptionOfCell.isHidden = false
                            cell.selectionStyle = .default
                            cell.accessoryType = .disclosureIndicator
                            if KPIOneView == .Numbers && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = self.KPIOneView.rawValue
                                case 1:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = self.KPITwoView?.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartTwo?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Numbers {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = self.KPIOneView.rawValue
                                case 1:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartOne?.rawValue
                                case 2:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = self.KPITwoView?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = self.KPIOneView.rawValue
                                case 1:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartOne?.rawValue
                                case 2:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = self.KPITwoView?.rawValue
                                case 3:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartTwo?.rawValue
                                default:
                                    break
                                }
                            }
                        default:
                            break
                        }
                    default:
                        switch indexPath.section {
                        case 0:
                            cell.descriptionOfCell.isHidden = true
                            cell.selectionStyle = .none
                            cell.accessoryType = .none
                            switch indexPath.row {
                            case 0:
                                cell.headerOfCell.text = (self.department?.rawValue)! + " Department"
                            case 1:
                                cell.headerOfCell.text = self.timeInterval.rawValue
                            case 2:
                                cell.headerOfCell.text = "Day"
                                switch timeInterval {
                                case .Monthly:
                                    if self.mounthlyInterval != nil {
                                        if self.mounthlyInterval! > 28 {
                                            cell.headerOfCell.text = "\(self.mounthlyInterval!) or last day"
                                        } else {
                                            cell.headerOfCell.text = "\(self.mounthlyInterval!)"
                                        }
                                    } else {
                                        cell.headerOfCell.text = "Add day"
                                    }
                                case .Weekly:
                                    cell.headerOfCell.text = self.weeklyInterval?.rawValue
                                default:
                                    break
                                }
                            case 3:
                                cell.headerOfCell.text = "Time zone: " + self.timeZone
                            case 4:
                                cell.headerOfCell.text = "Before " + self.deadline
                            default:
                                break
                            }
                        case 1:
                            cell.descriptionOfCell.isHidden = false
                            cell.selectionStyle = .default
                            cell.accessoryType = .disclosureIndicator
                            if KPIOneView == .Numbers && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = self.KPIOneView.rawValue
                                case 1:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = self.KPITwoView?.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartTwo?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Numbers {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = self.KPIOneView.rawValue
                                case 1:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartOne?.rawValue
                                case 2:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = self.KPITwoView?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = self.KPIOneView.rawValue
                                case 1:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartOne?.rawValue
                                case 2:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = self.KPITwoView?.rawValue
                                case 3:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = self.typeOfChartTwo?.rawValue
                                default:
                                    break
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }
        cell.prepareForReuse()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch buttonDidTaped {
        case .Report:
            switch indexPath.section {
            case 1:
                let destinationVC = storyboard?.instantiateViewController(withIdentifier: "AddReport") as! AddReportTableViewController
                destinationVC.report = self.report
                destinationVC.ReportAndViewVC = self
                navigationController?.pushViewController(destinationVC, animated: true)
            default:
                break
            }
        case .Edit:
            switch self.kpiArray[kpiIndex].typeOfKPI {
            case .IntegratedKPI: break
                //                switch section {
                //                case 0:
                //                    return 1
                //                case 1:
                //                    return 3
                //                default:
                //                    return 0
            //                }
            case .createdKPI:
                switch typeOfAccount {
                case .Admin:
                    switch indexPath.section {
                    case 0:
                        self.typeOfSetting = .Colour
                        self.settingArray = self.colourArray
                        self.showSelectSettingVC()
                    case 1:
                        switch indexPath.row {
                        case 0:
                            self.typeOfSetting = .KPIname
                            self.showSelectSettingVC()
                        case 1:
                            self.typeOfSetting = .KPInote
                            self.showSelectSettingVC()
                        case 2:
                            self.typeOfSetting = .Department
                            self.settingArray = departmentArray
                            self.showSelectSettingVC()
                        default:
                            break
                        }
                    case 2:
                        switch self.timeInterval {
                        case .Daily:
                            if KPIOneView == .Numbers && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    self.typeOfSetting = .Executant
                                    self.settingArray = executantArray
                                    self.showSelectSettingVC()
                                case 1:
                                    self.typeOfSetting = .TimeInterval
                                    self.settingArray = timeIntervalArray
                                    self.showSelectSettingVC()
                                case 2:
                                    self.typeOfSetting = .TimeZone
                                    self.settingArray = timeZoneArray
                                    self.showSelectSettingVC()
                                case 3:
                                    break
                                //deadline
                                case 4:
                                    self.typeOfSetting = .KPIViewOne
                                    self.settingArray = KPIOneViewArray
                                    self.showSelectSettingVC()
                                case 5:
                                    self.typeOfSetting = .KPIViewTwo
                                    self.settingArray = KPITwoViewArray
                                    self.showSelectSettingVC()
                                case 6:
                                    self.typeOfSetting = .ChartTwo
                                    self.settingArray = typeOfChartTwoArray
                                    self.showSelectSettingVC()
                                default:
                                    break
                                }
                                
                            }
                            if KPIOneView == .Graph && KPITwoView == .Numbers {
                                switch indexPath.row {
                                case 0:
                                    self.typeOfSetting = .Executant
                                    self.settingArray = executantArray
                                    self.showSelectSettingVC()
                                case 1:
                                    self.typeOfSetting = .TimeInterval
                                    self.settingArray = timeIntervalArray
                                    self.showSelectSettingVC()
                                case 2:
                                    self.typeOfSetting = .TimeZone
                                    self.settingArray = timeZoneArray
                                    self.showSelectSettingVC()
                                case 3:
                                    break
                                //deadline
                                case 4:
                                    self.typeOfSetting = .KPIViewOne
                                    self.settingArray = KPIOneViewArray
                                    self.showSelectSettingVC()
                                case 5:
                                    self.typeOfSetting = .ChartOne
                                    self.settingArray = typeOfChartOneArray
                                    self.showSelectSettingVC()
                                case 6:
                                    self.typeOfSetting = .KPIViewTwo
                                    self.settingArray = KPITwoViewArray
                                    self.showSelectSettingVC()
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    self.typeOfSetting = .Executant
                                    self.settingArray = executantArray
                                    self.showSelectSettingVC()
                                case 1:
                                    self.typeOfSetting = .TimeInterval
                                    self.settingArray = timeIntervalArray
                                    self.showSelectSettingVC()
                                case 2:
                                    self.typeOfSetting = .TimeZone
                                    self.settingArray = timeZoneArray
                                    self.showSelectSettingVC()
                                case 3:
                                    break
                                //deadline
                                case 4:
                                    self.typeOfSetting = .KPIViewOne
                                    self.settingArray = KPIOneViewArray
                                    self.showSelectSettingVC()
                                case 5:
                                    self.typeOfSetting = .ChartOne
                                    self.settingArray = typeOfChartOneArray
                                    self.showSelectSettingVC()
                                case 6:
                                    self.typeOfSetting = .KPIViewTwo
                                    self.settingArray = KPITwoViewArray
                                    self.showSelectSettingVC()
                                case 7:
                                    self.typeOfSetting = .ChartTwo
                                    self.settingArray = typeOfChartTwoArray
                                    self.showSelectSettingVC()
                                default:
                                    break
                                }
                            }
                        default:
                            if KPIOneView == .Numbers && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    self.typeOfSetting = .Executant
                                    self.settingArray = executantArray
                                    self.showSelectSettingVC()
                                case 1:
                                    self.typeOfSetting = .TimeInterval
                                    self.settingArray = timeIntervalArray
                                    self.showSelectSettingVC()
                                case 2:
                                    self.typeOfSetting = .DeliveryDay
                                    switch timeInterval {
                                    case .Monthly:
                                        self.settingArray = mounthlyIntervalArray
                                    case .Weekly:
                                        self.settingArray = weeklyArray
                                    default:
                                        break
                                    }
                                    self.showSelectSettingVC()
                                case 3:
                                    self.typeOfSetting = .TimeZone
                                    self.settingArray = timeZoneArray
                                    self.showSelectSettingVC()
                                case 4:
                                    break
                                //deadline
                                case 5:
                                    self.typeOfSetting = .KPIViewOne
                                    self.settingArray = KPIOneViewArray
                                    self.showSelectSettingVC()
                                case 6:
                                    self.typeOfSetting = .KPIViewTwo
                                    self.settingArray = KPITwoViewArray
                                    self.showSelectSettingVC()
                                case 7:
                                    self.typeOfSetting = .ChartTwo
                                    self.settingArray = typeOfChartTwoArray
                                    self.showSelectSettingVC()
                                default:
                                    break
                                }
                                
                            }
                            if KPIOneView == .Graph && KPITwoView == .Numbers {
                                switch indexPath.row {
                                case 0:
                                    self.typeOfSetting = .Executant
                                    self.settingArray = executantArray
                                    self.showSelectSettingVC()
                                case 1:
                                    self.typeOfSetting = .TimeInterval
                                    self.settingArray = timeIntervalArray
                                    self.showSelectSettingVC()
                                case 2:
                                    self.typeOfSetting = .DeliveryDay
                                    switch timeInterval {
                                    case .Monthly:
                                        self.settingArray = mounthlyIntervalArray
                                    case .Weekly:
                                        self.settingArray = weeklyArray
                                    default:
                                        break
                                    }
                                    self.showSelectSettingVC()
                                case 3:
                                    self.typeOfSetting = .TimeZone
                                    self.settingArray = timeZoneArray
                                    self.showSelectSettingVC()
                                case 4:
                                    break
                                //deadline
                                case 5:
                                    self.typeOfSetting = .KPIViewOne
                                    self.settingArray = KPIOneViewArray
                                    self.showSelectSettingVC()
                                case 6:
                                    self.typeOfSetting = .ChartOne
                                    self.settingArray = typeOfChartOneArray
                                    self.showSelectSettingVC()
                                case 7:
                                    self.typeOfSetting = .KPIViewTwo
                                    self.settingArray = KPITwoViewArray
                                    self.showSelectSettingVC()
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    self.typeOfSetting = .Executant
                                    self.settingArray = executantArray
                                    self.showSelectSettingVC()
                                case 1:
                                    self.typeOfSetting = .TimeInterval
                                    self.settingArray = timeIntervalArray
                                    self.showSelectSettingVC()
                                case 2:
                                    self.typeOfSetting = .DeliveryDay
                                    switch timeInterval {
                                    case .Monthly:
                                        self.settingArray = mounthlyIntervalArray
                                    case .Weekly:
                                        self.settingArray = weeklyArray
                                    default:
                                        break
                                    }
                                    self.showSelectSettingVC()
                                case 3:
                                    self.typeOfSetting = .TimeZone
                                    self.settingArray = timeZoneArray
                                    self.showSelectSettingVC()
                                case 4:
                                    break
                                //deadline
                                case 5:
                                    self.typeOfSetting = .KPIViewOne
                                    self.settingArray = KPIOneViewArray
                                    self.showSelectSettingVC()
                                case 6:
                                    self.typeOfSetting = .ChartOne
                                    self.settingArray = typeOfChartOneArray
                                    self.showSelectSettingVC()
                                case 7:
                                    self.typeOfSetting = .KPIViewTwo
                                    self.settingArray = KPITwoViewArray
                                    self.showSelectSettingVC()
                                case 8:
                                    self.typeOfSetting = .ChartTwo
                                    self.settingArray = typeOfChartTwoArray
                                    self.showSelectSettingVC()
                                default:
                                    break
                                }
                            }
                        }
                    default:
                        break
                    }
                case .Manager:
                    switch indexPath.section {
                    case 1:
                        if KPIOneView == .Numbers && KPITwoView == .Graph {
                            switch indexPath.row {
                            case 0:
                                self.typeOfSetting = .KPIViewOne
                                self.settingArray = KPIOneViewArray
                                self.showSelectSettingVC()
                            case 1:
                                self.typeOfSetting = .KPIViewTwo
                                self.settingArray = KPITwoViewArray
                                self.showSelectSettingVC()
                            case 2:
                                self.typeOfSetting = .ChartTwo
                                self.settingArray = typeOfChartTwoArray
                                self.showSelectSettingVC()
                            default:
                                break
                            }
                        }
                        if KPIOneView == .Graph && KPITwoView == .Numbers {
                            switch indexPath.row {
                            case 0:
                                self.typeOfSetting = .KPIViewOne
                                self.settingArray = KPIOneViewArray
                                self.showSelectSettingVC()
                            case 1:
                                self.typeOfSetting = .ChartOne
                                self.settingArray = typeOfChartOneArray
                                self.showSelectSettingVC()
                            case 2:
                                self.typeOfSetting = .KPIViewTwo
                                self.settingArray = KPITwoViewArray
                                self.showSelectSettingVC()
                            default:
                                break
                            }
                        }
                        if KPIOneView == .Graph && KPITwoView == .Graph {
                            switch indexPath.row {
                            case 0:
                                self.typeOfSetting = .KPIViewOne
                                self.settingArray = KPIOneViewArray
                                self.showSelectSettingVC()
                            case 1:
                                self.typeOfSetting = .ChartOne
                                self.settingArray = typeOfChartOneArray
                                self.showSelectSettingVC()
                            case 2:
                                self.typeOfSetting = .KPIViewTwo
                                self.settingArray = KPITwoViewArray
                                self.showSelectSettingVC()
                            case 3:
                                self.typeOfSetting = .ChartTwo
                                self.settingArray = typeOfChartTwoArray
                                self.showSelectSettingVC()
                            default:
                                break
                            }
                        }
                        
                    default:
                        break
                    }
                }
            }
        }
        
    }
    
    //MARK: - Show KPISelectSettingTableViewController method
    func showSelectSettingVC() {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "SelectSettingForKPI") as! KPISelectSettingTableViewController
        destinatioVC.ReportAndViewVC = self
        destinatioVC.selectSetting = settingArray
        let createdKPI = self.kpiArray[kpiIndex].createdKPI
        switch typeOfSetting {
        case .Colour:
            destinatioVC.segueWithSelecting = true
            destinatioVC.cellsWithColourView = true
            destinatioVC.colourDictionary = self.colourDictionary
        case .KPIname:
            destinatioVC.inputSettingCells = true
            destinatioVC.textFieldInputData = createdKPI?.KPI
        case .KPInote:
            destinatioVC.inputSettingCells = true
            destinatioVC.textFieldInputData = createdKPI?.descriptionOfKPI
        default:
            break
        }
        destinatioVC.navigationItem.rightBarButtonItem = nil
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            switch buttonDidTaped {
            case .Report:
                return kpiArray[kpiIndex].createdKPI?.KPI
            case .Edit:
                return " "
            }
            
        default:
            return " "
        }
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
    
    @IBAction func tapRightBarButton(_ sender: UIBarButtonItem) {
        
        var newKpi = kpiArray[kpiIndex].createdKPI
        
        switch buttonDidTaped {
        case .Report:
            newKpi?.addReport(report: self.report!)
            self.kpiArray[kpiIndex].createdKPI = newKpi
        case .Edit:
            switch self.kpiArray[kpiIndex].typeOfKPI {
            case .createdKPI:
                switch model.profile!.typeOfAccount {
                case .Admin:
                    var executantProfile: Profile!
                    for profile in self.memberlistArray {
                        if self.executant == profile.firstName + " " + profile.lastName {
                            executantProfile = Profile(profile: profile)
                        }
                    }
                    newKpi = CreatedKPI(source: .User, department: self.department!, KPI: self.kpiName, descriptionOfKPI: self.kpiDescription, executant: executantProfile, timeInterval: self.timeInterval, timeZone: self.timeZone, deadline: self.deadline, number: (self.kpiArray[kpiIndex].createdKPI?.number)!)
                    self.kpiArray[kpiIndex].createdKPI = newKpi
                    self.kpiArray[kpiIndex].KPIViewOne = self.KPIOneView
                    self.kpiArray[kpiIndex].KPIChartOne = self.typeOfChartOne
                    self.kpiArray[kpiIndex].KPIViewTwo = self.KPITwoView
                    self.kpiArray[kpiIndex].KPIChartTwo = self.typeOfChartTwo
                    if self.colour != .none {
                        self.kpiArray[kpiIndex].imageBacgroundColour = colourDictionary[self.colour]!
                    }
                case .Manager:
                    self.kpiArray[kpiIndex].KPIViewOne = self.KPIOneView
                    self.kpiArray[kpiIndex].KPIChartOne = self.typeOfChartOne
                    self.kpiArray[kpiIndex].KPIViewTwo = self.KPITwoView
                    self.kpiArray[kpiIndex].KPIChartTwo = self.typeOfChartTwo
                }
            default:
                break
            }
        }
        delegate = self.KPIListVC
        delegate.updateKPIList(kpiArray: self.kpiArray)
        _ = navigationController?.popViewController(animated: true)
    }
    
    //MARK: - updateSettingsArrayDelegate methods
    func updateStringValue(string: String?) {
        switch typeOfSetting {
        case .KPIname:
            if string != nil {
                kpiName = string!
            }
        case .KPInote:
            kpiDescription = string
        default:
            return
        }
        tableView.reloadData()
    }
    func updateSettingsArray(array: [(SettingName: String, value: Bool)]) {
        switch typeOfSetting {
        case .Colour:
            self.colourArray = array
            self.kpiArray[kpiIndex].imageBacgroundColour = self.colourDictionary[self.colour]!
        case .Department:
            self.departmentArray = array
        case .Executant:
            self.executantArray = array
        case .TimeInterval:
            self.timeIntervalArray = array
        case .DeliveryDay:
            switch self.timeInterval {
            case .Monthly:
                self.mounthlyIntervalArray = array
            case .Weekly:
                self.weeklyArray = array
            default:
                break
            }
        case .TimeZone:
            self.timeZoneArray = array
        case .KPIViewOne:
            self.KPIOneViewArray = array
            if KPIOneView == .Numbers && KPITwoView == .Numbers {
                KPITwoView = .Graph
            }
        case .ChartOne:
            self.typeOfChartOneArray = array
        case .KPIViewTwo:
            self.KPITwoViewArray = array
            if KPIOneView == .Numbers && KPITwoView == .Numbers {
                KPIOneView = .Graph
            }
        case .ChartTwo:
            self.typeOfChartTwoArray = array
        default:
            break
        }
        self.tableView.reloadData()
    }
    func updateDoubleValue(number: Double?) {
        self.report = number
        self.tableView.reloadData()
        if report != nil {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
}
