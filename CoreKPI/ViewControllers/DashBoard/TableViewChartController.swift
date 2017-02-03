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
    
    var index = 0
    var header: String = " "
    var dataArray: [(Date, Double)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! ChartTableViewCell
        switch indexPath.row {
        case 0:
            cell.metricsLabel.text = "Date"
            cell.persentLabel.text = "Value"
            cell.valueLabel.isHidden = true
        default:
            cell.metricsLabel.textColor = UIColor.black
            cell.persentLabel.textColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
            cell.valueLabel.isHidden = true
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            cell.metricsLabel.text = dateFormatter.string(from: dataArray[indexPath.row - 1].0)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 10
            cell.persentLabel.text = numberFormatter.string(from: NSNumber(value: dataArray[indexPath.row - 1].1))!
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
