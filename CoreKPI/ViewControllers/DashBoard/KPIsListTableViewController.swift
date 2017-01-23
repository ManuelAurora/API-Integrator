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

class KPIsListTableViewController: UITableViewController, updateKPIListDelegate, KPIListButtonCellDelegate {
    
    var request: Request!
    var model: ModelCoreKPI! = ModelCoreKPI(token: "123", profile: Profile(userId: 1, userName: "user@mail.ru", firstName: "user", lastName: "user", position: "CEO", photo: nil, phone: nil, nickname: nil, typeOfAccount: .Manager))
    
    //var kpiList: [KPI] = []
    var updateProfileDelegate: updateProfileDelegate!
    
    let profileDidChangeNotification = Notification.Name(rawValue:"profileDidChange")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.request = Request(model: self.model)
        if model.profile?.typeOfAccount != TypeOfAccount.Admin {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        //Debug only!
        let kpiOne = KPI(typeOfKPI: .createdKPI, integratedKPI: nil, createdKPI: CreatedKPI(source: .Integrated, department: Departments.Sales, KPI: "Shop Supplies", descriptionOfKPI: "One of the key indicators for western organizations that mainly help to determine the economic efficiency of the Procurement Department.", executant: self.model.profile!, timeInterval: TimeInterval.Daily , timeZone: "GMT +0", deadline: "Before 16:00", number: [("08/01/17", 12000), ("08/01/16", 25800), ("07/01/2017", 24400)]), imageBacgroundColour: nil)
        kpiOne.KPIViewOne = .Graph
        kpiOne.KPIViewTwo = TypeOfKPIView.Numbers
        let kpiTwo = KPI(typeOfKPI: .createdKPI, integratedKPI: nil, createdKPI: CreatedKPI(source: .Integrated, department: Departments.Procurement, KPI: "Shop Volume",descriptionOfKPI: nil, executant: Profile(userId: 123, userName: "User@User.com", firstName: "Pes", lastName: "Sobaka", position: nil, photo: nil, phone: nil, nickname: nil, typeOfAccount: .Admin) , timeInterval: TimeInterval.Weekly, timeZone: "MSK +3", deadline: "12.01.2017", number: [("08/01/17", 25800), ("07/01/2017", 24400)]), imageBacgroundColour: nil)
        kpiTwo.KPIViewOne = .Graph
        kpiTwo.KPIChartTwo = TypeOfChart.PointChart
        self.model.kpis = [kpiOne, kpiTwo]
        
        let nc = NotificationCenter.default
        nc.addObserver(forName:profileDidChangeNotification, object:nil, queue:nil, using:catchNotification)
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)

        self.navigationController?.hideTransparentNavigationBar()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)]
        tableView.tableFooterView = UIView(frame: .zero)
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
        
        if let imageString = self.model.kpis[indexPath.row].image {
            cell.KPIListCellImageView.isHidden = false
            cell.KPIListCellImageView.image = UIImage(named: imageString.rawValue)
        } else {
            cell.KPIListCellImageView.isHidden = true
        }
        
        cell.KPIListCellImageBacgroundView.backgroundColor = self.model.kpis[indexPath.row].imageBacgroundColour
        
        switch self.model.kpis[indexPath.row].typeOfKPI {
        case .IntegratedKPI:
            cell.reportButton.isHidden = true
            cell.KPIListNumber.isHidden = true
            cell.ManagedByStack.isHidden = true
            let integratedKPI = self.model.kpis[indexPath.row].integratedKPI
            cell.KPIListHeaderLabel.text = integratedKPI?.service.rawValue
        case .createdKPI:
            let createdKPI = self.model.kpis[indexPath.row].createdKPI
            cell.KPIListHeaderLabel.text = createdKPI?.KPI
            if self.model.profile?.typeOfAccount == TypeOfAccount.Admin {
                if self.model.profile?.userId == createdKPI?.executant.userId {
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
            
            if createdKPI?.executant.userId == self.model.profile?.userId {
                cell.memberNameButton.setTitle( "Me" , for: .normal )
            } else {
                let title = (createdKPI?.executant.firstName)! + " " + (createdKPI?.executant.lastName)!
                cell.memberNameButton.setTitle(title, for: .normal)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "PageVC") as! ChartsPageViewController
        destinationVC.kpi = self.model.kpis[indexPath.row]
        navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    
    //MARK: -  Pull to refresh method
    func refresh(sender:AnyObject)
    {
        //load KPI from server
        loadKPIsFromServer()
    }
    
    //MARK: - Load KPIs from server methods
    //MARK: Load all KPIs
    func loadKPIsFromServer(){
        self.request = Request(model: model)
        let data: [String : Any] = [:]
        
        request.getJson(category: "/kpi/getKPIList", data: data,
                        success: { json in
                            self.parsingJson(json: json)
        },
                        failure: { (error) in
                            print(error)
                            self.showAlert(title: "Sorry!", message: error)
                            self.refreshControl?.endRefreshing()
        })
    }
    
    func parsingJson(json: NSDictionary) {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSArray {
                    self.model.kpis.removeAll()
                    var KPIListEndParsing = false
                    var kpi = 0
                    while KPIListEndParsing == false {
                        var active = 0
                        var id = 0
                        let typeOfKPI = TypeOfKPI.createdKPI
                        
                        //var image: ImageForKPIList!
                        
                        let source = Source.User
                        var department: String
                        var kpi_name: String
                        var descriptionOfKPI: String?
                        var executant: Profile
                        let timeInterval = TimeInterval.Daily.rawValue
                        var timeZone: String
                        var deadline: String
                        var number: [(String, Double)]
                        
                        
                        if let kpiData = dataKey[kpi] as? NSDictionary {
                            active = (kpiData["active"] as? Int) ?? 0
                            id = (kpiData["id"] as? Int) ?? 0
                            kpi_name = (kpiData["name"] as? String) ?? "Error name"
                            department = (kpiData["department"] as? String) ?? "Error department"
                            descriptionOfKPI = kpiData["desc"] as? String
                            executant = self.model.profile!
                            timeZone = "no"
                            deadline = (kpiData["datetime"] as? String)!
                            number = []
                            //debug
                            //image = ImageForKPIList.Increases
                            
                            print("id: \(id); active: \(active)")
                            
                            let createdKPI = CreatedKPI(source: source, department: Departments(rawValue: department)!, KPI: kpi_name, descriptionOfKPI: descriptionOfKPI, executant: executant, timeInterval: TimeInterval(rawValue: timeInterval)!, timeZone: timeZone, deadline: deadline, number: number)
                            let kpi = KPI(typeOfKPI: typeOfKPI, integratedKPI: nil, createdKPI: createdKPI, imageBacgroundColour: UIColor.clear)
                            self.model.kpis.append(kpi)
                            
                        }
                        
                        kpi+=1
                        if dataKey.count == kpi {
                            KPIListEndParsing = true
                        }
                    }
                    self.tableView.reloadData()
                    
                } else {
                    print("Json data is broken")
                }
            } else {
                let errorMessage = json["message"] as! String
                print("Json error message: \(errorMessage)")
                showAlert(title: "Error geting KPI", message: errorMessage)
            }
        } else {
            print("Json file is broken!")
        }
        refreshControl?.endRefreshing()
    }
    
    //MARK: Load User's KPI
    func loadUsersKPI(userID: Int) {
        self.model.kpis.removeAll()
        self.request = Request(model: model)
        let data: [String : Any] = ["user_id": userID]
        
        request.getJson(category: "/kpi/getUserKPIs", data: data,
                        success: { json in
                            self.parsingJson(json: json)
        },
                        failure: { (error) in
                            print(error)
                            self.showAlert(title: "Sorry!", message: error)
        })
    }
    
    //MARK: - Show alert method
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - updateKPIListDelegate method
    func addNewKPI(kpi: KPI) {
        self.model.kpis.append(kpi)
        self.tableView.reloadData()
    }
    
    func updateKPIList(kpiArray: [KPI]) {
        self.model.kpis = kpiArray
        self.tableView.reloadData()
    }
    
    //MARK: - KPIListButtonCellDelegate methods
    func editButtonDidTaped(sender: UIButton) {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "ReportAndViewKPI") as! ReportAndViewKPITableViewController
        destinatioVC.model = self.model
        destinatioVC.kpiIndex = sender.tag
        destinatioVC.buttonDidTaped = ButtonDidTaped.Edit
        
        destinatioVC.KPIListVC = self
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
    func reportButtonDidTaped(sender: UIButton) {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "ReportAndViewKPI") as! ReportAndViewKPITableViewController
        destinatioVC.model = self.model
        destinatioVC.kpiIndex = sender.tag
        destinatioVC.buttonDidTaped = ButtonDidTaped.Report
        destinatioVC.KPIListVC = self
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
    func memberNameDidTaped(sender: UIButton) {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "MemberInfo") as! MemberInfoViewController
        destinatioVC.model = self.model
        let profile = self.model.kpis[sender.tag].createdKPI
        //destinatioVC.profile = profile?.executant
        destinatioVC.navigationItem.rightBarButtonItem = nil
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
    //MARK: - catchNotification
    func catchNotification(notification:Notification) -> Void {
        print("Catch notification")
        
        if notification.name == self.profileDidChangeNotification {
            guard let userInfo = notification.userInfo,
                let userID = userInfo["userID"] as? Int,
                let profile = userInfo["Profile"] as? Profile else {
                    print("No userInfo found in notification")
                    return
            }
            
        }
    }
    
    //MARK: - navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddKPI" {
            let destinationVC = segue.destination as! ChooseSuggestedKPITableViewController
            destinationVC.model = ModelCoreKPI(model: self.model)
            destinationVC.KPIListVC = self
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if(!(parent?.isEqual(self.parent) ?? false)) {
            self.navigationController?.presentTransparentNavigationBar()
        }
    }
    
}
