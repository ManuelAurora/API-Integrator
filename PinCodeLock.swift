//
//  PinCodeLock.swift
//  CoreKPI
//
//  Created by Мануэль on 16.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

struct PinLockConfiguration
{
    static let pinCodeLength = 4
    static let attempts = 3
}

class PinCodeLock
{
    var passcode = [String]()
    var attempts = PinLockConfiguration.attempts
    
    var delegate: PinCodeLockDelegate?
    
    private var currentIndex: Int {
        return passcode.count > 0 ? passcode.count - 1 : 0
    }
    
    func add(value: String) {
        
        passcode.append(value)
        delegate?.addedValue(at: currentIndex)
        
        if passcode.count == PinLockConfiguration.pinCodeLength {
            if let delegate = delegate as? PinCodeViewController {                
                if delegate.mode == .logIn {
                    delegate.handleAuthorizationBy(pinCode: passcode)
                    passcode.removeAll()
                }
                else {
                    if delegate.pinToConfirm.count > 0 {
                        delegate.createNew(pinCode: passcode)
                        passcode.removeAll()
                    }
                    
                    delegate.pinToConfirm = passcode
                    passcode.removeAll()                    
                }
            }
        }
        
        func removeLast() {
            
            delegate?.removedValue(at: currentIndex)
            passcode.removeLast()
        }
    }
}

protocol PinCodeLockDelegate: class {
    func addedValue(at index: Int)
    func removedValue(at index: Int)
    func handleAuthorizationBy(pinCode: [String])
}
