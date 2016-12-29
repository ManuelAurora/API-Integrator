//
//  KPIsListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 23.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class KPIsListTableViewController: UITableViewController {

    struct KPIs {
        var name: String
        var number: String?
        var managedBy: String?
    }
    
    var model = ModelCoreKPI(token: "123", profile: Profile(userId: 1, userName: "user@mail.ru", firstName: "user", lastName: "user", position: "CEO", photo: nil, phone: nil, nickname: nil, typeOfAccount: .Admin))   //: ModelCoreKPI!
    
    var kpiList: [KPIs]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if model.profile?.typeOfAccount != TypeOfAccount.Admin {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        //Debug only!
        let kpiOne = KPIs(name: "Sales Volume", number: "$12,920", managedBy: "Alan Been")
        let kpiTwo = KPIs(name: "Shop supplies", number: "9,210 kg", managedBy: "Me")
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
        cell.KPIListManagedBy.text = kpiList[indexPath.row].managedBy
        cell.KPIListHeaderLabel.text = kpiList[indexPath.row].name
        cell.KPIListNumber.text = kpiList[indexPath.row].number

        return cell
    }

    //Load TPIs from server methods
    func loadKPIsFromServer(){
        //Coming soon
    }

}
