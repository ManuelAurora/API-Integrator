//
//  faqDetailViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class faqDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var headersOfQestion: [String]!
    var descriptionsOfQuestion: [String]!
    var ansversForQuestion: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let titleCell = tableView.dequeueReusableCell(withIdentifier: "FAQTitle", for: indexPath) as! faqListTableViewCell
        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "FAQDescription", for: indexPath) as! AnswerFaqTableViewCell
        
        titleCell.headerOfQuestionLabel.text = headersOfQestion[indexPath.row]
        titleCell.numberOfQuestionLabel.text = String(indexPath.row)
        
        switch headersOfQestion[indexPath.row] {
        case "Question: Dashboards":
            titleCell.numberOfQuestionLabel.backgroundColor = UIColor(red: 154.0/255.0, green: 18.0/255.0, blue: 179.0/255.0, alpha: 1.0)
        case "Question: Alerts":
            titleCell.numberOfQuestionLabel.backgroundColor = UIColor(red: 31.0/255.0, green: 58.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        case "Question: Team": titleCell.numberOfQuestionLabel.backgroundColor = UIColor(red: 242.0/255.0, green: 121.0/255.0, blue: 53.0/255.0, alpha: 1.0)
        case "Question: Support":
            titleCell.numberOfQuestionLabel.backgroundColor = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
        default:
            break
        }
        
        titleCell.describeOfQuestionLabel.text = descriptionsOfQuestion[indexPath.row]
        descriptionCell.answerFaqTextView.text = ansversForQuestion[indexPath.row]
        
        if indexPath.row == 0 {
            return titleCell
        } else {
            return descriptionCell
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
