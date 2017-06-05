//
//  TextFieldDelegate + CheckInput.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 05.06.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

extension UITextFieldDelegate
{
    func check(textfields: [UITextField]) -> Bool {
        
        var result = false
        
        textfields.forEach {
            if let charsTotal = $0.text?.characters.count, charsTotal > 0 {
                result = true
            }
            else { result = false }
        }
        
        return result
    }
}
