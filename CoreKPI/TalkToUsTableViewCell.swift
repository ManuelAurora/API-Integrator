//
//  TalkToUsTableViewCell.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 28.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class TalkToUsTableViewCell: UITableViewCell
{

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel:   UILabel!
    @IBOutlet weak var backView:      UIView!
    
    func prepareCellCosmetics() {
    
        backgroundColor = .clear
        questionLabel.clipsToBounds      = true
        answerLabel.clipsToBounds        = true
        backView.layer.cornerRadius      = 6
        questionLabel.layer.cornerRadius = 6
        answerLabel.layer.cornerRadius   = 6 
    }
    
}
