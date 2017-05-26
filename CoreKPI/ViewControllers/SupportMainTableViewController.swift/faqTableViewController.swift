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
    
    var faqDictionary: [FAQSection : [(description: String, answer: String)]] = [:]
    let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "F.A.Q."
        dictionaryCreator()
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
            self.saveFAQ()
        }, failure: { error in
            self.showAlert(title: "Error Occured", errorMessage: error)
            print(error)
        }
        )
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
    
    //MARK: - CoreData methods
    func dictionaryCreator() {
        let array = loadFAQFromCoreData()
        var dashboard: [(description: String, answer: String)] = []
        var alerts: [(description: String, answer: String)] = []
        var team: [(description: String, answer: String)] = []
        var support: [(description: String, answer: String)] = []
        for faq in array {
            switch (faq.section)! {
            case "Dashboard":
                let descr = faq.descript
                let answer = faq.answer
                dashboard.append((descr!, answer!))
            case "Alert":
                let descr = faq.descript
                let answer = faq.answer
                alerts.append((descr!, answer!))
            case "Team":
                let descr = faq.descript
                let answer = faq.answer
                team.append((descr!, answer!))
            case "Support":
                let descr = faq.descript
                let answer = faq.answer
                support.append((descr!, answer!))
            default:
                break
            }
        }
        faqDictionary[FAQSection.Dashboard] = dashboard
        faqDictionary[FAQSection.Alert] = alerts
        faqDictionary[FAQSection.Team] = team
        faqDictionary[FAQSection.Support] = support
        
    }
    
    func loadFAQFromCoreData() -> [FAQ] {
        do {
            let faqArray = try context.fetch(FAQ.fetchRequest())
            return faqArray as! [FAQ]
        } catch {
            print("Fetching faild")
            return []
        }
    }
    
    func saveFAQ() {
        for faq in loadFAQFromCoreData() {
            self.context.delete(faq)
        }
        
        for section in faqDictionary {
            let key = section.key
            let array = section.value
            for item in array {
                let faq = FAQ(context: context)
                faq.section = key.rawValue
                faq.descript = item.description
                faq.answer = item.answer
            }
        }
        do {
            try self.context.save()
        } catch {
            print(error)
            return
        }
    }
    
    //MARK: - Navigations
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
