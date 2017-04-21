//
//  TalkToUsViewController.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 21.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class TalkToUsViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.layer.cornerRadius = 6
        view.backgroundColor = OurColors.gray
        textView.becomeFirstResponder()
    }

}
