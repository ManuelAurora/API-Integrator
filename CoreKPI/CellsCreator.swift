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
                    return 4
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
                            return datePickerIsVisible ? 5 : 4
                        case .Weekly, .Monthly:
                            if dataPickerIsVisible {
                                return datePickerIsVisible ? 7 : 6
                            } else {
                                return datePickerIsVisible ? 6 : 5
                            }
                        }
                    case 3:
                        return 2
                        
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
        cell.rightConstraint.constant = 1.0
        
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
            case .IntegratedKPI:
                break //Integrated KPI not editing!
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
                            var description = "No Description"
                            
                            if let descr = kpiDescription, descr != "", descr != " "
                            {
                                description = descr
                            }
                            else
                            {
                                cell.headerOfCell.textColor = UIColor.lightGray
                            }
                            
                            cell.headerOfCell.text = description
                            cell.headerOfCell.numberOfLines = 0
                          
                        case 2:
                            cell.headerOfCell.text = department.rawValue + " Department"
                        default:
                            break
                        }
                    case 2:
                        switch timeInterval {
                        case .Daily:
                            switch indexPath.row {
                            case 0:
                                cell.headerOfCell.text = "Executant"
                                cell.descriptionOfCell.text = getExecutantName(userID: executant)
                            case 1:
                                cell.headerOfCell.text = "Time interval"
                                cell.descriptionOfCell.text = timeInterval.rawValue
                            case 2:
                                cell.headerOfCell.text = "Time zone"
                                cell.descriptionOfCell.text = timeZone ?? "HUI"
                                
                            case 3:
                                cell.headerOfCell.text = "Deadline"
                                let dateFormatter = DateFormatter()
                                dateFormatter.timeStyle = .short
                                let date = dateFormatter.string(from: (deadlineTime))
                                cell.descriptionOfCell.text = date
                                cell.accessoryType = .none
                                cell.rightConstraint.constant = 16.0
                            case 4:
                                let datePickerCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerTableViewCell
                                datePickerCell.datePicker.setDate(deadlineTime, animated: false)
                                datePickerCell.editKPIVC = self
                                return datePickerCell
                            default:
                                break
                            }
                        case .Weekly, .Monthly:
                            
                            if dataPickerIsVisible {
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
                                        if mounthlyInterval != nil {
                                            if mounthlyInterval! > 28 {
                                                cell.descriptionOfCell.text = "\(mounthlyInterval!) or last day"
                                            } else {
                                                cell.descriptionOfCell.text = "\(mounthlyInterval!)"
                                            }
                                            
                                        } else {
                                            cell.descriptionOfCell.text = "Add day"
                                        }
                                    case .Weekly:
                                        cell.descriptionOfCell.text = weeklyInterval != .none ? weeklyInterval.rawValue : "Add day"
                                    default:
                                        break
                                    }
                                case 3:
                                    let dataPickerCell = tableView.dequeueReusableCell(withIdentifier: "DataPickerCell", for: indexPath)  as! DataPickerTableViewCell
                                    dataPickerCell.dataPicker.reloadAllComponents()
                                    dataPickerCell.dataPicker.selectRow(0, inComponent: 0, animated: false)
                                    switch timeInterval {
                                    case .Daily:
                                        break
                                    case .Weekly:
                                        if weeklyInterval == .none {
                                            dataPickerCell.dataPicker.selectRow(0, inComponent: 0, animated: false)
                                        } else {
                                            for (index, day) in weeklyArray.enumerated() {
                                                if day.SettingName == weeklyInterval.rawValue {
                                                    dataPickerCell.dataPicker.selectRow(index, inComponent: 0, animated: false)
                                                }
                                            }
                                        }
                                    case .Monthly:
                                        if mounthlyInterval == nil {
                                            dataPickerCell.dataPicker.selectRow(0, inComponent: 0, animated: false)
                                        } else {
                                            for (index, day) in mounthlyIntervalArray.enumerated() {
                                                if Int(day.SettingName) == mounthlyInterval {
                                                    dataPickerCell.dataPicker.selectRow(index, inComponent: 0, animated: false)
                                                }
                                            }
                                        }
                                    }
                                    dataPickerCell.dataPicker.selectedRow(inComponent: 0)
                                    return dataPickerCell
                                case 4:
                                    cell.headerOfCell.text = "Time zone"
                                    cell.descriptionOfCell.text = timeZone ?? " "
                                case 5:
                                    cell.headerOfCell.text = "Deadline"
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.timeStyle = .short
                                    let date = dateFormatter.string(from: (deadlineTime))
                                    cell.descriptionOfCell.text = date
                                    cell.accessoryType = .none
                                    cell.rightConstraint.constant = 16.0
                                case 6:
                                    let datePickerCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerTableViewCell
                                    datePickerCell.editKPIVC = self
                                    datePickerCell.datePicker.setDate(deadlineTime, animated: false)
                                    return datePickerCell
                                default:
                                    break
                                }
                            } else {
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
                                        cell.descriptionOfCell.text = weeklyInterval != .none ? weeklyInterval.rawValue : "Add day"
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
                                    let date = dateFormatter.string(from: (deadlineTime))
                                    cell.descriptionOfCell.text = date
                                    cell.accessoryType = .none
                                    cell.rightConstraint.constant = 16.0
                                case 5:
                                    let datePickerCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerTableViewCell
                                    datePickerCell.editKPIVC = self
                                    datePickerCell.datePicker.setDate(deadlineTime, animated: false)
                                    return datePickerCell
                                default:
                                    break
                                }
                            }
                        }
                    case 3:
                        
                        let chartOne = typeOfChartOne?.rawValue
                        let chartTwo = typeOfChartTwo?.rawValue
                        var descr = ""
                        
                        switch indexPath.row {
                        case 0:
                            if KPIOneView == .Numbers
                            {
                                descr = "Table"
                            }
                            else if KPIOneView == .Graph
                            {
                                descr = typeOfChartOne?.rawValue ?? ""
                            }
                            
                            if chartOne == chartTwo
                            {
                                typeOfChartTwo = nil
                                KPITwoView = nil
                            }                            
                            
                            cell.headerOfCell.text = "KPI's 1 st view"
                            cell.descriptionOfCell.text = descr
                            
                        case 1:
                            if KPITwoView == .Numbers
                            {
                                descr = "Table"
                            }
                            else if KPITwoView == .Graph
                            {
                                descr = typeOfChartTwo?.rawValue ?? ""
                            }                            

                            if chartOne == chartTwo
                            {
                                typeOfChartOne = typeOfChartTwo
                                KPIOneView     = KPITwoView
                                typeOfChartTwo = nil
                                KPITwoView     = nil
                            }
                            cell.headerOfCell.text = "KPI's 2 st view"
                            cell.descriptionOfCell.text = descr
                            
                        default:
                            break
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
                                cell.headerOfCell.text = department.rawValue + " Department"
                            case 1:
                                cell.headerOfCell.text = timeInterval.rawValue
                            case 2:
                                if timeZone != nil {
                                    cell.headerOfCell.text = "Time zone: " + timeZone!
                                } else {
                                    cell.headerOfCell.text = "Time zone: " + "Error timeZone"
                                }
                                
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
                            
                            if isInteractive
                            {
                                cell.accessoryType = .disclosureIndicator
                            }
                            else
                            {
                                cell.accessoryType = .none
                            }
                            
                            if KPIOneView == .Numbers && KPITwoView == .Graph {
                                switch indexPath.row {
                                case 0:
                                    cell.headerOfCell.text = "KPI's 1 st view"
                                    cell.descriptionOfCell.text = KPIOneView?.rawValue
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
                                    cell.descriptionOfCell.text = KPIOneView?.rawValue
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
                                    cell.descriptionOfCell.text = KPIOneView?.rawValue
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
                        break
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
                                tableView.deselectRow(at: indexPath, animated: true)
                                showDatePicker(row: indexPath.row)
                            default:
                                break
                            }
                        case .Weekly, .Monthly:
                            if dataPickerIsVisible {
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
                                    tableView.deselectRow(at: indexPath, animated: true)
                                    showDataPicker(row: indexPath.row)
                                case 4:
                                    typeOfSetting = .TimeZone
                                    settingArray = timeZoneArray
                                    showSelectSettingVC()
                                case 5:
                                    tableView.deselectRow(at: indexPath, animated: true)
                                    showDatePicker(row: indexPath.row)
                                default:
                                    break
                                }
                            } else {
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
                                    tableView.deselectRow(at: indexPath, animated: true)
                                    showDataPicker(row: indexPath.row)
                                case 3:
                                    typeOfSetting = .TimeZone
                                    settingArray = timeZoneArray
                                    showSelectSettingVC()
                                case 4:
                                    tableView.deselectRow(at: indexPath, animated: true)
                                    showDatePicker(row: indexPath.row)
                                default:
                                    break
                                }
                            }
                        }
                    case 3:
                        switch indexPath.row
                        {
                        case 0:
                            typeOfSetting = .KPIViewOne
                            settingArray = typeOfVisualizationArray
                            showSelectSettingVC()
                            
                        case 1:
                            typeOfSetting = .KPIViewTwo
                            settingArray = typeOfVisualizationArray
                            showSelectSettingVC()
                            
                        default:
                            break
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
    
    //MARK: - Date Picker
    func showDatePicker(row: Int) {
        datePickerIsVisible = !datePickerIsVisible
        
        let indexPath = IndexPath(item: row + 1, section: 2)
        
        if datePickerIsVisible {
            tableView.insertRows(at: [indexPath], with: .top)
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        } else {
            tableView.deleteRows(at: [indexPath], with: .top)
            if deadlineTime == nil {
                deadlineTime = Date()
                tableView.reloadRows(at: [IndexPath(item: row, section: 2)], with: .none)
            }
        }
    }
    
    //MARK: - UIPickerView
    func showDataPicker(row: Int) {
        dataPickerIsVisible = !dataPickerIsVisible
        let indexPath = IndexPath(item: row + 1, section: 2)
        if dataPickerIsVisible {
            tableView.insertRows(at: [indexPath], with: .top)
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        } else {
            switch timeInterval {
            case .Daily:
                break
            case .Weekly:
                if weeklyInterval == WeeklyInterval.none {
                    weeklyInterval = WeeklyInterval.Monday
                }
            case .Monthly:
                if mounthlyInterval == nil {
                    mounthlyInterval = 1
                }
            }
            checkInputValues()
            tableView.deleteRows(at: [indexPath], with: .top)
            tableView.reloadRows(at: [IndexPath(item: row, section: 2)], with: .none)
        }
    }
}

//MARK: - UIPickerViewDataSource and UIPickerViewDelegate methods
extension ReportAndViewKPITableViewController: UIPickerViewDataSource,UIPickerViewDelegate {
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
        let indexPath = IndexPath(item: 2, section: 2)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
