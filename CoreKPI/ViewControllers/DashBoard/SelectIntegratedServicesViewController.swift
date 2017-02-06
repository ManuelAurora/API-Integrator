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
        
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "ConfigureExternal") as! ExternalKPIViewController
        
        destinatioVC.ChoseSuggestedVC = chooseSuggestKPIVC
        
        switch sender {
        case saleforceButton:
            destinatioVC.serviceKPI = saleForceKPIArray
            destinatioVC.servive = .SalesForce
        case quickbooksButton:
            destinatioVC.serviceKPI = quickBooksKPIArray
            destinatioVC.servive = .Quickbooks
        case googleAnalyticsButton:
            destinatioVC.serviceKPI = googleAnalyticsKPIArray
            destinatioVC.servive = .GoogleAnalytics
        case hubSpotCRMButton:
            destinatioVC.serviceKPI = hubSpotCRMKPIArray
            destinatioVC.servive = .HubSpotCRM
        case payPalButton:
            destinatioVC.serviceKPI = payPalKPIArray
            destinatioVC.servive = .PayPal
        case hubSpotButton:
            destinatioVC.serviceKPI = hubSpotMarketingKPIArray
            destinatioVC.servive = .HubSpotMarketing
        default:
            break
        }
        navigationController?.pushViewController(destinatioVC, animated: true)
    }

}
