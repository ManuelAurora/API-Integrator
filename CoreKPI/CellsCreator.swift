//
//  CellsCreator.swift
//  CoreKPI
//
//  Created by Семен on 31.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

extension ReportAndViewKPITableViewController {
    
    
    //MARK: - Number of Sections
    func numberOfSections() -> Int {
        switch buttonDidTaped {
        case .Report:
            return 2
        case .Edit:
            switch model.kpis[kpiIndex].typeOfKPI {
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
    
    //MARK: - Number of rows in section
    func numberOfRows(section: Int) -> Int {
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
            switch model.kpis[kpiIndex].typeOfKPI {
            case .IntegratedKPI:
                break
            case .createdKPI:
                switch (model.profile?.typeOfAccount)! {
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
        return 0
    }
    
    //MARK: - Cell for indexPath
    func cellForIndexPath(indexPath: IndexPath) -> UITableViewCell {
        
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
                    dateFormatter.timeStyle = .short
                    let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadlineTime)!)
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
            //Add!
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
                                    dateFormatter.timeStyle = .short
                                    let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadlineTime)!)
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
                                    dateFormatter.timeStyle = .short
                                    let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadlineTime)!)
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
                                    dateFormatter.timeStyle = .short
                                    let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadlineTime)!)
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
                                    dateFormatter.timeStyle = .short
                                    let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadlineTime)!)
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
                                    dateFormatter.timeStyle = .short
                                    let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadlineTime)!)
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
                                    dateFormatter.timeStyle = .short
                                    let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadlineTime)!)
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
                                dateFormatter.timeStyle = .short
                                let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadlineTime)!)
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
                                dateFormatter.timeStyle = .short
                                let date = dateFormatter.string(from: (model.kpis[kpiIndex].createdKPI?.deadlineTime)!)
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
    
    func didSelectRowAt(IndexPath indexPath: IndexPath) {
        
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
    
}
