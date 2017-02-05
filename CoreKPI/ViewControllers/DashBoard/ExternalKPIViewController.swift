//
//  ExternalKPIViewController.swift
//  CoreKPI
//
//  Created by Семен on 05.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit
import OAuthSwift

class ExternalKPIViewController: OAuthViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var oauthswift: OAuthSwift?
    
    weak var ChoseSuggestedVC: ChooseSuggestedKPITableViewController!
    var servive: IntegratedServices!
    var serviceKPI: [(SettingName: String, value: Bool)]!
    var delegate: updateSettingsDelegate!
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
            withCallbackURL: URL(string: "com.smichrissoft.mobile.android.corekpi:/oauth2callback")!, scope: "full", state: state,
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
        

        
        // For googgle the redirect_uri should match your this syntax: your.bundle.id:/oauth2Callback
        self.oauthswift = oauthswift
        oauthswift.allowMissingStateCheck = true
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift) //"urn:ietf:wg:oauth:2.0:oob"
        // in plist define a url schem with: your.bundle.id:
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "CoreKPI.CoreKPI:/oauth2Callback")!, scope: "https://www.googleapis.com/auth/analytics.readonly", state: "",
            success: { credential, response, parameters in
                self.showAlert(title: "Google", message: credential.oauthToken)
                //let parameters =  Dictionary<String, AnyObject>()
                // Multi-part upload
                let _ = oauthswift.client.post("", success: { response in
                    let jsonDict = try? response.jsonObject()
                    print("SUCCESS: \(jsonDict)")
                }, failure: { error in
                    print(error)
                })
//                let _ = oauthswift.client.postImage(
//                    "https://www.googleapis.com/upload/drive/v2/files", parameters: parameters, image:  UIImagePNGRepresentation(#imageLiteral(resourceName: "SaleForce"))!,
//                    success: { response in
//                        let jsonDict = try? response.jsonObject()
//                        print("SUCCESS: \(jsonDict)")
//                },
//                    failure: { error in
//                        print(error)
//                }
//                )
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
}
