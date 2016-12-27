//
//  faqTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class faqTableViewController: UITableViewController {
    
    let headersOfQuestion = ["Question: Dashboards","Question: Dashboards", "Question: Alerts"]
    let descriptionsOfQuestion = ["Linux Or Windows Which Is It?", "Help Finding Information Online", "Why inkjet printing is very appealing?"]
    let ansversForQuestion = ["Audio player software is used to play back sound recordings in one of the many formats available for computers today. It can also play back music CDs. There is audio player software that is native to the computer’s operating system (Windows, Macintosh, and Linux) and there are web-based audio players. The main advantage of a computer audio player is that you can play your audio CDs and there is no longer any need to have a separate CD player.", "Some text", "And some text too"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return headersOfQuestion.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell", for: indexPath) as! faqListTableViewCell
        
        cell.headerOfQuestionLabel.text = headersOfQuestion[indexPath.row]
        cell.numberOfQuestionLabel.text = String(indexPath.row)
        
        switch headersOfQuestion[indexPath.row] {
        case "Question: Dashboards":
            cell.numberOfQuestionLabel.backgroundColor = UIColor(red: 154.0/255.0, green: 18.0/255.0, blue: 179.0/255.0, alpha: 1.0)
        case "Question: Alerts":
            cell.numberOfQuestionLabel.backgroundColor = UIColor(red: 31.0/255.0, green: 58.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        case "Question: Team": cell.numberOfQuestionLabel.backgroundColor = UIColor(red: 242.0/255.0, green: 121.0/255.0, blue: 53.0/255.0, alpha: 1.0)
        case "Question: Support":
            cell.numberOfQuestionLabel.backgroundColor = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
        default:
            break
        }
        
        cell.headerOfQuestionLabel.layer.cornerRadius = 14.5
        
        cell.describeOfQuestionLabel.text = descriptionsOfQuestion[indexPath.row]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FAQDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! faqDetailViewController
                //Настройка контроллера назначения
                destinationController.headerOfQestion = headersOfQuestion[indexPath.row]
                destinationController.descriptionOfQuestion = descriptionsOfQuestion[indexPath.row]
                destinationController.ansverForQuestion = ansversForQuestion[indexPath.row]
                destinationController.numberOfQuestion = String(indexPath.row)
            }
        }
    }
    
}
