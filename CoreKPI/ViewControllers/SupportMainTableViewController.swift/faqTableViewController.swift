//
//  faqTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

enum FAQSection : String {
    case Dashboard
    case Alert
    case Team
    case Support
}

class faqTableViewController: UITableViewController {
    
    struct FAQ {
        var section: String
        var data: [(description: String, answer: String)] = []
    }
    
    var faqDictionary: [FAQSection : [(description: String, answer: String)]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLocalFAQ()
        getFAQFromServer()
        tableView.tableFooterView = UIView(frame: .zero)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getFAQFromServer() {
        let request = GetFAQ()
        request.getFAQ(success: { faq in
            self.faqDictionary = faq
            self.tableView.reloadData()
            
            //self.saveFAQ()
        }, failure: { error in
            print(error)
        }
        )
    }
    
    //Load local FAQ
    func loadLocalFAQ() {
        if let data = UserDefaults.standard.data(forKey: "FAQ"),
            let myFAQArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[FAQ]] {
            let faqArray = myFAQArray[0]
            
            for faq in faqArray {
                faqDictionary[FAQSection(rawValue: faq.section)!] = faq.data
            }
            
        } else {
            print("No local FAQ in app storage")
        }
    }
    
    //MARK: - Save FAQ
    func saveFAQ() {
        UserDefaults.standard.removeObject(forKey: "FAQ")
        
        var faqArray:[FAQ] = []
        
        for section in faqDictionary {
            let faq = FAQ(section: section.key.rawValue, data: section.value)
            faqArray.append(faq)
        }
        
        let data: [[FAQ]] = [faqArray]
        
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
        UserDefaults.standard.set(encodedData, forKey: "FAQ")
        print("FAQ saved in NSKeyedArchive")
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return faqDictionary[.Dashboard]?.count ?? 0
        case 1:
            return faqDictionary[.Alert]?.count ?? 0
        case 2:
            return faqDictionary[.Team]?.count ?? 0
        case 3:
            return faqDictionary[.Support]?.count ?? 0
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell", for: indexPath) as! faqListTableViewCell
        
        var section: FAQSection!
        
        switch indexPath.section {
        case 0:
            section = FAQSection.Dashboard
            cell.numberBackgroundView.backgroundColor = UIColor(red: 154.0/255.0, green: 18.0/255.0, blue: 179.0/255.0, alpha: 1.0)
        case 1:
            section = FAQSection.Alert
            cell.numberBackgroundView.backgroundColor = UIColor(red: 31.0/255.0, green: 58.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        case 2:
            section = FAQSection.Team
            cell.numberBackgroundView.backgroundColor = UIColor(red: 242.0/255.0, green: 121.0/255.0, blue: 53.0/255.0, alpha: 1.0)
        case 3:
            section = FAQSection.Support
            cell.numberBackgroundView.backgroundColor = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
        default:
            break
        }
        cell.headerOfQuestionLabel.text = "Question: \(section.rawValue)"
        cell.describeOfQuestionLabel.text = faqDictionary[section]?[indexPath.row].description
        cell.numberOfQuestionLabel.text = "\(indexPath.row + 1)"
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FAQDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! faqDetailViewController
                //Настройка контроллера назначения
                
                var section: FAQSection!
                
                switch indexPath.section {
                case 0:
                    section = FAQSection.Dashboard
                case 1:
                    section = FAQSection.Alert
                case 2:
                    section = FAQSection.Team
                case 3:
                    section = FAQSection.Support
                default:
                    break
                }
                
                destinationController.numberOfQuestion = String(indexPath.row + 1)
                destinationController.headerOfQestion = "Question: \(section.rawValue)"
                destinationController.descriptionOfQuestion = (faqDictionary[section]?[indexPath.row].description)!
                destinationController.ansverForQuestion = (faqDictionary[section]?[indexPath.row].answer)!
                
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
}
