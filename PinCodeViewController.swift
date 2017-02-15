//
//  PinCodeViewController.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 15.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class PinCodeViewController: UIViewController
{
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet var pinCodePlaceholderViews: [PinCodePlaceholderView]!
    
    @IBAction func pinCodeButtonTapped(_ sender: PinCodeButton) {
        pinCodePlaceholderViews[0].animate(state: .filled)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoLabel.textColor = UIColor(red: 124.0/255.0, green: 77.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
   
    

}
