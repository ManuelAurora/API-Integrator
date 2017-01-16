//
//  faqTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class faqTableViewController: UITableViewController {
    
    enum FAQSection : String {
        case Dashboard = "Question: Dashboards"
        case Alert = "Question: Alerts"
        case Team = "Question: Team"
        case Support = "Question: Support"
    }
    
    let headersOfQuestion: [FAQSection] = [.Dashboard, .Dashboard, .Alert]
    let descriptionsOfQuestion = ["Linux Or Windows Which Is It?", "Help Finding Information Online", "Why inkjet printing is very appealing?"]
    let ansversForQuestion = ["Audio player software is used to play back sound recordings in one of the many formats available for computers today. It can also play back music CDs. There is audio player software that is native to the computer’s operating system (Windows, Macintosh, and Linux) and there are web-based audio players. The main advantage of a computer audio player is that you can play your audio CDs and there is no longer any need to have a separate CD player.", "Some text", "And some text too"]
    
    var sizeOfQuestionsInSections: [Int] = [0,0,0,0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        
        for heads in headersOfQuestion {
            switch heads {
            case .Dashboard:
                sizeOfQuestionsInSections[0] += 1
            case .Alert:
                sizeOfQuestionsInSections[1] += 1
            case .Team:
                sizeOfQuestionsInSections[2] += 1
            case .Support:
                sizeOfQuestionsInSections[3] += 1
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headersOfQuestion.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell", for: indexPath) as! faqListTableViewCell
        
        cell.headerOfQuestionLabel.text = headersOfQuestion[indexPath.row].rawValue
        
        var numberForLabel = 0
        
        switch indexPath.row {
        case 0..<sizeOfQuestionsInSections[0]:
            numberForLabel = indexPath.row
            
        case sizeOfQuestionsInSections[0]..<sizeOfQuestionsInSections[0]+sizeOfQuestionsInSections[1]:
            numberForLabel = indexPath.row - sizeOfQuestionsInSections[0]
        case sizeOfQuestionsInSections[0]+sizeOfQuestionsInSections[1]..<sizeOfQuestionsInSections[0]+sizeOfQuestionsInSections[1]+sizeOfQuestionsInSections[2]:
            numberForLabel = indexPath.row - sizeOfQuestionsInSections[0]+sizeOfQuestionsInSections[1]
        case sizeOfQuestionsInSections[0]+sizeOfQuestionsInSections[1]+sizeOfQuestionsInSections[2]..<sizeOfQuestionsInSections[0]+sizeOfQuestionsInSections[1]+sizeOfQuestionsInSections[2]+sizeOfQuestionsInSections[3]:
            numberForLabel = indexPath.row - sizeOfQuestionsInSections[0]+sizeOfQuestionsInSections[1]+sizeOfQuestionsInSections[2]
        default:
            numberForLabel = 00
        }
        cell.numberOfQuestionLabel.text = String(numberForLabel+1)
        
        switch headersOfQuestion[indexPath.row] {
        case .Dashboard:
            cell.numberBackgroundView.backgroundColor = UIColor(red: 154.0/255.0, green: 18.0/255.0, blue: 179.0/255.0, alpha: 1.0)
        case .Alert:
            cell.numberBackgroundView.backgroundColor = UIColor(red: 31.0/255.0, green: 58.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        case .Team: cell.numberBackgroundView.backgroundColor = UIColor(red: 242.0/255.0, green: 121.0/255.0, blue: 53.0/255.0, alpha: 1.0)
        case .Support:
            cell.numberBackgroundView.backgroundColor = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
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
                destinationController.headerOfQestion = headersOfQuestion[indexPath.row].rawValue
                destinationController.descriptionOfQuestion = descriptionsOfQuestion[indexPath.row]
                destinationController.ansverForQuestion = ansversForQuestion[indexPath.row]
                
                var numberForLabel = 0
                
                switch indexPath.row {
                case 0..<sizeOfQuestionsInSections[0]:
                    numberForLabel = indexPath.row
                    
                case sizeOfQuestionsInSections[0]..<sizeOfQuestionsInSections[0]+sizeOfQuestionsInSections[1]:
                    numberForLabel = indexPath.row - sizeOfQuestionsInSections[0]
                case sizeOfQuestionsInSections[0]+sizeOfQuestionsInSections[1]..<sizeOfQuestionsInSections[0]+sizeOfQuestionsInSections[1]+sizeOfQuestionsInSections[2]:
                    numberForLabel = indexPath.row - sizeOfQuestionsInSections[0]+sizeOfQuestionsInSections[1]
                case sizeOfQuestionsInSections[0]+sizeOfQuestionsInSections[1]+sizeOfQuestionsInSections[2]..<sizeOfQuestionsInSections[0]+sizeOfQuestionsInSections[1]+sizeOfQuestionsInSections[2]+sizeOfQuestionsInSections[3]:
                    numberForLabel = indexPath.row - sizeOfQuestionsInSections[0]+sizeOfQuestionsInSections[1]+sizeOfQuestionsInSections[2]
                default:
                    numberForLabel = 00
                }
                destinationController.numberOfQuestion = String(numberForLabel+1)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
}
