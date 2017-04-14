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
    var department: Departments {
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
                if department.SettingName == newValue.rawValue {
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
    var kpiName: String?
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
    var timeInterval: AlertTimeInterval {
        get {
            for interval in timeIntervalArray {
                if interval.value == true {
                    return AlertTimeInterval(rawValue: interval.SettingName)!
                }
            }
            return AlertTimeInterval.Daily
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
    var timeIntervalArray: [(SettingName: String, value: Bool)] = [(AlertTimeInterval.Daily.rawValue, true), (AlertTimeInterval.Weekly.rawValue, false), (AlertTimeInterval.Monthly.rawValue, false)]
    //WeeklyInterval
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
            var newWeeklyIntervalArray: [(SettingName: String, value: Bool)] = []
            for timeInterval in weeklyArray {
                if timeInterval.SettingName == newValue.rawValue {
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
                if timeInterval.SettingName == "\(newValue!)" {
                    newMountlyIntervalArray.append((timeInterval.SettingName, true))
                } else {
                    newMountlyIntervalArray.append((timeInterval.SettingName, false))
                }
            }
            mounthlyIntervalArray = newMountlyIntervalArray
        }
        
    }
    var mounthlyIntervalArray: [(SettingName: String, value: Bool)] = []
    //TimeZone
    var timeZone: String? {
        get {
            for timezone in timeZoneArray {
                if timezone.value == true {
                    return timezone.SettingName
                }
            }
            return nil
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
    var deadlineTime: Date!
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
    
    var datePickerIsVisible = false
    var dataPickerIsVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        switch buttonDidTaped {
        case .Report:
            self.navigationItem.rightBarButtonItem?.title = "Report"
            self.navigationItem.title = "Report KPI"
        case .Edit:
            self.navigationItem.rightBarButtonItem?.title = "Save"
            self.navigationItem.title = "KPI Edit"
            tableView.isScrollEnabled = true
            self.createExecutantArray()
            
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
    
    //MARK: - Check input values
    func checkInputValues() {
        if dataIsEntered() {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func dataIsEntered() -> Bool {

            if department == .none || kpiName == nil || executant == nil || (timeInterval == AlertTimeInterval.Weekly && weeklyInterval == WeeklyInterval.none) || (timeInterval == AlertTimeInterval.Monthly && mounthlyInterval == nil) || timeZone == nil || deadlineTime == nil {
                return false
            }

        return true
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
            //Delivery day
            switch timeInterval {
            case .Daily:
                break
            case .Weekly:
                switch (createdKPI?.deadlineDay)! {
                case 1:
                    weeklyInterval = .Monday
                case 2:
                    weeklyInterval = .Tuesday
                case 3:
                    weeklyInterval = .Wednesday
                case 4:
                    weeklyInterval = .Thursday
                case 5:
                    weeklyInterval = .Friday
                case 6:
                    weeklyInterval = .Saturday
                case 7:
                    weeklyInterval = .Sunday
                default:
                    break
                }
            case .Monthly:
                mounthlyInterval = (createdKPI?.deadlineDay)!
            }
            //Time Zone
            timeZone = (createdKPI?.timeZone)!
            //DeadlineTime
            deadlineTime = (createdKPI?.deadlineTime)!
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
        return numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows(section: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForIndexPath(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch buttonDidTaped {
        case .Report:
            return indexPath
        case .Edit:
            switch model.kpis[kpiIndex].typeOfKPI {
            case .IntegratedKPI:
                break //not editing
            case .createdKPI:
                switch typeOfAccount {
                case .Admin:
                    switch indexPath.section {
                    case 0,1,3:
                        return indexPath
                    case 2:
                        var newIndexPath = IndexPath()
                        switch timeInterval {
                        case .Daily:
                            switch indexPath.row {
                            case 3,4:
                                return indexPath
                            default:
                                newIndexPath = IndexPath(item: 4, section: 2)
                            }
                        case .Weekly, .Monthly:
                            if dataPickerIsVisible {
                                switch indexPath.row {
                                case 2,3:
                                    return indexPath
                                default:
                                    newIndexPath = IndexPath(item: 3, section: 2)
                                }
                            } else {
                                switch indexPath.row {
                                case 4,5:
                                    return indexPath
                                default:
                                    newIndexPath = IndexPath(item: 5, section: 2)
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
                            if indexPath.row > 2 {
                                newIndexPath = IndexPath(item: indexPath.row - 1, section: 2)
                                return newIndexPath
                            }
                        }
                    default:
                        break
                    }
                case .Manager:
                    return indexPath
                }
            }
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowAt(IndexPath: indexPath)
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
            destinatioVC.segueWithSelecting = true
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
            
        case 1, 2:
            return " "
        default:
            return nil
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
    
    private func ui(block: Bool) {
        
        var point = view.center
        point.y -= 80
        
        if block { addWaitingSpinner(at: point, color: OurColors.cyan) }
        else     { removeWaitingSpinner() }
        navigationItem.leftBarButtonItem?.isEnabled  = !block
        navigationItem.rightBarButtonItem?.isEnabled = !block
        tableView.isUserInteractionEnabled           = !block
    }
    
    @IBAction func tapRightBarButton(_ sender: UIBarButtonItem) {
                
        switch buttonDidTaped
        {
        case .Report:
            let request = AddReport(model: model)
            
            ui(block: true)
            request.addReportForKPI(withID: model.kpis[kpiIndex].id, report: report!, success: {
                self.ui(block: false)
                self.model.kpis[self.kpiIndex].createdKPI?.addReport(date: Date(), report: self.report!)
                self.prepareToMove()
            }, failure: { error in
                self.ui(block: false)
                print(error)
                self.showAlert(title: "Sorry",errorMessage: error)
            }
            )
        case .Edit:
            switch self.model.kpis[kpiIndex].typeOfKPI {
            case .createdKPI:
                switch model.profile!.typeOfAccount {
                case .Admin:
                    var deadlineDay = 0
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
                        default:
                            break
                        }
                    case .Monthly:
                        deadlineDay = mounthlyInterval!
                    }
                    let executantProfile: Int! = executant
                    //FIXME: WTF IS THIS
                    let newKpi = CreatedKPI(source: .User, department: self.department, KPI: self.kpiName!, descriptionOfKPI: self.kpiDescription, executant: executantProfile, timeInterval: self.timeInterval, deadlineDay: deadlineDay, timeZone: self.timeZone!, deadlineTime: self.deadlineTime, number: (self.model.kpis[kpiIndex].createdKPI?.number)!)
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
            })
        }        
    }
    
    func prepareToMove() {
        delegate = KPIListVC
        delegate.updateKPIList()
        _ = navigationController?.popViewController(animated: true)
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
        case .TimeZone:
            timeZoneArray = array
        case .KPIViewOne:
            KPIOneViewArray = array
            if KPIOneView == .Numbers && KPITwoView == .Numbers {
                KPITwoView = .Graph
            }
            chartDublicateDisabler(typeOfSetting: .KPIViewOne)
        case .ChartOne:
            typeOfChartOneArray = array
            chartDublicateDisabler(typeOfSetting: .ChartOne)
        case .KPIViewTwo:
            KPITwoViewArray = array
            if KPIOneView == .Numbers && KPITwoView == .Numbers {
                KPIOneView = .Graph
            }
            chartDublicateDisabler(typeOfSetting: .KPIViewTwo)
        case .ChartTwo:
            typeOfChartTwoArray = array
            chartDublicateDisabler(typeOfSetting: .ChartTwo)
        default:
            break
        }
        tableView.reloadData()
        checkInputValues()
    }
    
    private func chartDublicateDisabler(typeOfSetting: Setting) {
        switch typeOfSetting {
        case .KPIViewTwo, .ChartOne:
            if typeOfChartOne == typeOfChartTwo {
                for i in 0..<typeOfChartOneArray.count {
                    if typeOfChartOneArray[i].value == true {
                        if i != (typeOfChartOneArray.count - 1) {
                            typeOfChartTwo = TypeOfChart(rawValue: typeOfChartOneArray[i+1].SettingName)
                        } else {
                            typeOfChartTwo = .PieChart
                        }
                    }
                }
            }
        case .KPIViewOne, .ChartTwo:
            if typeOfChartOne == typeOfChartTwo {
                for i in 0..<typeOfChartTwoArray.count {
                    if typeOfChartTwoArray[i].value == true {
                        if i != (typeOfChartTwoArray.count - 1) {
                            typeOfChartOne = TypeOfChart(rawValue: typeOfChartTwoArray[i+1].SettingName)
                        } else {
                            typeOfChartOne = .PieChart
                        }
                    }
                }
            }
        default:
            break
        }
    }
    
    func updateDoubleValue(number: Double?) {
        report = number
        self.tableView.reloadData()
        
        if report != nil {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
}
//MARK: - UpdateTimeDelegate method
extension ReportAndViewKPITableViewController: UpdateTimeDelegate {
    func updateTime(newTime time: Date) {
        if datePickerIsVisible {
            deadlineTime = time
            var indexPath = IndexPath()
            switch timeInterval {
            case .Daily:
                indexPath = IndexPath(item: 3, section: 2)
            case .Weekly, .Monthly:
                indexPath = IndexPath(item: 4, section: 2)
            }
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        checkInputValues()
    }
}
