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

class ReportAndViewKPITableViewController: UITableViewController, updateSettingsDelegate {
    
    var kpiIndex: Int!
    var kpiArray: [KPI] = []
    var buttonDidTaped = ButtonDidTaped.Report
    weak var KPIListVC: KPIsListTableViewController!
    var delegate: updateKPIListDelegate!
    
    var report: Int?
    
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
            return 3
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
            switch section {
            case 0:
                return 4
            case 1:
                return 0
            case 2:
                return 0
            default:
                return 0
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
                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.department
                case 2:
                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.timeInterval
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
                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.department
                case 1:
                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.timeInterval
                case 2:
                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.timeZone
                case 3:
                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.deadline
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
            return kpiArray[kpiIndex].createdKPI?.KPI
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
                //destinationVC.KPIListVC = self.KPIListVC
                //                destinationVC.kpiArray = self.kpiArray
                //                destinationVC.kpiIndex = self.kpiIndex
                destinationVC.report = self.report
                destinationVC.ReportAndViewVC = self
                navigationController?.pushViewController(destinationVC, animated: true)
            default:
                break
            }
        case .Edit:
            print("Coming soon")
        }
        
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
    }
    func updateSettingsArray(array: [(SettingName: String, value: Bool)]) {
    }
    func updateIntValue(number: Int?) {
        self.report = number
        self.tableView.reloadData()
        if report != nil {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
}
