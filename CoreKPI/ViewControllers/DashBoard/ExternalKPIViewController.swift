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
    
    lazy var quickBookDataManager: QuickBookDataManager = {
        let datamanager = QuickBookDataManager()
        
        return datamanager
    }()
    
    lazy var internalWebViewController: WebViewController = {
        let controller = WebViewController()
        
        controller.delegate = self
        controller.view = UIView(frame: UIScreen.main.bounds)       
        controller.viewDidLoad()
        
        return controller
    }()    
    
    weak var ChoseSuggestedVC: ChooseSuggestedKPITableViewController!
    var selectedService: IntegratedServices!
    var serviceKPI: [(SettingName: String, value: Bool)]!
    var tokenDelegate: UpdateExternalTokensDelegate!
    var settingDelegate: updateSettingsDelegate!
    let modelDidChangeNotification = Notification.Name(rawValue:"modelDidChange")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = selectedService.rawValue + " KPI"
        tableView.tableFooterView = UIView(frame: .zero)
        quickBookDataManager = QuickBookDataManager()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didTapedSaveButton(_ sender: UIBarButtonItem) {
        var kpiNotSelected = true
        for service in serviceKPI {
            if service.value == true {
                
                if service.SettingName == "Balance"
                {
                    kpiNotSelected = false
                }
            }
        }
        if !kpiNotSelected {
            doAuthService()
        } else {
            showAlert(title: "Sorry!", message: "First you should select one or more KPI, or service not integrated yet")
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
        
        switch selectedService! {
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
        
        if internalWebViewController.parent == nil {
            self.addChildViewController(internalWebViewController)
        }
        
        let oauthswift = OAuth1Swift(
            consumerKey:    "qyprdLYMArOQwomSilhpS7v9Ge8kke",
            consumerSecret: "ogPRVftZXLA1A03QyWNyJBax1qOOphuVJVP121np",
            requestTokenUrl: "https://oauth.intuit.com/oauth/v1/get_request_token",
            authorizeUrl:    "https://appcenter.intuit.com/Connect/Begin",
            accessTokenUrl:  "https://oauth.intuit.com/oauth/v1/get_access_token"
        )
       
        self.oauthswift = oauthswift
        
        oauthswift.authorizeURLHandler = internalWebViewController
        
        let callbackUrlString = quickBookDataManager.serviceParameters[.callbackUrl]
        
        guard let callBackUrl = callbackUrlString else { print("DEBUG: Callback URL not found!"); return }
        
        let _ = oauthswift.authorize(
            withCallbackURL: callBackUrl,
            success: { credential, response, parameters in
                self.fetchDataFromIntuit(oauthswift)
                                        
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    func fetchDataFromIntuit(_ oauthswift: OAuth1Swift) {
        
        let queryParameters: [QBQueryParameterKeys: String] = [
            .dateMacro : QBPredifinedDateRange.thisMonth.rawValue
        ]
        
        let method = QBBalanceSheet(with: queryParameters)
        
        quickBookDataManager.queryMethod = method
        
        let fullUrlPath = quickBookDataManager.formUrlPath(method: method)
        
        let _ = oauthswift.client.get(
            fullUrlPath, headers: ["Accept":"application/json"],
            success: { response in
                
                let sum = self.quickBookDataManager.handle(response: response)
        },
            failure: { error in
                print(error)
        })
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
        //payPalTest()
        
        let oauthswift = OAuth2Swift(
            consumerKey: "AdA0F4asoYIoJoGK1Mat3i0apr1bdYeeRiZ6ktSgPrNmAMIQBO_TZtn_U80H7KwPdmd72CJhUTY5LYJH",
            consumerSecret: "",
            authorizeUrl: "https://www.sandbox.paypal.com/signin/authorize",
            responseType: "token")
        
        self.oauthswift = oauthswift
        oauthswift.allowMissingStateCheck = true
        oauthswift.accessTokenBasicAuthentification = true
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "https://appauth.demo-app.io:/oauth2redirect")!, scope: "profile+email+address+phone", state: "",
            success: { credential, response, parameters in
                print(credential.oauthToken)
                //self.selectViewID(credential: credential)
        },
            failure: { error in
                print("ERROR: \(error.localizedDescription)")
        })
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
        ChoseSuggestedVC.integrated = selectedService
        settingDelegate = ChoseSuggestedVC
        settingDelegate.updateSettingsArray(array: serviceKPI)
        tokenDelegate = ChoseSuggestedVC
        tokenDelegate.updateTokens(oauthToken: oauthToken, oauthRefreshToken: oauthRefreshToken, oauthTokenExpiresAt: oauthTokenExpiresAt!, viewID: viewID.viewID)
        let stackVC = navigationController?.viewControllers
        _ = navigationController?.popToViewController((stackVC?[(stackVC?.count)! - 3])!, animated: true)
    }
}

extension ExternalKPIViewController: OAuthWebViewControllerDelegate {
    
    func oauthWebViewControllerDidPresent() {
        
    }
    func oauthWebViewControllerDidDismiss() {
        
    }
    
    func oauthWebViewControllerWillAppear() {
        
    }
    func oauthWebViewControllerDidAppear() {
        
    }
    func oauthWebViewControllerWillDisappear() {
        
    }
    func oauthWebViewControllerDidDisappear() {
        // Ensure all listeners are removed if presented web view close
        oauthswift?.cancel()
    }
}
