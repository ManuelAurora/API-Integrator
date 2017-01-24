//
//  SelectIntegratedServicesViewController.swift
//  CoreKPI
//
//  Created by Семен Осипов on 07.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class SelectIntegratedServicesViewController: UIViewController {

    @IBOutlet weak var saleforceButton: UIButton!
    @IBOutlet weak var quickbooksButton: UIButton!
    @IBOutlet weak var googleAnalyticsButton: UIButton!
    @IBOutlet weak var hubSpotCRMButton: UIButton!
    @IBOutlet weak var payPalButton: UIButton!
    @IBOutlet weak var hubSpotButton: UIButton!
    
    weak var chooseSuggestKPIVC: ChooseSuggestedKPITableViewController!
    
    var saleForceKPIArray: [(SettingName: String, value: Bool)] = []
    var quickBooksKPIArray: [(SettingName: String, value: Bool)] = []
    var googleAnalyticsKPIArray: [(SettingName: String, value: Bool)] = []
    var hubSpotCRMKPIArray: [(SettingName: String, value: Bool)] = []
    var payPalKPIArray: [(SettingName: String, value: Bool)] = []
    var hubSpotMarketingKPIArray: [(SettingName: String, value: Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonDidTaped(_ sender: UIButton) {
        
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "SelectSettingForKPI") as! KPISelectSettingTableViewController
        destinatioVC.ChoseSuggestedVC = chooseSuggestKPIVC
        destinatioVC.selectSeveralEnable = true
        
        switch sender {
        case saleforceButton:
            destinatioVC.selectSetting = saleForceKPIArray
            destinatioVC.integratedService = .SalesForce
        case quickbooksButton:
            destinatioVC.selectSetting = quickBooksKPIArray
            destinatioVC.integratedService = .Quickbooks
        case googleAnalyticsButton:
            destinatioVC.selectSetting = googleAnalyticsKPIArray
            destinatioVC.integratedService = .GoogleAnalytics
        case hubSpotCRMButton:
            destinatioVC.selectSetting = hubSpotCRMKPIArray
            destinatioVC.integratedService = .HubSpotCRM
        case payPalButton:
            destinatioVC.selectSetting = payPalKPIArray
            destinatioVC.integratedService = .PayPal
        case hubSpotButton:
            destinatioVC.selectSetting = hubSpotMarketingKPIArray
            destinatioVC.integratedService = .HubSpotMarketing
        default:
            break
        }
        navigationController?.pushViewController(destinatioVC, animated: true)
    }

}
