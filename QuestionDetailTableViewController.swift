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
    @IBOutlet weak var answerTextView:   UITextView!
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        questionTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        answerTextView.scrollRangeToVisible(NSMakeRange(0, 0))
    }
        
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let tabBarHeight: CGFloat = 17
        let height = (view.bounds.height / 3) - tabBarHeight
        
        return height
    }
}
