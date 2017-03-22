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
import CoreData

class ExternalKPIViewController: OAuthViewController {
    
    @IBOutlet weak var tableView: UITableView!
           
    var quickBookDataManager: QuickBookDataManager {
        return QuickBookDataManager.shared()
    }
    
    var hubSpotManager: HubSpotManager {
        return HubSpotManager.sharedInstance
    }
    
    lazy var managedContext: NSManagedObjectContext = {
       
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    var selectedQBKPIs = [(SettingName: String, value: Bool)]()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = selectedService.rawValue + " KPI"
        tableView.tableFooterView = UIView(frame: .zero)        
    }
    
    @IBAction func didTapedSaveButton(_ sender: UIBarButtonItem) {
        
        var kpiNotSelected = true
        for service in serviceKPI {
            if service.value == true {
                kpiNotSelected = false
            }
        }
        if !kpiNotSelected {
            switch (selectedService)! {
            case .Quickbooks:
                selectedQBKPIs = serviceKPI.filter { $0.value == true }
                
            case .HubSpotCRM:
                if internalWebViewController.parent == nil {
                    self.addChildViewController(internalWebViewController)
                }
                
                hubSpotManager.webView = internalWebViewController
                hubSpotManager.connect()
            default:
                break
            }
            doAuthService()
        } else {
            showAlert(title: "Sorry!", errorMessage: "First you should select one or more KPI")
        }
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
            self.showAlert(title: "Sorry!", errorMessage: error)
        })
    }
    
    //MARK: QuickBooks
    func doOAuthQuickbooks() {
        quickBookDataManager.doOAuthQuickbooks {
            
            if let navigationController = self.navigationController
            {                
                navigationController.popToRootViewController(animated: true)
            }
            
            self.quickBookDataManager.formListOfRequests(from: self.selectedQBKPIs)
            self.quickBookDataManager.fetchDataFromIntuit(isCreation: true)           
        }
        
        if internalWebViewController.parent == nil {
            self.addChildViewController(internalWebViewController)
        }
        
        quickBookDataManager.oauthswift.authorizeURLHandler = internalWebViewController
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
            self.showAlert(title: "Sorry", errorMessage: error)
        })
    }
    
    // MARK: PayPal
    func doOAuthPayPal(){
        let payPalAuthVC = storyboard?.instantiateViewController(withIdentifier: .payPalAuthVC) as! PayPalAuthViewController
        payPalAuthVC.ChooseSuggestedKPIVC = ChoseSuggestedVC
        payPalAuthVC.serviceKPI = serviceKPI
        payPalAuthVC.selectedService = selectedService
        show(payPalAuthVC, sender: nil)
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
                }))
            }
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }, failure: { error in
        self.showAlert(title: "Sorry", errorMessage: error)
        })
    }
    
    //MARK: save google analytics data
    func saveGoogleAnalyticsData(credential: OAuthSwiftCredential, viewID: (viewID: String, webSiteUri: String)) {
        
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
        quickBookDataManager.oauthswift.cancel()
    }
}
