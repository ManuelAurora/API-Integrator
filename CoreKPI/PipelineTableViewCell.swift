//
//  PipelineTableViewCell.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 05.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class PipelineTableViewCell: UITableViewCell
{
    @IBOutlet weak var pipelineTitleLabel: UILabel!
    
    var wasSelected = false {
        didSet {
            self.accessoryType = wasSelected ? .checkmark : .none
        }
    }
}
