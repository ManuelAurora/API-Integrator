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

enum IntegratedServices: String {
    case none = "Choose Service"
    case SalesForce
    case Quickbooks
    case GoogleAnalytics
    case HubSpotCRM
    case HubSpotMarketing
    case PayPal
}

enum SalesForceKPIs: String {
    case none
    case RevenueNewLeads = "Revenue/new leads"
    case KeyMetrics = "Key metrics"
    case ConvertedLeads = "Converted Leads"
    case OpenOpportunitiesByStage = "Open opportunities by Stage"
    case TopSalesRep = "Top Sales Rep"
    case NewLeadsByIndustry = "New leads by industry"
    case CampaignROI = "Campaign ROI"
}

enum QiuckBooksKPIs: String {
    case none
    case Test = "Coming soon"
}

enum GoogleAnalyticsKPIs: String {
    case none
    case Test = "Coming soon"
}

enum HubSpotCRMKPIs: String {
    case none
    case Test = "Coming soon"
}

enum HubSpotMarketingKPIs: String {
    case none
    case Test = "Coming soon"
}

enum PayPalKPIs: String {
    case none
    case Test = "Coming soon"
}

enum TypeOfKPI: String {
    case IntegratedKPI
    case createdKPI
}

enum ImageForKPIList: String {
    case Increases = "Green up.png"
    case Decreases = "Red down.png"
    case SaleForce = "SaleForce.png"
    case QuickBooks = "QuickBooks.png"
    case GoogleAnalytics = "GoogleAnalytics.png"
    case HubSpotCRM = "HubSpotCRM.png"
    case PayPal = "PayPal.png"
    case HubSpotMarketing = "HubSpotMarketing.png"
}

enum Departments: String {
    case none = "Select"
    case Sales
    case Procurement
    case Projects
    case FinancialManagement = "Financial management"
    case Staff
}

//MARK: - Structs for KPIs
struct IntegratedKPI {
    var service: IntegratedServices
    var saleForceKPIs: [SalesForceKPIs]?
    var quickBookKPIs: [QiuckBooksKPIs]?
    var googleAnalytics: [GoogleAnalyticsKPIs]?
    var hubSpotCRMKPIs: [HubSpotCRMKPIs]?
    var payPalKPIs: [PayPalKPIs]?
    var hubSpotMarketingKPIs: [HubSpotMarketingKPIs]?
}

struct CreatedKPI {
    var source: Source
    var department: String
    var KPI: String
    var descriptionOfKPI: String?
    var executant: Profile
    var timeInterval: String
    var timeZone: String
    var deadline: String
    var number: [(date: String,number: Int)]
    mutating func addReport(report: Int) {
        number.append(("Today", report))
    }
}

struct KPI {
    var typeOfKPI: TypeOfKPI
    var integratedKPI: IntegratedKPI?
    var createdKPI: CreatedKPI?
    var image: ImageForKPIList? {
        
        switch typeOfKPI {
        case .createdKPI:
            let numbers = createdKPI?.number
            if (numbers?.count)! > 1 {
                if (numbers?[(numbers?.count)! - 1])! < (numbers?[(numbers?.count)! - 2])! {
                    return ImageForKPIList.Decreases
                }
                if (numbers?[(numbers?.count)! - 1])! > (numbers?[(numbers?.count)! - 2])! {
                    return ImageForKPIList.Increases
                }
                
            }
            return nil
        case .IntegratedKPI:
            let service = integratedKPI?.service
            switch service! {
            case .none:
                return nil
            case .SalesForce:
                return ImageForKPIList.SaleForce
            case .Quickbooks:
                return ImageForKPIList.QuickBooks
            case .GoogleAnalytics:
                return ImageForKPIList.GoogleAnalytics
            case .HubSpotCRM:
                return ImageForKPIList.HubSpotCRM
            case .PayPal:
                return ImageForKPIList.PayPal
            case .HubSpotMarketing:
                return ImageForKPIList.HubSpotMarketing
            }
        }
    }
    var imageBacgroundColour: UIColor!
    
}

class KPIsListTableViewController: UITableViewController, updateKPIListDelegate, KPIListButtonCellDelegate {
    
    var request: Request!
    var model: ModelCoreKPI! = ModelCoreKPI(token: "123", profile: Profile(userId: 1, userName: "user@mail.ru", firstName: "user", lastName: "user", position: "CEO", photo: nil, phone: nil, nickname: nil, typeOfAccount: .Admin))
    
    var kpiList: [KPI] = []
    var updateProfileDelegate: updateProfileDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.request = Request(model: self.model)
        if model.profile?.typeOfAccount != TypeOfAccount.Admin {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        //Debug only!
        let kpiOne = KPI(typeOfKPI: .createdKPI, integratedKPI: nil, createdKPI: CreatedKPI(source: .Integrated, department: "Sales Department", KPI: "Shop Supplies", descriptionOfKPI: "One of the key indicators for western organizations that mainly help to determine the economic efficiency of the Procurement Department.", executant: self.model.profile!, timeInterval: "Daily", timeZone: "Denver(GTM-6)", deadline: "Before 16:00", number: [("08/01/17", 12000), ("08/01/16", 25800), ("07/01/2017", 24400)]), imageBacgroundColour: UIColor.clear)
        let kpiTwo = KPI(typeOfKPI: .createdKPI, integratedKPI: nil, createdKPI: CreatedKPI(source: .Integrated, department: "IT", KPI: "Shop Volume",descriptionOfKPI: nil, executant: Profile(userId: 123, userName: "User@User.com", firstName: "Semen", lastName: "Osipov", position: nil, photo: nil, phone: nil, nickname: nil, typeOfAccount: .Admin) , timeInterval: "week", timeZone: "+3", deadline: "12.01.2017", number: [("08/01/17", 25800), ("07/01/2017", 24400)]), imageBacgroundColour: UIColor.clear)
        kpiList = [kpiOne, kpiTwo]
        
        self.loadKPIsFromServer()
        
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
        return kpiList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KPIListCell", for: indexPath) as! KPIListTableViewCell
        cell.KPIListVC  = self
        cell.editButton.tag = indexPath.row
        cell.reportButton.tag = indexPath.row
        cell.memberNameButton.tag = indexPath.row
        
        if let imageString = kpiList[indexPath.row].image {
            cell.KPIListCellImageView.isHidden = false
            cell.KPIListCellImageView.image = UIImage(named: imageString.rawValue)
        } else {
            cell.KPIListCellImageView.isHidden = true
        }
        
        cell.KPIListCellImageBacgroundView.backgroundColor = kpiList[indexPath.row].imageBacgroundColour
        
        switch kpiList[indexPath.row].typeOfKPI {
        case .IntegratedKPI:
            cell.reportButton.isHidden = true
            cell.KPIListNumber.isHidden = true
            cell.ManagedByStack.isHidden = true
            let integratedKPI = kpiList[indexPath.row].integratedKPI
            cell.KPIListHeaderLabel.text = integratedKPI?.service.rawValue
        case .createdKPI:
            let createdKPI = kpiList[indexPath.row].createdKPI
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
                    cell.KPIListNumber.text = "\(number.number)"
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
        switch indexPath.row {
        case 0:
            let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewChartViewController
            destinatioVC.typeOfChart = .PieChart
            navigationController?.pushViewController(destinatioVC, animated: true)
        case 1:
            let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewChartViewController
            destinatioVC.typeOfChart = .PointChart
            navigationController?.pushViewController(destinatioVC, animated: true)
        default:
            let destinationVC = storyboard?.instantiateViewController(withIdentifier: "ChartsiOS") as! iOSChartsTestViewController
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    //MARK: - Load KPIs from server methods
    func loadKPIsFromServer(){
        self.request = Request(model: model)
        let data: [String : Any] = [:]
        
        request.getJson(category: "/kpi/getKPIList", data: data,
                        success: { json in
                            self.parsingJson(json: json)
        },
                        failure: { (error) in
                            print(error)
        })
    }
    
    func parsingJson(json: NSDictionary) {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSArray {
                    
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
                        var number: [(String, Int)]
                        
                        
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
                            
                            let createdKPI = CreatedKPI(source: source, department: department, KPI: kpi_name, descriptionOfKPI: descriptionOfKPI, executant: executant, timeInterval: timeInterval, timeZone: timeZone, deadline: deadline, number: number)
                            let kpi = KPI(typeOfKPI: typeOfKPI, integratedKPI: nil, createdKPI: createdKPI, imageBacgroundColour: UIColor.clear)
                            self.kpiList.append(kpi)
                            
                        }
                        
                        kpi+=1
                        if dataKey.count == kpi {
                            KPIListEndParsing = true
                        }
                        self.tableView.reloadData()
                    }
                    
                    
                    
                    
                    //Save data from json
                    
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
    }
    
    //MARK: - Show alert method
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - updateKPIListDelegate method
    func addNewKPI(kpi: KPI) {
        self.kpiList.append(kpi)
        self.tableView.reloadData()
    }
    func updateKPIList(kpiArray: [KPI]) {
        self.kpiList = kpiArray
        self.tableView.reloadData()
    }
    
    //MARK: - KPIListButtonCellDelegate methods
    func editButtonDidTaped(sender: UIButton) {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "ReportAndViewKPI") as! ReportAndViewKPITableViewController
        destinatioVC.kpiIndex = sender.tag
        destinatioVC.kpiArray = self.kpiList
        destinatioVC.buttonDidTaped = ButtonDidTaped.Edit
        destinatioVC.KPIListVC = self
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    func reportButtonDidTaped(sender: UIButton) {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "ReportAndViewKPI") as! ReportAndViewKPITableViewController
        destinatioVC.kpiIndex = sender.tag
        destinatioVC.kpiArray = self.kpiList
        destinatioVC.buttonDidTaped = ButtonDidTaped.Report
        destinatioVC.KPIListVC = self
        navigationController?.pushViewController(destinatioVC, animated: true)
        
    }
    func memberNameDidTaped(sender: UIButton) {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "MemberInfo") as! MemberInfoViewController
        destinatioVC.model = self.model
        let profile = self.kpiList[sender.tag].createdKPI
        destinatioVC.profile = profile?.executant
        destinatioVC.navigationItem.rightBarButtonItem = nil
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
    //MARK: - navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddKPI" {
            let destinationVC = segue.destination as! ChooseSuggestedKPITableViewController
            destinationVC.model = ModelCoreKPI(model: self.model)
            destinationVC.KPIListVC = self
        }
    }
    
}
