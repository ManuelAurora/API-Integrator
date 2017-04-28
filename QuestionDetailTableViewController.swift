//
//  QuestionDetailTableViewController.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 28.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class QuestionDetailTableViewController: UITableViewController
{
    @IBOutlet weak var questionTextView: UITextView!
    var message: QuestionAnswer!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        questionTextView.text = " " + message.question + "\n \n" + " " + message.answer
       
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        questionTextView.scrollRangeToVisible(NSMakeRange(0, 0))
    }
        
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let tabBarHeight: CGFloat = 50
        let height = view.bounds.height - tabBarHeight
        
        return height
    }
}
