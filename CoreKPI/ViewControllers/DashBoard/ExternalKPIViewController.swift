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
    
    private var cancelTap: UITapGestureRecognizer? {
        didSet {
            guard let tap = cancelTap else { return }
            view.addGestureRecognizer(tap)
        }
    }
    
    var quickBookDataManager: QuickBookDataManager {
        return QuickBookDataManager.shared()
    }
    
    var hubSpotManager: HubSpotManager {
        return HubSpotManager.sharedInstance
    }
    
    let sfManager = SalesforceRequestManager.shared
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
    var selectedService: IntegratedServices = .none
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
            switch (selectedService) {
            case .Quickbooks:
                selectedQBKPIs = serviceKPI.filter { $0.value == true }
                ui(block: true, useSpinner: false)
                
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
                    if let crmKpi = HubSpotCRMKPIs(rawValue: $0.SettingName)
                    {
                        return hubSpotManager.choosenCrmKpis.append(crmKpi)
                    }
                    if let markKpi = HubSpotMarketingKPIs(rawValue: $0.SettingName)
                    {
                        return hubSpotManager.choosenMarketKpis.append(markKpi)
                    }
                }

            default: break
            }
            doAuthService()
            
        } else {
            showAlert(title: "Error Occured!",
                      errorMessage: "You should select at least one KPI.")
        }
    }
    
    @objc fileprivate func cancelSelector() {
        
        removeAllAlamofireNetworking()
        ui(block: false, useSpinner: true)
    }
    
    fileprivate func ui(block: Bool, useSpinner: Bool = false) {
        
        if block
        {
            cancelTap = UITapGestureRecognizer(target: self, action: #selector(cancelSelector))
        }
        else
        {
            cancelTap = nil
        }
        
        if block
        {
            view.layoutIfNeeded()
            let center = view.center
            if useSpinner { addWaitingSpinner(at: center, color: OurColors.cyan) }
        }
        else if useSpinner { removeWaitingSpinner() }
        
        tableView.isUserInteractionEnabled = false
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
        
        let salesFunnel = HubSpotCRMKPIs.SalesFunnel.rawValue
        let dealStageFunnel = HubSpotCRMKPIs.DealStageFunnel.rawValue
        
        guard (selectedHSKPIs.filter { $0.SettingName == salesFunnel }).count > 0 ||
            (selectedHSKPIs.filter { $0.SettingName == dealStageFunnel}).count > 0
            else {
                hubSpotManager.addRequest.addKPI(success: { result in
                    print("Added new Internal KPI on server")
                    self.navigationController?.popToRootViewController(animated: true)
                    NotificationCenter.default.post(name: .addedNewExtKpiOnServer,
                                                    object: nil)
                }, failure: { error in
                    print(error)
                })
                
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
        
        switch selectedService {
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
            self.showAlert(title: "Error Occured!", errorMessage: error)
        })
    }
    
    //MARK: QuickBooks
    func doOAuthQuickbooks() {
        
        quickBookDataManager.doOAuthQuickbooks {
            if let navigationController = self.navigationController
            {                
                navigationController.popToRootViewController(animated: true)
            }
                    
            let externalKPI = ExternalKPI()
            let addRequest = AddKPI()
            let qbEntities = self.quickBookDataManager.quickbooksKPIManagedObjects
            var kpiIDs = [Int]()
                
            self.selectedQBKPIs.forEach { kpi in
                if let qbkpi = QiuckBooksKPIs(rawValue: kpi.SettingName)
                {
                    let idForKpi = self.quickBookDataManager.getIdFor(kpi: qbkpi)
                    kpiIDs.append(idForKpi)
                }
            }
            
            externalKPI.kpiName = "SemenKPI"
            externalKPI.quickbooksKPI = qbEntities?.filter({
                $0.realmId == self.quickBookDataManager.serviceParameters[.companyId]
            }).first
            externalKPI.serviceName = IntegratedServices.Quickbooks.rawValue
            addRequest.type = IntegratedServicesServerID.quickbooks.rawValue
            
            let semenKPI = KPI(kpiID: -2,
                               typeOfKPI: .IntegratedKPI,
                               integratedKPI: externalKPI,
                               createdKPI: nil,
                               imageBacgroundColour: nil)
                        
            addRequest.kpiIDs = kpiIDs
            addRequest.kpi = semenKPI
            addRequest.addKPI(success: { result in
                print("Added new Internal KPI on server")
                NotificationCenter.default.post(name: .addedNewExtKpiOnServer,
                                                object: nil)
            }, failure: { error in
                print(error)
            })            
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
            self.showAlert(title: "Error Occured", errorMessage: error)
        })
    }
    
    // MARK: PayPal
    func doOAuthPayPal(){
        let payPalAuthVC = storyboard?.instantiateViewController(withIdentifier: .payPalAuthVC) as! PayPalAuthViewController
        payPalAuthVC.extVC = self 
        payPalAuthVC.serviceKPI = serviceKPI
        payPalAuthVC.selectedService = selectedService
        show(payPalAuthVC, sender: nil)
    }
    
    // MARK: HubSpotCRM
    func doOAuthHubSpotCRM(){
    }
    
    //MARK: - get ViewID for google analytics
    func selectViewID(googleKPI: GACredentialsInfo) {
        ui(block: true, useSpinner: true)
        var googleKPI = googleKPI
        let request = GAnalytics(oauthToken: googleKPI.token!,
                                 oauthRefreshToken: googleKPI.refreshToken!,
                                 oauthTokenExpiresAt: googleKPI.expiresAt! as Date)
        
        request.getViewID(success: { viewIDArray in
            self.ui(block: false, useSpinner: true)
            let alertVC = UIAlertController(title: "Select source", message: "Please!", preferredStyle: .actionSheet)
            for viewID in viewIDArray {
                alertVC.addAction(UIAlertAction(title: viewID.webSiteUri, style: .default, handler: { (UIAlertAction) in
                    self.ui(block: true, useSpinner: true)
                    googleKPI.viewID = viewID.viewID
                    googleKPI.siteURL = viewID.webSiteUri
                    self.saveOauth2Data(googleAnalyticsObject: googleKPI, payPalObject: nil, salesForceObject: nil)
                }))
            }
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }, failure: { error in
            self.ui(block: false, useSpinner: true)
            self.showAlert(title: "Error Occured", errorMessage: error)
        })
    }
    
    //MARK: save Oauth2.0 credentials data
    func saveOauth2Data(googleAnalyticsObject: GACredentialsInfo?, payPalObject: PayPalKPI?, salesForceObject: SalesForceKPI?) {
        
        let idsForServer = getIdsForSelectedKpis(selectedService)
        let source = googleAnalyticsObject?.siteURL
        
        checkIsTtlValid(idsForServer, selectedService, source: source) {
            self.ui(block: false, useSpinner: true)
            self.addOnServerSelectedKpis(idsForServer,
                                         service: self.selectedService,
                                         source: googleAnalyticsObject)
            
           self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func getIdsForSelectedKpis(_ service: IntegratedServices) -> [Int] {
        
        var idsForServer = [Int]()
        
        switch service
        {
        case .SalesForce:
            serviceKPI.forEach { kpi in
                guard kpi.value else { return }
                
                if let sfKpi = SalesForceKPIs(rawValue: kpi.SettingName)
                {
                    let id =  sfManager.getServerIdFor(kpi: sfKpi)
                    idsForServer.append(id)
                }
            }
            
        case .GoogleAnalytics:
            serviceKPI.forEach { kpi in
                guard kpi.value else { return }
                
                if let gaKpi = GoogleAnalyticsKPIs(rawValue: kpi.SettingName)
                {
                    let id =  GAnalytics.getServerIdFor(kpi: gaKpi)
                    idsForServer.append(id)
                }
            }
            
        case .PayPal:
            serviceKPI.forEach { kpi in
                guard kpi.value else { return }
                
                if let payKpi = PayPalKPIs(rawValue: kpi.SettingName)
                {
                    let id =  PayPal.getServerIdFor(kpi: payKpi)
                    idsForServer.append(id)
                }
            }
            
        default: break
        }
        
        return idsForServer
    }
    
    private func addOnServerSelectedKpis(_ ids: [Int],
                                         service: IntegratedServices,
                                         source: GACredentialsInfo? = nil) {
        
        let externalKPI = ExternalKPI(context: context)
        let addKpi      = AddKPI()
        
        addKpi.kpiIDs = ids
        externalKPI.kpiName = "SemenKPI"
        
        switch service
        {
        case .GoogleAnalytics:
            let gaEntity = GAnalytics.googleAnalyticsEntity(for: source?.siteURL)
            
            gaEntity.oAuthToken        = source?.token
            gaEntity.oAuthRefreshToken = source?.refreshToken
            gaEntity.siteURL           = source?.siteURL
            gaEntity.viewID            = source?.viewID
            
            if let date = source?.expiresAt as NSDate?
            {
                gaEntity.oAuthTokenExpiresAt = date
            }
            
            externalKPI.googleAnalyticsKPI = gaEntity
            externalKPI.serviceName = IntegratedServices.GoogleAnalytics.rawValue
            addKpi.type = IntegratedServicesServerID.googleAnalytics.rawValue
                        
        case .SalesForce:
            let sfEntity  = sfManager.fetchSalesForceKPIEntity()
            
            externalKPI.saleForceKPI = sfEntity!
            externalKPI.serviceName = IntegratedServices.SalesForce.rawValue
            addKpi.type = IntegratedServicesServerID.salesforceCRM.rawValue
            
        case .PayPal:
            let payEntity = PayPal.payPalEntity            
            externalKPI.payPalKPI = payEntity
            externalKPI.serviceName = IntegratedServices.PayPal.rawValue
            addKpi.type = IntegratedServicesServerID.paypal.rawValue
            
        default: break
        }
        
        let semenKPI = KPI(kpiID: -1, typeOfKPI: .IntegratedKPI,
                           integratedKPI: externalKPI,
                           createdKPI: nil,
                           imageBacgroundColour: nil)
        
        addKpi.kpi = semenKPI
        addKpi.addKPI(success: { ids in
            self.ui(block: false, useSpinner: true)
            print("DEBUG: KPIS ADDED ON SERV")
            NotificationCenter.default.post(name: .addedNewExtKpiOnServer, object: nil)
        }, failure: { error in
            self.ui(block: false, useSpinner: true)
            print(error)
        })
        
    }
    
    private func checkIsTtlValid(_ kpis: [Int], _: IntegratedServices,
                                 source: String?,
                                 completion: @escaping ()->())  {
       
        switch selectedService
        {
        case .GoogleAnalytics:
            let entity = GAnalytics.googleAnalyticsEntity(for: source)
            
            if let expDate = entity.oAuthTokenExpiresAt
            {
                let ttl = AddKPI.getSecondsFrom(date: expDate)
                
                if ttl < 0
                {
                    let ga = IntegratedServices.GoogleAnalytics
                    
                    ga.updateTokenFor(kpiID: kpis[0], gaEntity: entity) {
                        completion()
                    }
                }
                else
                {
                    completion()
                }
            }
            else { completion() }
            
            
        default: completion(); break
        }
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
            if let crmKpi = HubSpotCRMKPIs(rawValue: kpi.SettingName)
            {
                let kpiId = hubSpotManager.getCRMIdFor(kpi: crmKpi)
                
                if !hubSpotManager.addRequest.kpiIDs.contains(kpiId)
                {
                    hubSpotManager.addRequest.kpiIDs.append(kpiId)
                }
            }
        }
        
        pipelines.forEach { pipe in
            hubSpotManager.addRequest.pipelineIds.append(pipe.pipelineId)
        }
                
        hubSpotManager.addRequest.addKPI(success: { result in
            print("Added new Internal KPI on server")
            self.navigationController?.popToRootViewController(animated: true)
            NotificationCenter.default.post(name: .addedNewExtKpiOnServer,
                                            object: nil)
        }, failure: { error in
            print(error)
        })
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
