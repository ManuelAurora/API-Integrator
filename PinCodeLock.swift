//
//  PinCodeLock.swift
//  CoreKPI
//
//  Created by Мануэль on 16.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class PinCodeLock
{
    struct Configuration
    {
        static let pinCodeLength = 4
        static let attempts = 3
    }
    
    private var passcode = [String]()
    var attempts = Configuration.attempts
    
    var delegate: PinCodeLockDelegate?
    
    private var currentIndex: Int {
        return passcode.count > 0 ? passcode.count - 1 : 0
    }
    
    func add(value: String) {
        
        passcode.append(value)
        delegate?.addedValue(at: currentIndex)
        
        if passcode.count == Configuration.pinCodeLength {
            delegate?.handleAuthorizationBy(pinCode: passcode)
            passcode.removeAll()
        }
    }
    
    func removeLast() {
        
        passcode.removeLast()
        delegate?.removedValue(at: currentIndex)
    }
    
}

protocol PinCodeLockDelegate: class {
    func addedValue(at index: Int)
    func removedValue(at index: Int)
    func handleAuthorizationBy(pinCode: [String])
}
