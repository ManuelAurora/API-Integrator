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

class ReportAndViewKPITableViewController: UITableViewController, updateSettingsDelegate {
    
    var model: ModelCoreKPI!
    weak var KPIListVC: KPIsListTableViewController!
    var delegate: updateKPIListDelegate!
    
    var kpiIndex: Int!
    var kpiArray: [KPI] = []
    var buttonDidTaped = ButtonDidTaped.Report
    
    // report property
    var report: Double?
    
    // edit property
    var typeOfAccount: TypeOfAccount {
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
            return TypeOfAccount.Admin
        } else {
            return TypeOfAccount.Manager
        }
    }
    
    var colour: Colour {
        get {
            for colour in colourArray {
                if colour.value == true {
                    return Colour(rawValue: colour.SettingName)!
                }
            }
            return Colour.none
        }
    }
    var colourArray: [(SettingName: String, value: Bool)] = [(Colour.Pink.rawValue, false), (Colour.Green.rawValue, false), (Colour.Blue.rawValue, false)]
    var colourDictionary: [Colour : UIColor] = [
        Colour.Pink : UIColor(red: 251/255, green: 233/255, blue: 231/255, alpha: 1),
        Colour.Green : UIColor(red: 200/255, green: 247/255, blue: 197/255, alpha: 1),
        Colour.Blue : UIColor(red: 227/255, green: 242/255, blue: 253/255, alpha: 1)
    ]
    
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
            
        }
        tableView.autoresizesSubviews = true
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                        let interval = kpiArray[kpiIndex].createdKPI?.timeInterval
                        switch interval! {
                        case .Daily:
                            return 6 //+2 type of graphics
                        default:
                            return 7 //+2 type of graphics
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
                        return 2 //+2 type of graphics
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
                let createdKPI = self.kpiArray[kpiIndex].createdKPI
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
                            cell.headerOfCell.text = createdKPI?.KPI
                        case 1:
                            cell.headerOfCell.text = createdKPI?.descriptionOfKPI ?? "No description"
                            cell.headerOfCell.numberOfLines = 0
                            if createdKPI?.descriptionOfKPI == nil {
                                cell.headerOfCell.textColor = UIColor.lightGray
                            }
                        case 2:
                            cell.headerOfCell.text = (createdKPI?.department.rawValue)! + " Department"
                        default:
                            break
                        }
                    case 2:
                        switch (createdKPI?.timeInterval)! {
                        case .Daily:
                            switch indexPath.row {
                            case 0:
                                cell.headerOfCell.text = "Executant"
                                cell.descriptionOfCell.text = (createdKPI?.executant.firstName)! + " " + (createdKPI?.executant.lastName)!
                            case 1:
                                cell.headerOfCell.text = "Time interval"
                                cell.descriptionOfCell.text = createdKPI?.timeInterval.rawValue
                            case 2:
                                cell.headerOfCell.text = "Time zone"
                                cell.descriptionOfCell.text = createdKPI?.timeZone
                            case 3:
                                cell.headerOfCell.text = "Deadline"
                                cell.descriptionOfCell.text = createdKPI?.deadline
                                cell.accessoryType = .none
                            case 4:
                                cell.headerOfCell.text = "KPI's 1 st view"
                                cell.descriptionOfCell.text = "Numbers"
                            case 5:
                                cell.headerOfCell.text = "KPI's 2 st view"
                                cell.descriptionOfCell.text = "Graph"
                            default:
                                break
                            }
                        default:
                            break
                        }
                    default:
                        break
                    }
                case .Manager: break
//                    switch section {
//                    case 0:
//                        let interval = kpiArray[kpiIndex].createdKPI?.timeInterval
//                        switch interval! {
//                        case .Daily:
//                            return 4
//                        default:
//                            return 5
//                        }
//                    case 1:
//                        return 2 //+2 type of graphics
//                    default:
//                        return 0
//                    }
                }
            }
            
            
            
//            switch indexPath.section {
//            case 0:
//                cell.selectionStyle = .none
//                cell.descriptionOfCell.text = ""
//                switch indexPath.row {
//                case 0:
//                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.department.rawValue
//                case 1:
//                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.timeInterval.rawValue
//                case 2:
//                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.timeZone
//                case 3:
//                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.deadline
//                default:
//                    break
//                }
//            case 1:
//                cell.selectionStyle = .default
//                cell.accessoryType = .disclosureIndicator
//                switch indexPath.row {
//                case 0:
//                    cell.headerOfCell.text = "KPI’s 2nd view"
//                    cell.descriptionOfCell.text = "Graph" //debug
//                case 1:
//                    cell.headerOfCell.text = "Graph type"
//                    cell.descriptionOfCell.text = "Piechart" //debug
//                default:
//                    break
//                }
//            default:
//                break
//            }
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
                        default:
                            break
                        }
//                    case 2:
//                        let interval = kpiArray[kpiIndex].createdKPI?.timeInterval
//                        switch interval! {
//                        case .Daily:
//                            return 6 //+2 type of graphics
//                        default:
//                            return 7 //+2 type of graphics
//                        }
                    default:
                        break
                    }
                case .Manager: break
//                    switch section {
//                    case 0:
//                        let interval = kpiArray[kpiIndex].createdKPI?.timeInterval
//                        switch interval! {
//                        case .Daily:
//                            return 4
//                        default:
//                            return 5
//                        }
//                    case 1:
//                        return 2 //+2 type of graphics
//                    default:
//                        return 0
//                    }
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
        switch buttonDidTaped {
        case .Report:
            var newKpi = kpiArray[kpiIndex].createdKPI
            newKpi?.addReport(report: self.report!)
            self.kpiArray[kpiIndex].createdKPI = newKpi
            delegate = self.KPIListVC
            delegate.updateKPIList(kpiArray: self.kpiArray)
            _ = navigationController?.popViewController(animated: true)
        case .Edit:
            break
        }
    }
    
    //MARK: - updateSettingsArrayDelegate methods
    func updateStringValue(string: String?) {
        var createdKPI = self.kpiArray[kpiIndex].createdKPI
        switch typeOfSetting {
        case .KPIname:
            if string != nil {
                createdKPI?.KPI = string!
            }
        case .KPInote:
                createdKPI?.descriptionOfKPI = string
        default:
            return
        }
        self.kpiArray[kpiIndex].createdKPI = createdKPI
        tableView.reloadData()
    }
    func updateSettingsArray(array: [(SettingName: String, value: Bool)]) {
        switch typeOfSetting {
        case .Colour:
            self.colourArray = array
            self.kpiArray[kpiIndex].imageBacgroundColour = self.colourDictionary[self.colour]
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
