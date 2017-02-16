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
    fileprivate let pincodeLock = PinCodeLock()
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet var pinCodePlaceholderViews: [PinCodePlaceholderView]!
    
    @IBAction func pinCodeButtonTapped(_ sender: PinCodeButton) {
        
        pincodeLock.add(value: sender.actualNumber)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pincodeLock.delegate = self
        infoLabel.textColor = OurColors.violet
    }
    
   
    
}

extension PinCodeViewController: PinCodeLockDelegate
{
    func addedValue(at index: Int) {
        
        pinCodePlaceholderViews[index].animate(state: .filled)
        //cancelButton.isEnabled = true
    }
    
    func removedValue(at index: Int) {
        
        pinCodePlaceholderViews[index].animate(state: .empty)
        pincodeLock.removeLast()
    }
    
    func handleAuthorizationBy(pinCode: [String]) {
        
        _ = pinCodePlaceholderViews.map { $0.animate(state: .empty) }
    }
}

