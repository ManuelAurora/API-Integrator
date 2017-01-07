//
//  KPIsListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 23.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

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

enum typeOfKPI: String {
    case IntegratedKPI
    case createdKPI
}

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
    var executant: Profile
    var timeInterval: String
    var timeZone: String
    var deadline: String
}

struct KPI {
    var typeOfKPI: typeOfKPI
    var integratedKPI: IntegratedKPI?
    var createdKPI: CreatedKPI?
}

class KPIsListTableViewController: UITableViewController, updateKPIListDelegate {
    
    var request: Request!
    var model = ModelCoreKPI(token: "123", profile: Profile(userId: 1, userName: "user@mail.ru", firstName: "user", lastName: "user", position: "CEO", photo: nil, phone: nil, nickname: nil, typeOfAccount: .Admin))   //: ModelCoreKPI!
    
    var kpiList: [KPI] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.request = Request(model: self.model)
        if model.profile?.typeOfAccount != TypeOfAccount.Admin {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        //Debug only!
        let kpiOne = KPI(typeOfKPI: .createdKPI, integratedKPI: nil, createdKPI: CreatedKPI(source: .Integrated, department: "IT", KPI: "KPI", executant: self.model.profile!, timeInterval: "week", timeZone: "+3", deadline: "12.01.2017"))
        let kpiTwo = KPI(typeOfKPI: .createdKPI, integratedKPI: nil, createdKPI: CreatedKPI(source: .Integrated, department: "IT", KPI: "KPI", executant: self.model.profile!, timeInterval: "week", timeZone: "+3", deadline: "12.01.2017"))
        kpiList = [kpiOne, kpiTwo]
        
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
        cell.KPIListManagedBy.text = "Me"//kpiList[indexPath.row]
        let integrated = kpiList[indexPath.row].integratedKPI
        let created = kpiList[indexPath.row].createdKPI
        cell.KPIListHeaderLabel.text = integrated?.service.rawValue ?? created?.KPI
        cell.KPIListNumber.text = "12000$"//kpiList[indexPath.row].number

        return cell
    }

    //MARK: - Load TPIs from server methods
    func loadKPIsFromServer(){
        self.request = Request(model: model)
        let data: [String : Any] = [:]
        
        request.getJson(category: "/team/setNickName", data: data,
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
                if let dataKey = json["data"] as? NSDictionary {
                    
                    print(dataKey)
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
    
    //MARK: - navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addKPI" {
            let destinationVC = segue.destination as! AddNewKPITableViewController
            destinationVC.model = ModelCoreKPI(model: self.model)
            destinationVC.kpiListVC = self
        }
    }
    
}
