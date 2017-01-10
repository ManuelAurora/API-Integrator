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

class ReportAndViewKPITableViewController: UITableViewController, updateSettingsArrayDelegate {
    
    var kpi: KPI!
    var dictionary: [String : Int] = [:]
    var buttonDidTaped = ButtonDidTaped.Report
    
    var report: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch buttonDidTaped {
        case .Edit:
            tableView.estimatedRowHeight = 44.0
            tableView.rowHeight = UITableViewAutomaticDimension
        default:
            dictionary = (kpi.createdKPI?.number)!
        }
        
        
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
            return 2
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
            //return (kpi.createdKPI?.number.count)! + 1
//        case .View:
//            switch section {
//            case 0:
//                return 5
//            case 1:
//                return 1
//            default:
//                return 0
//            }
        case .Edit:
            switch section {
            case 0:
                return 4
            default:
                return 2
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
                    cell.headerOfCell.text = kpi.createdKPI?.descriptionOfKPI
                case 1:
                    cell.headerOfCell.text = kpi.createdKPI?.department
                case 2:
                    cell.headerOfCell.text = kpi.createdKPI?.timeInterval
                case 3:
                    cell.headerOfCell.text = kpi.createdKPI?.timeZone
                case 4:
                    cell.headerOfCell.text = kpi.createdKPI?.deadline
                default:
                    break
                }
            case 1:
                cell.selectionStyle = .default
                cell.headerOfCell.text = "My Report"
                cell.descriptionOfCell.text = report ?? "Add report"
                cell.accessoryType = .disclosureIndicator
            default:
                break
            }
//            cell.selectionStyle = .none
//            switch indexPath.row {
//            case 0:
//                cell.headerOfCell.text = "Days"
//                cell.descriptionOfCell.text = "Data"
//            default:
//                let first = dictionary.popFirst()
//                cell.headerOfCell.text = first?.key
//                cell.descriptionOfCell.text = "\((first?.value)!)"
//            }
//        case .View:
//            switch indexPath.section {
//            case 0:
//                cell.selectionStyle = .none
//                cell.descriptionOfCell.text = ""
//                switch indexPath.row {
//                case 0:
//                    cell.headerOfCell.text = kpi.createdKPI?.descriptionOfKPI
//                case 1:
//                    cell.headerOfCell.text = kpi.createdKPI?.department
//                case 2:
//                    cell.headerOfCell.text = kpi.createdKPI?.timeInterval
//                case 3:
//                    cell.headerOfCell.text = kpi.createdKPI?.timeZone
//                case 4:
//                    cell.headerOfCell.text = kpi.createdKPI?.deadline
//                default:
//                    break
//                }
//            case 1:
//                cell.selectionStyle = .default
//                cell.headerOfCell.text = "My Report"
//                cell.descriptionOfCell.text = report ?? "Add report"
//                cell.accessoryType = .disclosureIndicator
//            default:
//                break
//            }
        case .Edit:
            switch indexPath.section {
            case 0:
                 cell.selectionStyle = .none
                cell.descriptionOfCell.text = ""
                switch indexPath.row {
                case 0:
                    cell.headerOfCell.text = kpi.createdKPI?.department
                case 1:
                    cell.headerOfCell.text = kpi.createdKPI?.timeInterval
                case 2:
                    cell.headerOfCell.text = kpi.createdKPI?.timeZone
                case 3:
                    cell.headerOfCell.text = kpi.createdKPI?.deadline
                default:
                    break
                }
            case 1:
                cell.selectionStyle = .default
                cell.accessoryType = .disclosureIndicator
                switch indexPath.row {
                case 0:
                    cell.headerOfCell.text = "KPI’s 2nd view"
                    cell.descriptionOfCell.text = "Graph" //debug
                case 1:
                    cell.headerOfCell.text = "Graph type"
                    cell.descriptionOfCell.text = "Piechart" //debug
                default:
                    break
                }
            default:
                break
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return kpi.createdKPI?.KPI
        default:
            return " "
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 13)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch buttonDidTaped {
        case .Report:
            switch indexPath.section {
            case 1:
                let destinationVC = storyboard?.instantiateViewController(withIdentifier: "AddReport") as! AddReportTableViewController
                navigationController?.pushViewController(destinationVC, animated: true)
            default:
                break
            }
        case .Edit:
            print("Coming soon")
        }
   
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    func updateStringValue(string: String?) {
        self.report = string
    }
    func updateSettingsArray(array: [(SettingName: String, value: Bool)]) {
    }
    
}
