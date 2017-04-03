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
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
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
    var selectedHSKPIs = [(SettingName: String, value: Bool)]()
    
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
    var tokenDelegate: UpdateExternalKPICredentialsDelegate!
    var settingDelegate: updateSettingsDelegate!
    let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = selectedService.rawValue + " KPI"
        tableView.tableFooterView = UIView(frame: .zero)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setHidesBackButton(false, animated: true)
        doneButton.isEnabled = true
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
                
                selectedHSKPIs         = serviceKPI.filter { $0.value == true }
                hubSpotManager.webView = internalWebViewController
                hubSpotManager.connect()                
                
                selectedHSKPIs.forEach {
                    if let type = HubSpotCRMKPIs(rawValue: $0.SettingName)
                    {
                        hubSpotManager.createNewEntity(type: type)
                    }
                }
                
            default:
                break
            }
            
            doneButton.isEnabled = false
            navigationItem.setHidesBackButton(true, animated: true)
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
        request.oAuthAutorisation(servise: .SalesForce, viewController: self, success: { saleForceKPI in
            self.saveOauth2Data(googleAnalyticsObject: nil, payPalObject: nil, salesForceObject: saleForceKPI.salesForceObject)
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
        request.oAuthAutorisation(servise: .GoogleAnalytics, viewController: self, success: { objects in
            self.selectViewID(googleKPI: objects.googleAnalyticsObject!)
        
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
    func selectViewID(googleKPI: GoogleKPI) {
        let request = GoogleAnalytics(oauthToken: googleKPI.oAuthToken!, oauthRefreshToken: googleKPI.oAuthRefreshToken!, oauthTokenExpiresAt: googleKPI.oAuthTokenExpiresAt! as Date)
        request.getViewID(success: { viewIDArray in
            let alertVC = UIAlertController(title: "Select source", message: "Please!", preferredStyle: .actionSheet)
            for viewID in viewIDArray {
                alertVC.addAction(UIAlertAction(title: viewID.webSiteUri, style: .default, handler: { (UIAlertAction) in
                    //let googleKPI = GoogleKPI(context: self.context)
                    //googleKPI.oAuthToken = credential.oauthToken
                    //googleKPI.oAuthRefreshToken = credential.oauthRefreshToken
                    //googleKPI.oAuthTokenExpiresAt = credential.oauthTokenExpiresAt as NSDate?
                    googleKPI.viewID = viewID.viewID
                    googleKPI.siteURL = viewID.webSiteUri
                    self.saveOauth2Data(googleAnalyticsObject: googleKPI, payPalObject: nil, salesForceObject: nil)
                }))
            }
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }, failure: { error in
        self.showAlert(title: "Sorry", errorMessage: error)
        })
    }
    
    //MARK: save Oauth2.0 credentials data
    func saveOauth2Data(googleAnalyticsObject: GoogleKPI?, payPalObject: PayPalKPI?, salesForceObject: SalesForceKPI?) {
    
        ChoseSuggestedVC.integrated = selectedService
        settingDelegate = ChoseSuggestedVC
        settingDelegate.updateSettingsArray(array: serviceKPI)
        tokenDelegate = ChoseSuggestedVC
        tokenDelegate.updateCredentials(googleAnalyticsObject: googleAnalyticsObject, payPalObject: payPalObject, salesForceObject: salesForceObject)
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
