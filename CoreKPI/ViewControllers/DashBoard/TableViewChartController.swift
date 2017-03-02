//
//  TableViewChartController.swift
//  CoreKPI
//
//  Created by Семен on 17.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class TableViewChartController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var qBMethod: QBMethod!
    lazy var qbDataManager: QuickBookDataManager = {
        let qbdm = QuickBookDataManager.shared()
        return qbdm
    }()
    
    var index = 0
    var header: String = " "
    let notificationCenter = NotificationCenter.default
    var reportArray: [(Date, Double)] = []
    
    var dataArray: [(leftValue: String, centralValue: String, rightValue: String)] = []
    var titleOfTable: (leftTitle: String, centralTitle: String, rightTitle: String) = ("","","")
    
    var typeOfKPI: TypeOfKPI = .createdKPI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch qBMethod!
        {
        case .query:
            notificationCenter.addObserver(self, selector: #selector(TableViewChartController.reloadTableView), name: .qBInvoicesRefreshed, object: nil)
            
        case .balanceSheet:
         notificationCenter.addObserver(self, selector: #selector(TableViewChartController.reloadTableView), name: .qBBalanceSheetRefreshed, object: nil)
            
        default:
            break
        }
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        notificationCenter.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reloadTableView() {
        
        switch qBMethod!
        {
        case .query:
            dataArray = qbDataManager.invoices
            
        case .balanceSheet:
            dataArray = qbDataManager.balanceSheet
            
        default:
            break
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch typeOfKPI {
        case .createdKPI:
            return reportArray.count + 1
        case .IntegratedKPI:
            return dataArray.count + 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! ChartTableViewCell
        
        switch typeOfKPI {
        case .createdKPI:
            switch indexPath.row {
            case 0:
                cell.leftLabel.text = "Date"
                cell.rightLabel.text = "Value"
                cell.centralLabel.isHidden = true
            default:
                cell.leftLabel.textColor = UIColor.black
                cell.rightLabel.textColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
                cell.centralLabel.isHidden = true
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                cell.leftLabel.text = dateFormatter.string(from: reportArray[indexPath.row - 1].0)
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.maximumFractionDigits = 10
                cell.rightLabel.text = numberFormatter.string(from: NSNumber(value: reportArray[indexPath.row - 1].1))!
            }
        case .IntegratedKPI:
            switch indexPath.row {
            case 0:
                cell.leftLabel.text = titleOfTable.leftTitle
                cell.centralLabel.text = titleOfTable.centralTitle
                cell.rightLabel.text = titleOfTable.rightTitle
            default:
                cell.leftLabel.textColor = UIColor.black
                cell.centralLabel.textColor = UIColor.black
                cell.rightLabel.textColor = UIColor.black
                cell.leftLabel.text = dataArray[indexPath.row - 1].leftValue
                cell.centralLabel.text = dataArray[indexPath.row - 1].centralValue
                cell.rightLabel.text = dataArray[indexPath.row - 1].rightValue
            }
        }
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return header
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.text = self.header
        header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 13)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
}
