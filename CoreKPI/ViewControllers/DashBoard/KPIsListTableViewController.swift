//
//  KPIsListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 23.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import CoreData
//MARK: - Enums for setting

class KPIsListTableViewController: UITableViewController
{    
    var model: ModelCoreKPI!
    var arrayOfKPI: [KPI] = []
    var isFilteredForUser = false 
    let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
    let nc = NotificationCenter.default
    var rightBarButton: UIBarButtonItem!
    let stateMachine = UserStateMachine.shared
    
    @IBAction func showSelectServicesScreen() {
        
        let servStoryboard = UIStoryboard(name: "Services", bundle: nil)
        let identifier = "ServiceSelectionCollectionViewController"
        let controller = servStoryboard.instantiateViewController(withIdentifier: identifier) as! ServiceSelectionCollectionViewController
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightBarButton = navigationItem.rightBarButtonItem
        
        if stateMachine.isAdmin {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        let attrs = [NSForegroundColorAttributeName : OurColors.cyan]
        let nc = NotificationCenter.default
        nc.addObserver(forName: .newExternalKPIadded,
                       object: nil,
                       queue: nil,
                       using: catchNotification)
        
        nc.addObserver(forName: .addedNewExtKpiOnServer, object: nil, queue: nil) {
            notification in
            
            self.removeAllKpis()
        }
       
        self.navigationController?.navigationBar.titleTextAttributes = attrs
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = OurColors.gray
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let firstLoad = UserDefaults.standard.data(forKey: "firstLoad"),
            let _ = NSKeyedUnarchiver.unarchiveObject(with: firstLoad) as? Bool {
        } else {
            let onboardingVC = storyboard?.instantiateViewController(
                withIdentifier: .onboardPageVC) as! OnboardingPageViewController
            present(onboardingVC, animated: true, completion: nil)
            saveData()
        }
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshControl?.addTarget(self,
                                  action: #selector(self.refresh),
                                  for: UIControlEvents.valueChanged)
        refreshControl?.backgroundColor = UIColor.clear
        
        if !isFilteredForUser
        {
            navigationItem.rightBarButtonItem = rightBarButton
        }
        
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    //MARK: - Save mark about first loading
    func saveData() {
        
        let data: Bool = true
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
        UserDefaults.standard.set(encodedData, forKey: "firstLoad")
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfKPI.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let kpiToDelete = arrayOfKPI[indexPath.row]
        
        if stateMachine.isAdmin || kpiToDelete.integratedKPI != nil
        {
            return true
        }
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "KPIListCell", for: indexPath) as! KPIListTableViewCell
        let kpi = arrayOfKPI[indexPath.row]
        cell.KPIListVC  = self
        cell.editButton.tag = indexPath.row
        cell.reportButton.tag = indexPath.row
        cell.memberNameButton.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row
        cell.showOptionsValue(for: kpi)
        
        if let imageString = arrayOfKPI[indexPath.row].image {
            cell.KPIListCellImageView.isHidden = false
            cell.KPIListCellImageView.image = UIImage(named: imageString.rawValue)
        } else {
            cell.KPIListCellImageView.isHidden = true
        }
        
        cell.KPIListCellImageBacgroundView.backgroundColor = arrayOfKPI[indexPath.row].imageBacgroundColour
        
        hideButtonsOnKPICard(cell: cell, kpi: arrayOfKPI[indexPath.row])
        
        switch kpi.typeOfKPI {
        case .IntegratedKPI:
            
            cell.KPIListNumber.isHidden = true
            cell.reportButton.isHidden = true
            cell.ManagedByStack.isHidden = true
            let integratedKPI = arrayOfKPI[indexPath.row].integratedKPI
            cell.KPIListHeaderLabel.text = integratedKPI?.kpiName
            
        case .createdKPI:
            let createdKPI = arrayOfKPI[indexPath.row].createdKPI
            cell.KPIListHeaderLabel.text = createdKPI?.KPI
            
            if let kpi = createdKPI, kpi.number.count > 0
            {
                let val = kpi.number[0].number as NSNumber
                let formatter: NumberFormatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 10
                let formatedStr: String = formatter.string(from: val) ?? ""
                cell.KPIListNumber.text = formatedStr
            }
            else { cell.KPIListNumber.text = "" }
            
            if createdKPI?.executant == model.profile?.userId {
                cell.memberNameButton.setTitle( "Me" , for: .normal )
            } else {
                for profile in model.team {
                    if Int(profile.userID) == createdKPI?.executant {
                        let title = (profile.firstName)! + " " + (profile.lastName)!
                        cell.memberNameButton.setTitle(title, for: .normal)
                        return cell
                    }
                }
                cell.memberNameButton.setTitle("error member", for: .normal)
            }
        }
        return cell
    }
       
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        
        let selectedKpi =  arrayOfKPI[indexPath.row]
        
        if selectedKpi.createdKPI != nil
        {
            loadReportsFor(kpi: selectedKpi)
        }
        
        let destinationVC = storyboard?.instantiateViewController(withIdentifier:
            .chartsViewController) as! ChartsPageViewController
        
        destinationVC.kpi = arrayOfKPI[indexPath.row]
        navigationController?.pushViewController(destinationVC, animated: true)
    }
        
    override func tableView(_ tableView: UITableView,
                            editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction =  UITableViewRowAction(
            style: .default,
            title: "Delete",
            handler: {
                (action, indexPath) -> Void in
                let kpiToDelete = self.arrayOfKPI[indexPath.row]
                
                if kpiToDelete.typeOfKPI == .IntegratedKPI
                {
                    let id = Int(kpiToDelete.integratedKPI.serverID)
                    
                    DeleteIntegratedKPI().deleteKPI(kpiID: id , success: {
                        print("DEBUG: SUCCESSFULLY DELETED")
                        self.context.delete(self.arrayOfKPI[indexPath.row].integratedKPI)
                        (UIApplication.shared .delegate as! AppDelegate).saveContext()
                        self.arrayOfKPI.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }, failure: { (error) in
                        print(error)
                    })
                }
                else
                {
                    self.deleteKPI(kpiID: self.model.kpis[indexPath.row].id)
                    self.model.kpis.remove(at: indexPath.row)
                    self.arrayOfKPI.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
        })
        
        return [deleteAction]        
    }
    
    //MARK: show/hide buttons on KPI cards
    private func hideButtonsOnKPICard(cell: KPIListTableViewCell, kpi: KPI) {
        
        switch kpi.typeOfKPI
        {
        case .createdKPI:
            cell.reportButton.isHidden   = stateMachine.isAdmin && !isThisKpiByMe(kpi)
            cell.editButton.isHidden     = !stateMachine.isAdmin || isFilteredForUser
            cell.KPIListNumber.isHidden  = false
            cell.ManagedByStack.isHidden = false
            
        case .IntegratedKPI:
            cell.reportButton.isHidden = true
            cell.editButton.isHidden = true
            cell.KPIListNumber.isHidden = true
            cell.ManagedByStack.isHidden = true
        }
    }
    
    func reloadTableView() {
        
        tableView.reloadData()
    }
    
    //MARK: - Delete KPI
    func deleteKPI(kpiID: Int) {
        let request = DeleteKPI(model: model)
        request.deleteKPI(kpiID: kpiID, success: {
            print("KPI with id \(kpiID) was deleted")
        }, failure: { error in
            print(error)
            self.showAlert(title: "Sorry", errorMessage: error)
            self.loadKPIsFromServer()
        })
    }
    
    //MARK: -  Pull to refresh method
    func refresh(sender:AnyObject)
    {
        removeAllKpis()
    }
    
    //MARK: - Load KPIs from server methods
    //MARK: Load all KPIs
    func loadKPIsFromServer() {        
       
        let request = GetKPIs(model: model)
        request.getKPIsFromServer(success: { kpi in
            self.model.kpis = kpi
            self.arrayOfKPI = kpi
            self.loadIntegratedKpis()
            self.refreshControl?.endRefreshing()
            //self.loadReports()
            //NotificationCenter.default.post(name: .modelDidChanged, object: nil)
            
        }, failure: { error in
            print(error)
            self.refreshControl?.endRefreshing()
            self.showAlert(title: "Sorry!", errorMessage: error)
            self.tableView.reloadData()
        })
    }
    
    func removeAllKpis() {
        
        let request = NSFetchRequest<ExternalKPI>(entityName: "ExternalKPI")
        if let result  = try? context.fetch(request)
        {
            result.forEach { context.delete($0) }
        }
        
        do {
            try context.save()
            arrayOfKPI.removeAll()
            tableView.reloadData()
            loadKPIsFromServer()
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func loadIntegratedKpis() {
        
        GetIntegratedKPIs().getKPIsFromServer(success: { kpis in
            print(kpis)
            self.loadExternal()
        }) { error in
            print(error)
            self.tableView.reloadData()
        }
    }
    
    func loadExternal() {
        
        do {
            let request = NSFetchRequest<ExternalKPI>(entityName: "ExternalKPI")
            let userID = Int64(model.profile.userId)
            let predicate = NSPredicate(format: "userID == \(userID)",
                argumentArray: nil)
            request.predicate = predicate
            
            _ = try context.fetch(request)
                .forEach { extKPI in
                    let kpi = KPI(kpiID: 0,
                                  typeOfKPI: .IntegratedKPI,
                                  integratedKPI: extKPI,
                                  createdKPI: nil,
                                  imageBacgroundColour: UIColor(hex: "D8F7D7".hex!))
                    kpi.KPIViewOne = .Numbers
                    
                    arrayOfKPI.append(kpi)
            }
            tableView.reloadData()
        }
        catch {
            print("Fetching failed")
        }
    }
    
    private func isThisKpiByMe(_ kpi: KPI) -> Bool{
        return kpi.createdKPI?.executant == model.profile.userId
    }
    
    //MARK: Load reports
    func loadReportsFor(kpi: KPI) {
        
        kpi.createdKPI?.number.removeAll()
        
        let request = GetReports(model: model)
        let interval = kpi.createdKPI?.timeInterval
        request.getReportForKPI(withID: kpi.id, period: interval!, success: { reports in
            kpi.createdKPI?.number = request.filterReports(kpi: kpi, reports: reports)
            self.nc.post(name: .reportDataForKpiRecieved, object: nil)
            self.tableView.reloadData()
        }, failure: { error in })
    }
    
    //MARK: Load User's KPI
    func loadUsersKPI(userID: Int) {
                
        navigationItem.title = "Responsibility"
        
        arrayOfKPI = model.kpis.filter { kpi in
            if let created = kpi.createdKPI
            {
                return created.executant == userID
            }
            else if let integrated = kpi.integratedKPI
            {
                return integrated.userID == Int64(userID)
            }
            return false
        }
    }
    
    //MARK: - CatchNotification
    func catchNotification(notification:Notification) -> Void {
        
        if notification.name == .modelDidChanged { tableView.reloadData() }
        else if notification.name == .newExternalKPIadded
        {
            refresh(sender: self)
            tableView.reloadData()
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddKPI" {
            let destinationVC = segue.destination as! ChooseSuggestedKPITableViewController
            destinationVC.model = model            
            destinationVC.KPIListVC = self
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if(!(parent?.isEqual(self.parent) ?? false)) {
           // self.navigationController?.presentTransparentNavigationBar()
        }
    }
    
}

//MARK: - updateKPIListDelegate method
extension KPIsListTableViewController: updateKPIListDelegate {
    
    func addNewKPI(kpi: KPI) {
        
        self.model.kpis.append(kpi)
        self.arrayOfKPI.append(kpi)
        self.tableView.reloadData()
    }
    
    func updateKPIList() {
        
        removeAllKpis()
    }
}

//MARK: - KPIListButtonCellDelegate methods
extension KPIsListTableViewController: KPIListButtonCellDelegate {
    
    func userTapped(button: UIButton, edit: Bool) {
        
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: .reportViewController) as! ReportAndViewKPITableViewController
        destinatioVC.model = model        
        destinatioVC.kpiIndex = button.tag
        destinatioVC.buttonDidTaped = edit ? ButtonDidTaped.Edit : ButtonDidTaped.Report
        destinatioVC.KPIListVC = self
        navigationController?.pushViewController(destinatioVC, animated: true)        
    }
    
    func memberNameDidTaped(sender: UIButton) {
        
        let stack = self.navigationController?.viewControllers
        
        if (stack?.count)! > 1, stack?[(stack?.count)! - 2] is MemberInfoViewController {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: .memberViewController) as! MemberInfoViewController
        destinatioVC.model = model
        destinatioVC.navigationItem.rightBarButtonItem = nil
        
        let member = model.team.filter { $0.userID == Int64(model.profile.userId) }
        let createdKPI = arrayOfKPI[sender.tag].createdKPI
        let executantId = createdKPI?.executant
        for i in 0..<model.team.count {
            if Int(model.team[i].userID) == executantId {
                destinatioVC.index = i
                navigationController?.pushViewController(destinatioVC, animated: true)
                return
            }
        }
        showAlert(title: "Error", errorMessage: "Unknown member!")
        return
    }
    
    func deleteDidTaped(sender: UIButton) {
        let indexPath = IndexPath(item: sender.tag, section: 1)
      
        let kpiToDelete = model.kpis[indexPath.row]
        
        if let _ = kpiToDelete.createdKPI
        {
            deleteKPI(kpiID: kpiToDelete.id)
        }
        else
        {
            let id = Int(kpiToDelete.integratedKPI.serverID)
            
            DeleteIntegratedKPI().deleteKPI(kpiID: id , success: {
                print("DEBUG: SUCCESSFULLY DELETED")
            }, failure: { (error) in
                print(error)
            })
        }
        
        model.kpis.remove(at: indexPath.row)
        arrayOfKPI.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
