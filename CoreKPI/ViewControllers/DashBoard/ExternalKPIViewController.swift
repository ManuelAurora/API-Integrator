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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var managedContext: NSManagedObjectContext = {
       
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    var selectedQBKPIs = [(SettingName: String, value: Bool)]()
    var selectedHSKPIs = [(SettingName: String, value: Bool)]()
    
    lazy var internalWebViewController: WebViewController = {
        let controller = WebViewController()
        weak var weakSelf = self
        controller.delegate = weakSelf
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("DEBUG: ExternalKPIVC Deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToNotifications()
        providesPresentationContextTransitionStyle = true
        definesPresentationContext = true
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
                
            case .HubSpotCRM, .HubSpotMarketing:
                if internalWebViewController.parent == nil
                {
                    self.addChildViewController(internalWebViewController)
                }
                
                let urlStr = hubSpotManager.makeUrlPathForAuthentication()
                let url    = URL(string: urlStr)!
                
                internalWebViewController.handle(url)
                
                selectedHSKPIs = serviceKPI.filter { $0.value == true }
                
                selectedHSKPIs.forEach {
                    if $0.SettingName != HubSpotCRMKPIs.SalesFunnel.rawValue &&
                        $0.SettingName != HubSpotCRMKPIs.DealStageFunnel.rawValue
                    {
                        hubSpotManager.createNewEntityFor(service: selectedService,
                                                          kpiName: $0.SettingName)
                    }
                }
                
            default: break
            }
            doAuthService()
            
        } else {
            showAlert(title: "Sorry!", errorMessage: "First you should select one or more KPI")
        }
    }
    
    private func ui(block: Bool) {
        
        if block
        {
            view.layoutIfNeeded()
            let center = view.center
            addWaitingSpinner(at: center, color: OurColors.cyan)
        }
        else     { removeWaitingSpinner() }
        
        doneButton.isEnabled = !block
        navigationItem.setHidesBackButton(block, animated: true)
        tableView.isUserInteractionEnabled = !block
    }
    
    private var connected = false
    
    private func subscribeToNotifications() {
        
        weak var weakSelf = self
        let nc = NotificationCenter.default
        
        nc.addObserver(weakSelf!,
                       selector: #selector(weakSelf?.choosePipelines),
                       name: .hubspotManagerRecievedData,
                       object: nil)
        
        nc.addObserver(forName: .hubspotTokenRecieved,
                       object: nil, queue: nil) { _ in
                        //guard self.connected == false else { return }
                        weakSelf?.hubSpotManager.connect()
                        weakSelf?.connected = true
        }
    }
    
    @objc private func choosePipelines() {
        
        ui(block: false)
        let salesFunnel = HubSpotCRMKPIs.SalesFunnel.rawValue
        let dealStageFunnel = HubSpotCRMKPIs.DealStageFunnel.rawValue
        guard (selectedHSKPIs.filter { $0.SettingName == salesFunnel }).count > 0 ||
              (selectedHSKPIs.filter { $0.SettingName == dealStageFunnel}).count > 0
            else {
                navigationController?.popToRootViewController(animated: true)
                return
        }
        
        let pipelineVC = storyboard?.instantiateViewController(withIdentifier: .choosePipelineVC) as! HubspotChoosePipelineViewController
        
        pipelineVC.pipelines = hubSpotManager.pipelinesArray
        pipelineVC.delegate  = self
        
        navigationController?.pushViewController(pipelineVC, animated: true)
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

extension ExternalKPIViewController: HubspotSalesFunnelMakerProtocol
{
    func formChoosen(pipelines: [HSPipeline]) {
        
        let choosenKPI = serviceKPI.filter {
            ($0.SettingName == HubSpotCRMKPIs.SalesFunnel.rawValue && $0.value == true) ||
            ($0.SettingName == HubSpotCRMKPIs.DealStageFunnel.rawValue && $0.value == true)
        }
        
        choosenKPI.forEach { kpi in
            pipelines.forEach { pipe in
                
                hubSpotManager.createNewEntityFor(service: selectedService,
                                                  kpiName: kpi.SettingName,
                                                  pipelineID: pipe.pipelineId)
            }
        }
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
        internalWebViewController.delegate = nil
        hubSpotManager.oauthSwift.cancel()
        quickBookDataManager.oauthswift.cancel()
    }
}
