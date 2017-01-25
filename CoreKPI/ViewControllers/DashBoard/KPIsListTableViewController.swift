//
//  KPIsListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 23.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

//MARK: - Enums for setting
enum Source: String {
    case none = "Choose"
    case User
    case Integrated
}

class KPIsListTableViewController: UITableViewController {
    
    var model: ModelCoreKPI! = ModelCoreKPI(token: "123", profile: Profile(userId: 1, userName: "user@mail.ru", firstName: "user", lastName: "user", position: "CEO", photo: nil, phone: nil, nickname: nil, typeOfAccount: .Manager))
    
    //var updateProfileDelegate: updateProfileDelegate!
    
    let profileDidChangeNotification = Notification.Name(rawValue:"profileDidChange")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if model.profile?.typeOfAccount != TypeOfAccount.Admin {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        //Debug ->
        let kpiOne = KPI(typeOfKPI: .createdKPI, integratedKPI: nil, createdKPI: CreatedKPI(source: .Integrated, department: Departments.Sales, KPI: "Shop Supplies", descriptionOfKPI: "One of the key indicators for western organizations that mainly help to determine the economic efficiency of the Procurement Department.", executant: (model.profile?.userId)!, timeInterval: TimeInterval.Daily , timeZone: "GMT +0", deadline: "Before 16:00", number: [("08/01/17", 12000), ("08/01/16", 25800), ("07/01/2017", 24400)]), imageBacgroundColour: nil)
        kpiOne.KPIViewOne = .Graph
        kpiOne.KPIViewTwo = TypeOfKPIView.Numbers
        let kpiTwo = KPI(typeOfKPI: .createdKPI, integratedKPI: nil, createdKPI: CreatedKPI(source: .Integrated, department: Departments.Procurement, KPI: "Shop Volume",descriptionOfKPI: nil, executant: 75 , timeInterval: TimeInterval.Weekly, timeZone: "MSK +3", deadline: "12.01.2017", number: [("08/01/17", 25800), ("07/01/2017", 24400)]), imageBacgroundColour: nil)
        kpiTwo.KPIViewOne = .Graph
        kpiTwo.KPIChartTwo = TypeOfChart.PointChart
        self.model.kpis = [kpiOne, kpiTwo]
        //<-debug
        let nc = NotificationCenter.default
        nc.addObserver(forName:profileDidChangeNotification, object:nil, queue:nil, using:catchNotification)
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)

        self.navigationController?.hideTransparentNavigationBar()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)]
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let firstLoad = UserDefaults.standard.data(forKey: "firstLoad"),
            let _ = NSKeyedUnarchiver.unarchiveObject(with: firstLoad) as? Bool {
        } else {
            let onboardingVC = storyboard?.instantiateViewController(withIdentifier: "OnboardingVC") as! OnboardingPageViewController
            present(onboardingVC, animated: true, completion: nil)
            print("First load!")
            saveData()
        }
    }
    
    //MARK: - Save mark about first loading
    func saveData() {
        let data: Bool = true
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
        UserDefaults.standard.set(encodedData, forKey: "firstLoad")
        print("First loading mark saved in NSKeyedArchive")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model.kpis.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KPIListCell", for: indexPath) as! KPIListTableViewCell
        cell.KPIListVC  = self
        cell.editButton.tag = indexPath.row
        cell.reportButton.tag = indexPath.row
        cell.memberNameButton.tag = indexPath.row
        
        if let imageString = model.kpis[indexPath.row].image {
            cell.KPIListCellImageView.isHidden = false
            cell.KPIListCellImageView.image = UIImage(named: imageString.rawValue)
        } else {
            cell.KPIListCellImageView.isHidden = true
        }
        
        cell.KPIListCellImageBacgroundView.backgroundColor = model.kpis[indexPath.row].imageBacgroundColour
        
        switch model.kpis[indexPath.row].typeOfKPI {
        case .IntegratedKPI:
            cell.reportButton.isHidden = true
            cell.KPIListNumber.isHidden = true
            cell.ManagedByStack.isHidden = true
            let integratedKPI = model.kpis[indexPath.row].integratedKPI
            cell.KPIListHeaderLabel.text = integratedKPI?.service.rawValue
        case .createdKPI:
            let createdKPI = model.kpis[indexPath.row].createdKPI
            cell.KPIListHeaderLabel.text = createdKPI?.KPI
            if model.profile?.typeOfAccount == TypeOfAccount.Admin {
                if model.profile?.userId == createdKPI?.executant {
                    cell.reportButton.isHidden = false
                    cell.editButton.isHidden = false
                } else {
                    cell.reportButton.isHidden = true
                    cell.editButton.isHidden = false
                }
            } else {
                cell.reportButton.isHidden = false
                cell.editButton.isHidden = false
            }
            cell.KPIListNumber.isHidden = false
            cell.ManagedByStack.isHidden = false
            
            if (createdKPI?.number.count)! > 0 {
                if let number = createdKPI?.number[(createdKPI?.number.count)! - 1] {
                    let formatter: NumberFormatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.groupingSeparator = ","
                    formatter.decimalSeparator = "."
                    formatter.maximumFractionDigits = 10
                    let formatedStr: String = formatter.string(from: NSNumber(value: number.number))!
                    cell.KPIListNumber.text = formatedStr
                }
            } else {
                cell.KPIListNumber.text = ""
            }
            
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "PageVC") as! ChartsPageViewController
        destinationVC.kpi = model.kpis[indexPath.row]
        navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    
    //MARK: -  Pull to refresh method
    func refresh(sender:AnyObject)
    {
        loadKPIsFromServer()
    }
    
    //MARK: - Load KPIs from server methods
    //MARK: Load all KPIs
    func loadKPIsFromServer(){
        let request = GetKPIs(model: model)
        request.getKPIsFromServer(success: { kpi in
            self.model.kpis = kpi
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }, failure: { error in
            print(error)
            self.refreshControl?.endRefreshing()
            self.showAlert(title: "Sorry!", message: error)
            self.tableView.reloadData()
        }
        )
    }
    
    //MARK: Load User's KPI
    func loadUsersKPI(userID: Int) {
        
        let request = GetUserKPIs(model: model)
        request.getUserKPIs(userID: userID, success: { kpi in
            self.model.kpis = kpi
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }, failure: { error in
            print(error)
            self.refreshControl?.endRefreshing()
            self.showAlert(title: "Sorry!", message: error)
            self.tableView.reloadData()
        }
        )
    }
    
    //MARK: - Show alert method
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - CatchNotification
    func catchNotification(notification:Notification) -> Void {
        
        if notification.name == profileDidChangeNotification {
            guard let userInfo = notification.userInfo,
                let teamList = userInfo["teamList"] as? [Team] else {
                    print("No userInfo found in notification")
                    return
            }
            model.team = teamList
            tableView.reloadData()
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddKPI" {
            let destinationVC = segue.destination as! ChooseSuggestedKPITableViewController
            destinationVC.model = ModelCoreKPI(model: model)
            destinationVC.KPIListVC = self
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if(!(parent?.isEqual(self.parent) ?? false)) {
            self.navigationController?.presentTransparentNavigationBar()
        }
    }
    
}

//MARK: - updateKPIListDelegate method
extension KPIsListTableViewController: updateKPIListDelegate {
    
    func addNewKPI(kpi: KPI) {
        self.model.kpis.append(kpi)
        self.tableView.reloadData()
    }
    
    func updateKPIList(kpiArray: [KPI]) {
        self.model.kpis = kpiArray
        self.tableView.reloadData()
    }
}

//MARK: - KPIListButtonCellDelegate methods
extension KPIsListTableViewController: KPIListButtonCellDelegate {
    func editButtonDidTaped(sender: UIButton) {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "ReportAndViewKPI") as! ReportAndViewKPITableViewController
        destinatioVC.model = ModelCoreKPI(model: model)
        destinatioVC.kpiIndex = sender.tag
        destinatioVC.buttonDidTaped = ButtonDidTaped.Edit
        
        destinatioVC.KPIListVC = self
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
    func reportButtonDidTaped(sender: UIButton) {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "ReportAndViewKPI") as! ReportAndViewKPITableViewController
        destinatioVC.model = model
        destinatioVC.kpiIndex = sender.tag
        destinatioVC.buttonDidTaped = ButtonDidTaped.Report
        destinatioVC.KPIListVC = self
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
    func memberNameDidTaped(sender: UIButton) {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "MemberInfo") as! MemberInfoViewController
        destinatioVC.model = model
        destinatioVC.navigationItem.rightBarButtonItem = nil
        let createdKPI = model.kpis[sender.tag].createdKPI
        let executantId = createdKPI?.executant
        for i in 0..<model.team.count {
            if Int(model.team[i].userID) == executantId {
                destinatioVC.index = i
                navigationController?.pushViewController(destinatioVC, animated: true)
                return
            }
        }
        showAlert(title: "Error", message: "Unknown member!")
        return
    }
}
