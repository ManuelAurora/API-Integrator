//
//  NewNameViewController.swift
//  CoreKPI
//
//  Created by Семен on 26.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class NewNameViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UITextField!
    
    var personName: String!
    
    weak var changeNameVC: ChageNameTableViewController!
    var delegate: updateNicknameDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.placeholder = self.personName
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if(!(parent?.isEqual(self.parent) ?? false)) {
            if let nickname = nameLabel.text {
                if nickname != "" {
                    delegate = changeNameVC
                    delegate.updateNickname(nickname: nickname)
                }
            }
        }
    }
    
}
