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
        let oauthswift = OAuth2Swift(
            consumerKey:    "3MVG9HxRZv05HarSOV2Bh.pnwumGqpwVny5raeBxpjMwIQCVzeb7HmzJvGTOxEm6N3S2Q7LFo48KvA.0DrKYt",
            consumerSecret: "2273564242408453432",
            authorizeUrl:   "https://login.salesforce.com/services/oauth2/authorize",
            accessTokenUrl: "https://login.salesforce.com/services/oauth2/token",
            responseType:   "code"
        )
        self.oauthswift = oauthswift
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
        let state = generateState(withLength: 20)
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "CoreKPI.CoreKPI:/oauth2Callback")!, scope: "full", state: state,
            success: { credential, response, parameters in
                self.showAlert(title: "saleForce", message: credential.oauthToken)
        },
            failure: { error in
                print(error.description)
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
        let oauthswift = OAuth2Swift(
            consumerKey:    "988266735713-9ruvi1tjo1bk6gckjuiqnncuq6otn0ko.apps.googleusercontent.com",
            consumerSecret: "",
            authorizeUrl:   "https://accounts.google.com/o/oauth2/v2/auth",
            accessTokenUrl: "https://accounts.google.com/o/oauth2/token",
            responseType:   "code"
        )
        self.oauthswift = oauthswift
        oauthswift.allowMissingStateCheck = true
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift) // magic redirect - "urn:ietf:wg:oauth:2.0:oob"
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "CoreKPI.CoreKPI:/oauth2Callback")!, scope: "https://www.googleapis.com/auth/analytics.readonly", state: "123",
            success: { credential, response, parameters in
                self.selectViewID(credential: credential)
        },
            failure: { error in
                print("ERROR: \(error.localizedDescription)")
        }
        )
    }
    
    
    // MARK: PayPal
    func doOAuthPayPal(){
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
                    self.saveData(credential: credential, viewID: viewID)
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
    
    func saveData(credential: OAuthSwiftCredential, viewID: (viewID: String, webSiteUri: String)) {
        
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
