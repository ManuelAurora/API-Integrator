//
//  ChooseSuggestedKPITableViewController.swift
//  CoreKPI
//
//  Created by Семен on 27.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class ChooseSuggestedKPITableViewController: UITableViewController, updateSettingsArrayDelegate {
    
    var model: ModelCoreKPI!
    var KPIListVC: KPIsListTableViewController!
    
    enum TypeOfSetting: String {
        case none
        case Source
        case Service
        case Departament
        case KPI
        case Executant
        case TimeInterval = "Time interval"
        case TimeZone = "Time zone"
        case Deadline
    }
    
    var delegate: updateKPIListDelegate!
    
    var source = Source.none
    var sourceArray: [(SettingName: String, value: Bool)] = [(Source.User.rawValue, false), (Source.Integrated.rawValue, false)]
    
    //MARK: - integarted services
    var integrated = IntegratedServices.none
    var saleForceKPIs: [SalesForceKPIs] = []
    var saleForceKPIArray: [(SettingName: String, value: Bool)] = [(SalesForceKPIs.RevenueNewLeads.rawValue, false), (SalesForceKPIs.KeyMetrics.rawValue, false), (SalesForceKPIs.ConvertedLeads.rawValue, false), (SalesForceKPIs.OpenOpportunitiesByStage.rawValue, false), (SalesForceKPIs.TopSalesRep.rawValue, false), (SalesForceKPIs.NewLeadsByIndustry.rawValue, false), (SalesForceKPIs.CampaignROI.rawValue, false)]
    var quickBooksKPIs: [QiuckBooksKPIs] = []
    var quickBooksKPIArray: [(SettingName: String, value: Bool)] = [(QiuckBooksKPIs.Test.rawValue, true)]
    var googleAnalyticsKPIs: [GoogleAnalyticsKPIs] = []
    var googleAnalyticsKPIArray: [(SettingName: String, value: Bool)] = [(GoogleAnalyticsKPIs.Test.rawValue, true)]
    var hubspotCRMKPIs: [HubSpotCRMKPIs] = []
    var hubSpotCRMKPIArray: [(SettingName: String, value: Bool)] = [(HubSpotCRMKPIs.Test.rawValue, true)]
    var paypalKPIs: [PayPalKPIs] = []
    var payPalKPIArray: [(SettingName: String, value: Bool)] = [(PayPalKPIs.Test.rawValue, true)]
    var hubspotMarketingKPIs: [HubSpotMarketingKPIs] = []
    var hubSpotMarketingKPIArray: [(SettingName: String, value: Bool)] = [(HubSpotMarketingKPIs.Test.rawValue, true)]
    
    //MARK: User's KPI
    
    
    var typeOfSetting = TypeOfSetting.none
    var settingArray: [(SettingName: String, value: Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            switch source {
            case .none:
                return 1
            case .User:
                return 7
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
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch indexPath.section {
        case 0:
            let SuggestedCell = tableView.dequeueReusableCell(withIdentifier: "SuggestedKPICell", for: indexPath) as! DashboardSetingTableViewCell
            switch source {
            case .none:
                SuggestedCell.headerOfCell.text = "Source"
                SuggestedCell.descriptionOfCell.text = source.rawValue
            case .User:
                switch indexPath.row {
                case 0:
                    SuggestedCell.headerOfCell.text = "Source"
                    SuggestedCell.descriptionOfCell.text = source.rawValue
                case 1:
                    SuggestedCell.headerOfCell.text = "Department"
                    SuggestedCell.descriptionOfCell.text = "IT"
                case 2:
                    SuggestedCell.headerOfCell.text = "KPI"
                    SuggestedCell.descriptionOfCell.text = "Chose KPI"
                case 3:
                    SuggestedCell.headerOfCell.text = "Executant"
                    SuggestedCell.descriptionOfCell.text = "Alan Been"
                case 4:
                    SuggestedCell.headerOfCell.text = "Time Interval"
                    SuggestedCell.descriptionOfCell.text = source.rawValue
                case 5:
                    SuggestedCell.headerOfCell.text = "Time Zone"
                    SuggestedCell.descriptionOfCell.text = "Default"
                case 6:
                    SuggestedCell.headerOfCell.text = "Deadline"
                    SuggestedCell.descriptionOfCell.text = "12:15AM"
                default:
                    break
                }
            case .Integrated:
                switch indexPath.row {
                case 0:
                    SuggestedCell.headerOfCell.text = "Source"
                    SuggestedCell.descriptionOfCell.text = source.rawValue
                case 1:
                    SuggestedCell.headerOfCell.text = "Service"
                    SuggestedCell.descriptionOfCell.text = integrated.rawValue
                default:
                    SuggestedCell.headerOfCell.text = "KPI \(indexPath.row - 1)"
                    SuggestedCell.accessoryType = .none
                    SuggestedCell.selectionStyle = .none
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
            
            return SuggestedCell
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "SaveButtonCell", for: indexPath)
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "CreateButtonCell", for: indexPath)
        default:
            cell = UITableViewCell()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch source {
            case .none:
                self.typeOfSetting = .Source
                self.settingArray = self.sourceArray
                showSelectSettingVC()
            case .User:
                switch indexPath.row {
                case 0:
                    self.typeOfSetting = .Source
                    self.settingArray = self.sourceArray
                    showSelectSettingVC()
                default:
                    break
                }
            case .Integrated:
                switch indexPath.row {
                case 0:
                    self.typeOfSetting = .Source
                    self.settingArray = self.sourceArray
                    showSelectSettingVC()
                case 1:
                    self.typeOfSetting = .Service
                    self.showIntegratedServicesVC()
                default:
                    break
                }
            }
        case 1:
            self.tapSaveButton()
        case 2:
            let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "CreateNewKPI") as! CreateNewKPITableViewController
            navigationController?.pushViewController(destinatioVC, animated: true)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return " "
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 13)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    func tapSaveButton() {
        if source == .none || (source == .Integrated && integrated == .none)/* || (add for user)*/ {
        let alertController = UIAlertController(title: "Error", message: "One ore more parameters are not selected", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        var kpi: KPI!
        
        switch source {
        case .Integrated:
            
            let imageForKPIList: ImageForKPIList
            
            switch self.integrated {
            case .SalesForce:
                imageForKPIList = ImageForKPIList.SaleForce
            case .Quickbooks:
                imageForKPIList = ImageForKPIList.QuickBooks
            case .GoogleAnalytics:
                imageForKPIList = ImageForKPIList.GoogleAnalytics
            case .HubSpotCRM:
                imageForKPIList = ImageForKPIList.HubSpotCRM
            case .PayPal:
                imageForKPIList = ImageForKPIList.PayPal
            case .HubSpotMarketing:
                imageForKPIList = ImageForKPIList.HubSpotMarketing
            default:
                imageForKPIList = ImageForKPIList.Decreases
            }
            
            let integratedKPI = IntegratedKPI(service: self.integrated, saleForceKPIs: saleForceKPIs, quickBookKPIs: quickBooksKPIs, googleAnalytics: googleAnalyticsKPIs, hubSpotCRMKPIs: hubspotCRMKPIs, payPalKPIs: paypalKPIs, hubSpotMarketingKPIs: hubspotMarketingKPIs)
            kpi = KPI(typeOfKPI: .IntegratedKPI, integratedKPI: integratedKPI, createdKPI: nil, image: imageForKPIList )
        default:
            break
        }
        
        self.delegate = self.KPIListVC
        delegate.addNewKPI(kpi: kpi)
        
        let KPIListVC = self.navigationController?.viewControllers[0] as! KPIsListTableViewController
        _ = self.navigationController?.popToViewController(KPIListVC, animated: true)
    }
    
    //MARK: - Show KPISelectSettingTableViewController method
    func showSelectSettingVC() {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "SelectSettingForKPI") as! KPISelectSettingTableViewController
        destinatioVC.ChoseSuggestedVC = self
        destinatioVC.selectSetting = settingArray
        switch typeOfSetting {
        default:
            break
        }
        destinatioVC.navigationItem.rightBarButtonItem = nil
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
    //MARK: - Show SelectIntegratedServicesViewController method
    func showIntegratedServicesVC() {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "SelectIntegratedServices") as! SelectIntegratedServicesViewController
        destinatioVC.chooseSuggestKPIVC = self
        
        destinatioVC.saleForceKPIArray = self.saleForceKPIArray
        destinatioVC.quickBooksKPIArray = self.quickBooksKPIArray
        destinatioVC.googleAnalyticsKPIArray = self.googleAnalyticsKPIArray
        destinatioVC.hubSpotCRMKPIArray = self.hubSpotCRMKPIArray
        destinatioVC.payPalKPIArray = self.payPalKPIArray
        destinatioVC.hubSpotMarketingKPIArray = self.hubSpotMarketingKPIArray
        
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
    //MARK: - updateSettingArrayDelegate methods
    func updateSettingsArray(array: [(SettingName: String, value: Bool)]) {
        switch typeOfSetting {
        case .Source:
            self.sourceArray = array
            for source in array {
                if source.value == true {
                    self.source = Source(rawValue: source.SettingName)!
                }
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
        default:
            return
        }
        
        tableView.reloadData()
        self.typeOfSetting = .none
        self.settingArray.removeAll()
    }
    
    func updateStringValue(string: String?) {
        switch typeOfSetting {
        default:
            print(string ?? "optional")
        }
    }
}
