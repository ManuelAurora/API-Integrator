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
    
    private var cancelTap: UITapGestureRecognizer? {
        didSet {
            guard let tap = cancelTap else { return }
            view.addGestureRecognizer(tap)
            textView.addGestureRecognizer(tap)
        }
    }
    
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
    
    @objc private func cancelSelector() {
        
        removeAllAlamofireNetworking()
        cancelAllNetwokingAndAnimateonOnTap(false)      
        ui(block: false)
    }
    
    private func cancelAllNetwokingAndAnimateonOnTap(_ isOn: Bool) {
        
        if isOn
        {
            cancelTap = nil
            cancelTap = UITapGestureRecognizer(target: self,
                                               action: #selector(cancelSelector))
        }
        else if let gesture = cancelTap
        {
            view.removeGestureRecognizer(gesture)
            textView.removeGestureRecognizer(gesture)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.contentInset = UIEdgeInsetsMake(-50, 0, 0, 0)
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
        textView.resignFirstResponder()
        cancelAllNetwokingAndAnimateonOnTap(block)
    }

}
