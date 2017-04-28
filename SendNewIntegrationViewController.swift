//
//  TalkToUsViewController.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 21.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class SendNewIntegrationViewController: UIViewController {

    var messageType: MessageType!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    @IBAction func send() {
        
        let request =  MessagesRequestManager(model: ModelCoreKPI.modelShared)
     
        request.send(message: textView.text, type: messageType, success: {
            self.navigationController?.popViewController(animated: true)
        }) { error in
           self.showAlert(title: "Error Occured", errorMessage: error)
        }        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        textView.layer.cornerRadius = 6
        view.backgroundColor = OurColors.gray
        textView.becomeFirstResponder()
    }

}
