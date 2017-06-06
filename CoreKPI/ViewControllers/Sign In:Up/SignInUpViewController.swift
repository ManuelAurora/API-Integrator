//
//  SignInUpViewController.swift
//  CoreKPI
//
//  Created by Семен on 14.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class SignInUpViewController: UIViewController, StoryboardInstantiation {
    
    var launchController: LaunchViewController!
    var model: ModelCoreKPI!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction func register(_ sender: UIButton) {        
        navigationController?.pushViewController(launchController.registerVC,
                                                 animated: true)
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        navigationController?.pushViewController(launchController.signInVC,
                                                 animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set border for buttons
        signInButton.layer.borderWidth = 1.0
        signInButton.layer.borderColor = UIColor(red: 124.0/255.0, green: 77.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        registerButton.layer.borderWidth = 1.0
        registerButton.layer.borderColor = UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0).cgColor
    }
    
  }
