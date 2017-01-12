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
    
    var model: ModelCoreKPI!
    weak var KPIListVC: KPIsListTableViewController!
    var delegate: updateKPIListDelegate!
    
    var kpiIndex: Int!
    var kpiArray: [KPI] = []
    var buttonDidTaped = ButtonDidTaped.Report
    
    var typeOfAccount: TypeOfAccount {
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
            return TypeOfAccount.Admin
        } else {
            return TypeOfAccount.Manager
        }
    }
    
    var report: Double?
    
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
            switch indexPath.section {
            case 0:
                cell.selectionStyle = .none
                cell.descriptionOfCell.text = ""
                switch indexPath.row {
                case 0:
                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.department.rawValue
                case 1:
                    cell.headerOfCell.text = kpiArray[kpiIndex].createdKPI?.timeInterval.rawValue
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
