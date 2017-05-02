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
        ui(block: true)
        request.send(message: textView.text, type: messageType, success: {
            self.ui(block: false)
            self.navigationController?.popViewController(animated: true)
        }) { error in
            self.ui(block: false)
            self.textView.becomeFirstResponder()
           self.showAlert(title: "Error Occured", errorMessage: error)
        }        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        textView.layer.cornerRadius = 6
        view.backgroundColor = OurColors.gray
        textView.becomeFirstResponder()
    }
    
    private func ui(block: Bool) {
        
        let point = navigationController!.view.center
        
        if block { addWaitingSpinner(at: point, color: OurColors.cyan) }
        else     { removeWaitingSpinner() }
        
        navigationItem.setHidesBackButton(block, animated: true)
        navigationItem.leftBarButtonItem?.isEnabled  = !block
        navigationItem.rightBarButtonItem?.isEnabled = !block
        textView.isUserInteractionEnabled = !block
        textView.resignFirstResponder()
    }

}
