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

class ReportAndViewKPITableViewController: UITableViewController {
    
    var model: ModelCoreKPI!
    weak var KPIListVC: KPIsListTableViewController!
    var delegate: updateKPIListDelegate!
    
    var kpiIndex: Int!
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
    var executant: Int? {
        get {
            for member in executantArray {
                if member.value == true {
                    for profile in model.team {
                        if member.SettingName == profile.firstName! + " " + profile.lastName! {
                            return Int(profile.userID)
                        }
                    }
                }
            }
            return nil
        }
        set {
            var newExecutantArray: [(SettingName: String, value: Bool)] = []
            for executant in executantArray {
                if executant.SettingName == getExecutantName(userID: newValue) {
                    newExecutantArray.append((executant.SettingName, true))
                } else {
                    newExecutantArray.append((executant.SettingName, false))
                }
            }
            executantArray = newExecutantArray
        }
    }
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
    var deadline: Date!
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
    var typeOfChartOneArray: [(SettingName: String, value: Bool)] = [(TypeOfChart.PieChart.rawValue, true), (TypeOfChart.PointChart.rawValue, false), (TypeOfChart.LineChart.rawValue, false), (TypeOfChart.BarChart.rawValue, false), (TypeOfChart.Funnel.rawValue, false), (TypeOfChart.PositiveBar.rawValue, false), (TypeOfChart.AreaChart.rawValue, false)]
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
    var typeOfChartTwoArray: [(SettingName: String, value: Bool)] = [(TypeOfChart.PieChart.rawValue, true), (TypeOfChart.PointChart.rawValue, false), (TypeOfChart.LineChart.rawValue, false), (TypeOfChart.BarChart.rawValue, false), (TypeOfChart.Funnel.rawValue, false), (TypeOfChart.PositiveBar.rawValue, false), (TypeOfChart.AreaChart.rawValue, false)]
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
    
    let modelDidChangeNotification = Notification.Name(rawValue:"modelDidChange")
    
    var datePickerIsVisible = false
    
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
            self.createExecutantArray()
            let nc = NotificationCenter.default
            nc.addObserver(forName: modelDidChangeNotification, object:nil, queue:nil, using:catchNotification)
            
            for i in 1...31 {
                self.mounthlyIntervalArray.append(("\(i)", false))
            }
        }
        tableView.autoresizesSubviews = true
        tableView.tableFooterView = UIView(frame: .zero)
        updateKPIInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateKPIInfo() {
        switch self.model.kpis[kpiIndex].typeOfKPI {
        case .createdKPI:
            let createdKPI = model.kpis[kpiIndex].createdKPI
            //Colour
            var tempColourDictionary = colourDictionary
            for _ in 0..<tempColourDictionary.count {
                let temp = tempColourDictionary.popFirst()
                if temp?.value == model.kpis[kpiIndex].imageBacgroundColour {
                    colour = (temp?.key)!
                }
            }
            //KPI name
            kpiName = (createdKPI?.KPI)!
            //KPI note
            kpiDescription = createdKPI?.descriptionOfKPI
            //KPI department
            department = (createdKPI?.department)!
            //Time interval
            timeInterval = (createdKPI?.timeInterval)!
            //Time Zone
            timeZone = (createdKPI?.timeZone)!
            //Deadline
            deadline = (createdKPI?.deadline)!
            //Charts
            KPIOneView = model.kpis[kpiIndex].KPIViewOne
            KPITwoView = model.kpis[kpiIndex].KPIViewTwo!
            typeOfChartOne = model.kpis[kpiIndex].KPIChartOne
            typeOfChartTwo = model.kpis[kpiIndex].KPIChartTwo
            
        case .IntegratedKPI:
            //let integratedKPI = self.kpiArray[kpiIndex].integratedKPI
            break
        }
    }
    
    //MARK: - catchNotification
    func catchNotification(notification:Notification) -> Void {
        
        if notification.name == self.modelDidChangeNotification {
            guard let userInfo = notification.userInfo,
                let model = userInfo["model"] as? ModelCoreKPI else {
                    print("No userInfo found in notification")
                    return
            }
            self.model.team = model.team
            executantArray.removeAll()
            createExecutantArray()
            tableView.reloadData()
        }
    }
    
    //MARK: create executantArray
    func createExecutantArray() {
        for profile in model.team {
            let executantName = profile.firstName! + " " + profile.lastName!
            executantArray.append((executantName, false))
        }
        let createdKPI = model.kpis[kpiIndex].createdKPI
        executant = createdKPI?.executant
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch buttonDidTaped {
        case .Report:
            return 2
        case .Edit:
            switch self.model.kpis[kpiIndex].typeOfKPI {
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
            switch self.model.kpis[kpiIndex].typeOfKPI {
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
                                return datePickerIsVisible ? 8 : 7
                            } else {
                                return datePickerIsVisible ? 9 : 8
                            }
                        default:
                            if KPIOneView == .Numbers && KPITwoView == .Graph || KPIOneView == .Graph && KPITwoView == .Numbers {
                                return datePickerIsVisible ? 9 : 8
                            } else {
                                return datePickerIsVisible ? 10 : 9
                            }
                        }
                    default:
                        return 0
                    }
                case .Manager:
                    switch section {
                    case 0:
                        let interval = model.kpis[kpiIndex].createdKPI?.timeInterval
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
                    cell.headerOfCell.text = model.kpis[kpiIndex].createdKPI?.descriptionOfKPI ?? "No description"
                    cell.headerOfCell.textColor = UIColor.gray
                    cell.headerOfCell.numberOfLines = 0
                case 1:
                    cell.headerOfCell.text = model.kpis[kpiIndex].createdKPI?.department.rawValue
                case 2:
                    cell.headerOfCell.text = model.kpis[kpiIndex].createdKPI?.timeInterval.rawValue
                case 3:
                    cell.headerOfCell.text = "Time zone: " + (model.kpis[kpiIndex].createdKPI?.timeZone)!
                case 4:
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "hh:mm"
                    let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadline)!)
                    cell.headerOfCell.text = date
                default:
                    break
                }
            case 1:
                cell.selectionStyle = .default
                cell.headerOfCell.text = "My Report"
                if report == nil {
                    cell.descriptionOfCell.text = "Add report"
                } else {
                    let formatter: NumberFormatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.maximumFractionDigits = 10
                    let formattedStr: String = formatter.string(from: NSNumber(value: report!))!
                    cell.descriptionOfCell.text = formattedStr
                }
                cell.accessoryType = .disclosureIndicator
            default:
                break
            }
        case .Edit:
            cell.accessoryType = .disclosureIndicator
            switch model.kpis[kpiIndex].typeOfKPI {
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
                        colourCell.descriptionOfCell.text = colour.rawValue
                        for color in colourDictionary {
                            if color.key == colour {
                                colourCell.colourView.backgroundColor = color.value
                                colourCell.prepareForReuse()
                                return colourCell
                            }
                        }
                        colourCell.colourView.backgroundColor = UIColor.clear
                        colourCell.prepareForReuse()
                        return colourCell
                    case 1:
                        cell.headerOfCell.textColor = UIColor.black
                        cell.descriptionOfCell.text = ""
                        switch indexPath.row {
                        case 0:
                            cell.headerOfCell.text = kpiName
                        case 1:
                            cell.headerOfCell.text = kpiDescription ?? "No description"
                            cell.headerOfCell.numberOfLines = 0
                            if kpiDescription == nil {
                                cell.headerOfCell.textColor = UIColor.lightGray
                            }
                        case 2:
                            cell.headerOfCell.text = (department?.rawValue)! + " Department"
                        default:
                            break
                        }
                    case 2:
                        switch self.timeInterval {
                        case .Daily:
                            if KPIOneView == .Numbers && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "Executant"
                                    cell.descriptionOfCell.text = getExecutantName(userID: executant)
                                case 1:
                                    cell.headerOfCell.text = "Time interval"
                                    cell.descriptionOfCell.text = timeInterval.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Time zone"
                                    cell.descriptionOfCell.text = timeZone
                                case 3:
                                    cell.headerOfCell.text = "Deadline"
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "hh:mm"
                                    let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadline)!)
                                    cell.descriptionOfCell.text = date
                                    cell.accessoryType = .none
                                case 4:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = KPIOneView.rawValue
                                case 5:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = KPITwoView?.rawValue
                                case 6:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartTwo?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Numbers {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "Executant"
                                    cell.descriptionOfCell.text = getExecutantName(userID: executant)
                                case 1:
                                    cell.headerOfCell.text = "Time interval"
                                    cell.descriptionOfCell.text = timeInterval.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Time zone"
                                    cell.descriptionOfCell.text = timeZone
                                case 3:
                                    cell.headerOfCell.text = "Deadline"
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "hh:mm"
                                    let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadline)!)
                                    cell.descriptionOfCell.text = date
                                    cell.accessoryType = .none
                                case 4:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = KPIOneView.rawValue
                                case 5:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartOne?.rawValue
                                case 6:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = KPITwoView?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "Executant"
                                    cell.descriptionOfCell.text = getExecutantName(userID: executant)
                                case 1:
                                    cell.headerOfCell.text = "Time interval"
                                    cell.descriptionOfCell.text = timeInterval.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Time zone"
                                    cell.descriptionOfCell.text = timeZone
                                case 3:
                                    cell.headerOfCell.text = "Deadline"
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "hh:mm"
                                    let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadline)!)
                                    cell.descriptionOfCell.text = date
                                    cell.accessoryType = .none
                                case 4:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = KPIOneView.rawValue
                                case 5:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartOne?.rawValue
                                case 6:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = KPITwoView?.rawValue
                                case 7:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartTwo?.rawValue
                                default:
                                    break
                                }
                            }
                            
                        default:
                            if KPIOneView == .Numbers && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "Executant"
                                    cell.descriptionOfCell.text = getExecutantName(userID: executant)
                                case 1:
                                    cell.headerOfCell.text = "Time interval"
                                    cell.descriptionOfCell.text = timeInterval.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Day"
                                    switch timeInterval {
                                    case .Monthly:
                                        if self.mounthlyInterval != nil {
                                            if mounthlyInterval! > 28 {
                                                cell.descriptionOfCell.text = "\(mounthlyInterval!) or last day"
                                            } else {
                                                cell.descriptionOfCell.text = "\(mounthlyInterval!)"
                                            }
                                            
                                        } else {
                                            cell.descriptionOfCell.text = "Add day"
                                        }
                                    case .Weekly:
                                        cell.descriptionOfCell.text = weeklyInterval?.rawValue
                                    default:
                                        break
                                    }
                                case 3:
                                    cell.headerOfCell.text = "Time zone"
                                    cell.descriptionOfCell.text = timeZone
                                case 4:
                                    cell.headerOfCell.text = "Deadline"
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "hh:mm"
                                    let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadline)!)
                                    cell.descriptionOfCell.text = date
                                    cell.accessoryType = .none
                                case 5:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = KPIOneView.rawValue
                                case 6:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = KPITwoView?.rawValue
                                case 7:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartTwo?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Numbers {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "Executant"
                                    cell.descriptionOfCell.text = getExecutantName(userID: executant)
                                case 1:
                                    cell.headerOfCell.text = "Time interval"
                                    cell.descriptionOfCell.text = timeInterval.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Day"
                                    switch timeInterval {
                                    case .Monthly:
                                        if self.mounthlyInterval != nil {
                                            if self.mounthlyInterval! > 28 {
                                                cell.descriptionOfCell.text = "\(mounthlyInterval!) or last day"
                                            } else {
                                                cell.descriptionOfCell.text = "\(mounthlyInterval!)"
                                            }
                                        } else {
                                            cell.descriptionOfCell.text = "Add day"
                                        }
                                    case .Weekly:
                                        cell.descriptionOfCell.text = weeklyInterval?.rawValue
                                    default:
                                        break
                                    }
                                case 3:
                                    cell.headerOfCell.text = "Time zone"
                                    cell.descriptionOfCell.text = timeZone
                                case 4:
                                    cell.headerOfCell.text = "Deadline"
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "hh:mm"
                                    let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadline)!)
                                    cell.descriptionOfCell.text = date
                                    cell.accessoryType = .none
                                case 5:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = KPIOneView.rawValue
                                case 6:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartOne?.rawValue
                                case 7:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = KPITwoView?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "Executant"
                                    cell.descriptionOfCell.text = getExecutantName(userID: executant)
                                case 1:
                                    cell.headerOfCell.text = "Time interval"
                                    cell.descriptionOfCell.text = timeInterval.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Day"
                                    switch timeInterval {
                                    case .Monthly:
                                        if self.mounthlyInterval != nil {
                                            if self.mounthlyInterval! > 28 {
                                                cell.descriptionOfCell.text = "\(mounthlyInterval!) or last day"
                                            } else {
                                                cell.descriptionOfCell.text = "\(mounthlyInterval!)"
                                            }
                                        } else {
                                            cell.descriptionOfCell.text = "Add day"
                                        }
                                    case .Weekly:
                                        cell.descriptionOfCell.text = weeklyInterval?.rawValue
                                    default:
                                        break
                                    }
                                case 3:
                                    cell.headerOfCell.text = "Time zone"
                                    cell.descriptionOfCell.text = timeZone
                                case 4:
                                    cell.headerOfCell.text = "Deadline"
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "hh:mm"
                                    let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadline)!)
                                    cell.descriptionOfCell.text = date
                                    cell.accessoryType = .none
                                case 5:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = KPIOneView.rawValue
                                case 6:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartOne?.rawValue
                                case 7:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = KPITwoView?.rawValue
                                case 8:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartTwo?.rawValue
                                default:
                                    break
                                }
                            }
                        }
                    default:
                        break
                    }
                case .Manager:
                    switch timeInterval {
                    case .Daily:
                        switch indexPath.section {
                        case 0:
                            cell.descriptionOfCell.isHidden = true
                            cell.selectionStyle = .none
                            cell.accessoryType = .none
                            switch indexPath.row {
                            case 0:
                                cell.headerOfCell.text = (department?.rawValue)! + " Department"
                            case 1:
                                cell.headerOfCell.text = timeInterval.rawValue
                            case 2:
                                cell.headerOfCell.text = "Time zone: " + timeZone
                            case 3:
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "hh:mm"
                                let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadline)!)
                                cell.headerOfCell.text = "Before " + date
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
                                    cell.descriptionOfCell.text = KPIOneView.rawValue
                                case 1:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = KPITwoView?.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartTwo?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Numbers {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = KPIOneView.rawValue
                                case 1:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartOne?.rawValue
                                case 2:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = KPITwoView?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = KPIOneView.rawValue
                                case 1:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartOne?.rawValue
                                case 2:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = KPITwoView?.rawValue
                                case 3:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartTwo?.rawValue
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
                                cell.headerOfCell.text = (department?.rawValue)! + " Department"
                            case 1:
                                cell.headerOfCell.text = timeInterval.rawValue
                            case 2:
                                cell.headerOfCell.text = "Day"
                                switch timeInterval {
                                case .Monthly:
                                    if self.mounthlyInterval != nil {
                                        if self.mounthlyInterval! > 28 {
                                            cell.headerOfCell.text = "\(mounthlyInterval!) or last day"
                                        } else {
                                            cell.headerOfCell.text = "\(mounthlyInterval!)"
                                        }
                                    } else {
                                        cell.headerOfCell.text = "Add day"
                                    }
                                case .Weekly:
                                    cell.headerOfCell.text = weeklyInterval?.rawValue
                                default:
                                    break
                                }
                            case 3:
                                cell.headerOfCell.text = "Time zone: " + timeZone
                            case 4:
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "hh:mm"
                                let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadline)!)
                                cell.headerOfCell.text = "Before " + date
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
                                    cell.descriptionOfCell.text = KPIOneView.rawValue
                                case 1:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = KPITwoView?.rawValue
                                case 2:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartTwo?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Numbers {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = KPIOneView.rawValue
                                case 1:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartOne?.rawValue
                                case 2:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = KPITwoView?.rawValue
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = KPIOneView.rawValue
                                case 1:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartOne?.rawValue
                                case 2:
                                    cell.headerOfCell.text = "KPI's 2 st view"
                                    cell.descriptionOfCell.text = KPITwoView?.rawValue
                                case 3:
                                    cell.headerOfCell.text = "Graph type"
                                    cell.descriptionOfCell.text = typeOfChartTwo?.rawValue
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
            switch model.kpis[kpiIndex].typeOfKPI {
            case .IntegratedKPI: break
                    //Warning!
            case .createdKPI:
                switch typeOfAccount {
                case .Admin:
                    switch indexPath.section {
                    case 0:
                        typeOfSetting = .Colour
                        settingArray = self.colourArray
                        showSelectSettingVC()
                    case 1:
                        switch indexPath.row {
                        case 0:
                            typeOfSetting = .KPIname
                            showSelectSettingVC()
                        case 1:
                            typeOfSetting = .KPInote
                            showSelectSettingVC()
                        case 2:
                            typeOfSetting = .Department
                            settingArray = departmentArray
                            showSelectSettingVC()
                        default:
                            break
                        }
                    case 2:
                        switch timeInterval {
                        case .Daily:
                            if KPIOneView == .Numbers && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    typeOfSetting = .Executant
                                    settingArray = executantArray
                                    showSelectSettingVC()
                                case 1:
                                    typeOfSetting = .TimeInterval
                                    settingArray = timeIntervalArray
                                    showSelectSettingVC()
                                case 2:
                                    typeOfSetting = .TimeZone
                                    settingArray = timeZoneArray
                                    showSelectSettingVC()
                                case 3:
                                    break
                                //deadline
                                case 4:
                                    typeOfSetting = .KPIViewOne
                                    settingArray = KPIOneViewArray
                                    showSelectSettingVC()
                                case 5:
                                    typeOfSetting = .KPIViewTwo
                                    settingArray = KPITwoViewArray
                                    showSelectSettingVC()
                                case 6:
                                    typeOfSetting = .ChartTwo
                                    settingArray = typeOfChartTwoArray
                                    showSelectSettingVC()
                                default:
                                    break
                                }
                                
                            }
                            if KPIOneView == .Graph && KPITwoView == .Numbers {
                                switch indexPath.row {
                                case 0:
                                    typeOfSetting = .Executant
                                    settingArray = executantArray
                                    showSelectSettingVC()
                                case 1:
                                    typeOfSetting = .TimeInterval
                                    settingArray = timeIntervalArray
                                    showSelectSettingVC()
                                case 2:
                                    typeOfSetting = .TimeZone
                                    settingArray = timeZoneArray
                                    showSelectSettingVC()
                                case 3:
                                    break
                                //deadline
                                case 4:
                                    typeOfSetting = .KPIViewOne
                                    settingArray = KPIOneViewArray
                                    showSelectSettingVC()
                                case 5:
                                    typeOfSetting = .ChartOne
                                    settingArray = typeOfChartOneArray
                                    showSelectSettingVC()
                                case 6:
                                    typeOfSetting = .KPIViewTwo
                                    settingArray = KPITwoViewArray
                                    showSelectSettingVC()
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    typeOfSetting = .Executant
                                    settingArray = executantArray
                                    showSelectSettingVC()
                                case 1:
                                    typeOfSetting = .TimeInterval
                                    settingArray = timeIntervalArray
                                    showSelectSettingVC()
                                case 2:
                                    typeOfSetting = .TimeZone
                                    settingArray = timeZoneArray
                                    showSelectSettingVC()
                                case 3:
                                    break
                                //deadline
                                case 4:
                                    typeOfSetting = .KPIViewOne
                                    settingArray = KPIOneViewArray
                                    showSelectSettingVC()
                                case 5:
                                    typeOfSetting = .ChartOne
                                    settingArray = typeOfChartOneArray
                                    showSelectSettingVC()
                                case 6:
                                    typeOfSetting = .KPIViewTwo
                                    settingArray = KPITwoViewArray
                                    showSelectSettingVC()
                                case 7:
                                    typeOfSetting = .ChartTwo
                                    settingArray = typeOfChartTwoArray
                                    showSelectSettingVC()
                                default:
                                    break
                                }
                            }
                        default:
                            if KPIOneView == .Numbers && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    typeOfSetting = .Executant
                                    settingArray = executantArray
                                    showSelectSettingVC()
                                case 1:
                                    typeOfSetting = .TimeInterval
                                    settingArray = timeIntervalArray
                                    showSelectSettingVC()
                                case 2:
                                    typeOfSetting = .DeliveryDay
                                    switch timeInterval {
                                    case .Monthly:
                                        settingArray = mounthlyIntervalArray
                                    case .Weekly:
                                        settingArray = weeklyArray
                                    default:
                                        break
                                    }
                                    showSelectSettingVC()
                                case 3:
                                    typeOfSetting = .TimeZone
                                    settingArray = timeZoneArray
                                    showSelectSettingVC()
                                case 4:
                                    break
                                //deadline
                                case 5:
                                    typeOfSetting = .KPIViewOne
                                    settingArray = KPIOneViewArray
                                    showSelectSettingVC()
                                case 6:
                                    typeOfSetting = .KPIViewTwo
                                    settingArray = KPITwoViewArray
                                    showSelectSettingVC()
                                case 7:
                                    typeOfSetting = .ChartTwo
                                    settingArray = typeOfChartTwoArray
                                    showSelectSettingVC()
                                default:
                                    break
                                }
                                
                            }
                            if KPIOneView == .Graph && KPITwoView == .Numbers {
                                switch indexPath.row {
                                case 0:
                                    typeOfSetting = .Executant
                                    settingArray = executantArray
                                    showSelectSettingVC()
                                case 1:
                                    typeOfSetting = .TimeInterval
                                    settingArray = timeIntervalArray
                                    showSelectSettingVC()
                                case 2:
                                    typeOfSetting = .DeliveryDay
                                    switch timeInterval {
                                    case .Monthly:
                                        settingArray = mounthlyIntervalArray
                                    case .Weekly:
                                        settingArray = weeklyArray
                                    default:
                                        break
                                    }
                                    self.showSelectSettingVC()
                                case 3:
                                    typeOfSetting = .TimeZone
                                    settingArray = timeZoneArray
                                    showSelectSettingVC()
                                case 4:
                                    break
                                //deadline
                                case 5:
                                    typeOfSetting = .KPIViewOne
                                    settingArray = KPIOneViewArray
                                    showSelectSettingVC()
                                case 6:
                                    typeOfSetting = .ChartOne
                                    settingArray = typeOfChartOneArray
                                    showSelectSettingVC()
                                case 7:
                                    typeOfSetting = .KPIViewTwo
                                    settingArray = KPITwoViewArray
                                    showSelectSettingVC()
                                default:
                                    break
                                }
                            }
                            if KPIOneView == .Graph && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    typeOfSetting = .Executant
                                    settingArray = executantArray
                                    showSelectSettingVC()
                                case 1:
                                    typeOfSetting = .TimeInterval
                                    settingArray = timeIntervalArray
                                    showSelectSettingVC()
                                case 2:
                                    typeOfSetting = .DeliveryDay
                                    switch timeInterval {
                                    case .Monthly:
                                        settingArray = mounthlyIntervalArray
                                    case .Weekly:
                                        settingArray = weeklyArray
                                    default:
                                        break
                                    }
                                    self.showSelectSettingVC()
                                case 3:
                                    typeOfSetting = .TimeZone
                                    settingArray = timeZoneArray
                                    showSelectSettingVC()
                                case 4:
                                    break
                                //deadline
                                case 5:
                                    typeOfSetting = .KPIViewOne
                                    settingArray = KPIOneViewArray
                                    showSelectSettingVC()
                                case 6:
                                    typeOfSetting = .ChartOne
                                    settingArray = typeOfChartOneArray
                                    showSelectSettingVC()
                                case 7:
                                    typeOfSetting = .KPIViewTwo
                                    settingArray = KPITwoViewArray
                                    showSelectSettingVC()
                                case 8:
                                    typeOfSetting = .ChartTwo
                                    settingArray = typeOfChartTwoArray
                                    showSelectSettingVC()
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
                                typeOfSetting = .KPIViewOne
                                settingArray = KPIOneViewArray
                                showSelectSettingVC()
                            case 1:
                                typeOfSetting = .KPIViewTwo
                                settingArray = KPITwoViewArray
                                showSelectSettingVC()
                            case 2:
                                typeOfSetting = .ChartTwo
                                settingArray = typeOfChartTwoArray
                                showSelectSettingVC()
                            default:
                                break
                            }
                        }
                        if KPIOneView == .Graph && KPITwoView == .Numbers {
                            switch indexPath.row {
                            case 0:
                                typeOfSetting = .KPIViewOne
                                settingArray = KPIOneViewArray
                                showSelectSettingVC()
                            case 1:
                                typeOfSetting = .ChartOne
                                settingArray = typeOfChartOneArray
                                showSelectSettingVC()
                            case 2:
                                typeOfSetting = .KPIViewTwo
                                settingArray = KPITwoViewArray
                                showSelectSettingVC()
                            default:
                                break
                            }
                        }
                        if KPIOneView == .Graph && KPITwoView == .Graph {
                            switch indexPath.row {
                            case 0:
                                typeOfSetting = .KPIViewOne
                                settingArray = KPIOneViewArray
                                showSelectSettingVC()
                            case 1:
                                typeOfSetting = .ChartOne
                                settingArray = typeOfChartOneArray
                                showSelectSettingVC()
                            case 2:
                                typeOfSetting = .KPIViewTwo
                                settingArray = KPITwoViewArray
                                showSelectSettingVC()
                            case 3:
                                typeOfSetting = .ChartTwo
                                settingArray = typeOfChartTwoArray
                                showSelectSettingVC()
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
    
    func getExecutantName(userID: Int?) -> String? {
        if userID == nil {
            return nil
        }
        for member in model.team {
            if Int(member.userID) == userID {
                return member.firstName! + " " + member.lastName!
            }
        }
        return nil
    }
    
    //MARK: - Show KPISelectSettingTableViewController method
    func showSelectSettingVC() {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "SelectSettingForKPI") as! KPISelectSettingTableViewController
        destinatioVC.ReportAndViewVC = self
        destinatioVC.selectSetting = settingArray
        switch typeOfSetting {
        case .Colour:
            destinatioVC.segueWithSelecting = true
            destinatioVC.cellsWithColourView = true
            destinatioVC.colourDictionary = self.colourDictionary
        case .KPIname:
            destinatioVC.inputSettingCells = true
            destinatioVC.textFieldInputData = self.kpiName
        case .KPInote:
            destinatioVC.inputSettingCells = true
            destinatioVC.textFieldInputData = self.kpiDescription
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
                return model.kpis[kpiIndex].createdKPI?.KPI
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
        
        var newKpi = self.model.kpis[kpiIndex].createdKPI
        
        switch buttonDidTaped {
        case .Report:
            newKpi?.addReport(date: Date(), report: self.report!)
            self.model.kpis[kpiIndex].createdKPI = newKpi
            let request = AddReport(model: model)
            request.addReportForKPI(withID: self.model.kpis[kpiIndex].id, report: self.report!, success: {
            self.prepareToMove()
            }, failure: { error in
                print(error)
                self.showAlert(title: "Sorry",errorMessage: error)
            }
            )
        case .Edit:
            switch self.model.kpis[kpiIndex].typeOfKPI {
            case .createdKPI:
                switch model.profile!.typeOfAccount {
                case .Admin:
                    let executantProfile: Int! = executant
                    newKpi = CreatedKPI(source: .User, department: self.department!, KPI: self.kpiName, descriptionOfKPI: self.kpiDescription, executant: executantProfile, timeInterval: self.timeInterval, timeZone: self.timeZone, deadline: self.deadline, number: (self.model.kpis[kpiIndex].createdKPI?.number)!)
                    self.model.kpis[kpiIndex].createdKPI = newKpi
                    self.model.kpis[kpiIndex].KPIViewOne = self.KPIOneView
                    self.model.kpis[kpiIndex].KPIChartOne = self.typeOfChartOne
                    self.model.kpis[kpiIndex].KPIViewTwo = self.KPITwoView
                    self.model.kpis[kpiIndex].KPIChartTwo = self.typeOfChartTwo
                    if self.colour != .none {
                        self.model.kpis[kpiIndex].imageBacgroundColour = colourDictionary[self.colour]!
                    }
                case .Manager:
                    self.model.kpis[kpiIndex].KPIViewOne = self.KPIOneView
                    self.model.kpis[kpiIndex].KPIChartOne = self.typeOfChartOne
                    self.model.kpis[kpiIndex].KPIViewTwo = self.KPITwoView
                    self.model.kpis[kpiIndex].KPIChartTwo = self.typeOfChartTwo
                }
            default:
                break
            }
            let request = EditKPI(model: model)
            request.editKPI(kpi: self.model.kpis[kpiIndex], success: {
                self.prepareToMove()
            }, failure: { error in
                print(error)
                self.showAlert(title: "Sorry",errorMessage: error)
            }
            )
        }
        

    }
    
    func prepareToMove() {
        delegate = KPIListVC
        delegate.updateKPIList(kpiArray: self.model.kpis)
        _ = navigationController?.popViewController(animated: true)
    }
    
    //MARK: - show alert function
    func showAlert(title: String, errorMessage: String) {
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}

//MARK: - updateSettingsArrayDelegate methods
extension ReportAndViewKPITableViewController: updateSettingsDelegate {
    
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
            colourArray = array
        case .Department:
            departmentArray = array
        case .Executant:
            executantArray = array
        case .TimeInterval:
            timeIntervalArray = array
        case .DeliveryDay:
            switch timeInterval {
            case .Monthly:
                mounthlyIntervalArray = array
            case .Weekly:
                weeklyArray = array
            default:
                break
            }
        case .TimeZone:
            timeZoneArray = array
        case .KPIViewOne:
            KPIOneViewArray = array
            if KPIOneView == .Numbers && KPITwoView == .Numbers {
                KPITwoView = .Graph
            }
        case .ChartOne:
            typeOfChartOneArray = array
        case .KPIViewTwo:
            KPITwoViewArray = array
            if KPIOneView == .Numbers && KPITwoView == .Numbers {
                KPIOneView = .Graph
            }
        case .ChartTwo:
            typeOfChartTwoArray = array
        default:
            break
        }
        tableView.reloadData()
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
