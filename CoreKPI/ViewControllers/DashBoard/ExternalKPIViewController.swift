//
//  ExternalKPIViewController.swift
//  CoreKPI
//
//  Created by Семен on 05.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire

class ExternalKPIViewController: OAuthViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var oauthswift: OAuthSwift?
    
    weak var ChoseSuggestedVC: ChooseSuggestedKPITableViewController!
    var servive: IntegratedServices!
    var serviceKPI: [(SettingName: String, value: Bool)]!
    var tokenDelegate: UpdateExternalTokensDelegate!
    var settingDelegate: updateSettingsDelegate!
    let modelDidChangeNotification = Notification.Name(rawValue:"modelDidChange")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = servive.rawValue + " KPI"
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didTapedSaveButton(_ sender: UIBarButtonItem) {
        var kpiNotSelected = true
        for service in serviceKPI {
            if service.value == true {
                kpiNotSelected = false
            }
        }
        if !kpiNotSelected {
            doAuthService()
        } else {
            showAlert(title: "Sorry!", message: "First you should select one or more KPI")
        }
        
    }
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource methods
extension ExternalKPIViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceKPI.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = serviceKPI[indexPath.row].SettingName
        cell.accessoryType = serviceKPI[indexPath.row].value ? .checkmark : .none
        return cell
    }
    
}

//MARK: - UITableViewDelegate methods
extension ExternalKPIViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        serviceKPI[indexPath.row].value = !serviceKPI[indexPath.row].value
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension ExternalKPIViewController {
    
    // MARK: - do authentification
    func doAuthService() {
        
        switch servive! {
        case .SalesForce:
            doOAuthSalesforce()
        case .Quickbooks:
            doOAuthQuickbooks()
        case .HubSpotMarketing:
            doOAuthHubSpotMarketing()
        case .GoogleAnalytics:
            doOAuthGoogle()
        case .PayPal:
            doOAuthPayPal()
        case .HubSpotCRM:
            doOAuthHubSpotCRM()
        default:
            break
        }
    }
    
    //MARK: Salesforce
    func doOAuthSalesforce() {
        let request = ExternalRequest()
        request.oAuthAutorisation(servise: .SalesForce, viewController: self, success: { crededential in
            //TODO:
            print(crededential.oauthToken)
        }, failure: { error in
            self.showAlert(title: "Sorry!", message: error)
        }
        )
    }
    
    //MARK: QuickBooks
    func doOAuthQuickbooks() {
        
    }
    
    //MARK: HubSpotMarketing
    func doOAuthHubSpotMarketing() {
        
    }
    
    // MARK: Google
    func doOAuthGoogle(){
        let request = ExternalRequest()
        request.oAuthAutorisation(servise: .GoogleAnalytics, viewController: self, success: { credential in
            self.selectViewID(credential: credential)
        
        }, failure: { error in
            self.showAlert(title: "Sorry", message: error)
        }
        )
    }
    
    
    // MARK: PayPal
    func doOAuthPayPal(){
        let request = ExternalRequest()
        request.oAuthAutorisation(servise: .PayPal, viewController: self, success: { credential in
            self.ChoseSuggestedVC.integrated = self.servive
            self.settingDelegate = self.ChoseSuggestedVC
            self.settingDelegate.updateSettingsArray(array: self.serviceKPI)
            self.tokenDelegate = self.ChoseSuggestedVC
            self.tokenDelegate.updateTokens(oauthToken: credential.oauthToken, oauthRefreshToken: credential.oauthRefreshToken, oauthTokenExpiresAt: credential.oauthTokenExpiresAt!, viewID: nil)
            let stackVC = self.navigationController?.viewControllers
            _ = self.navigationController?.popToViewController((stackVC?[(stackVC?.count)! - 3])!, animated: true)
        }, failure: { error in
            self.showAlert(title: "Sorry", message: error)
        }
        )
    }
    
    // MARK: HubSpotCRM
    func doOAuthHubSpotCRM(){
    }
    
    //MARK: - get ViewID for google analytics
    func selectViewID(credential: OAuthSwiftCredential) {
        let request = GoogleAnalytics(oauthToken: credential.oauthToken, oauthRefreshToken: credential.oauthRefreshToken, oauthTokenExpiresAt: credential.oauthTokenExpiresAt!)
        request.getViewID(success: { viewIDArray in
            let alertVC = UIAlertController(title: "Select source", message: "Please!", preferredStyle: .actionSheet)
            for viewID in viewIDArray {
                alertVC.addAction(UIAlertAction(title: viewID.webSiteUri, style: .default, handler: { (UIAlertAction) in
                    self.saveGoogleAnalyticsData(credential: credential, viewID: viewID)
                }
                ))
            }
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }, failure: { error in
        self.showAlert(title: "Sorry", message: error)
        }
        )
    }
    
    //MARK: save google analytics data
    func saveGoogleAnalyticsData(credential: OAuthSwiftCredential, viewID: (viewID: String, webSiteUri: String)) {
        
        let oauthToken = credential.oauthToken
        let oauthRefreshToken = credential.oauthRefreshToken
        let oauthTokenExpiresAt = credential.oauthTokenExpiresAt
        ChoseSuggestedVC.integrated = servive
        settingDelegate = ChoseSuggestedVC
        settingDelegate.updateSettingsArray(array: serviceKPI)
        tokenDelegate = ChoseSuggestedVC
        tokenDelegate.updateTokens(oauthToken: oauthToken, oauthRefreshToken: oauthRefreshToken, oauthTokenExpiresAt: oauthTokenExpiresAt!, viewID: viewID.viewID)
        let stackVC = navigationController?.viewControllers
        _ = navigationController?.popToViewController((stackVC?[(stackVC?.count)! - 3])!, animated: true)
    }
    
}
