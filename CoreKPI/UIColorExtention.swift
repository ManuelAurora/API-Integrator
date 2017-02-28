//
//  UIColorExtention.swift
//  CoreKPI
//
//  Created by Семен on 20.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var hex: Int? {
        return Int(self, radix: 16)
    }
}

// MARK: - Hex, Hex + Alpha, RGB, RGB + Alpha
extension UIColor {
    convenience init(hex: Int) {
        self.init(hex: hex, a: 1.0)
    }
    
    convenience init(hex: Int, a: CGFloat) {
        self.init(r: (hex >> 16) & 0xff, g: (hex >> 8) & 0xff, b: hex & 0xff, a: a)
    }
    
    convenience init(r: Int, g: Int, b: Int) {
        self.init(r: r, g: g, b: b, a: 1.0)
    }
    
    convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    convenience init?(hexString: String) {
        guard let hex = hexString.hex else {
            return nil
        }
        self.init(hex: hex)
    }
    
    func getHexString() -> String {
        let components = cgColor.components
        let red   = (components?[0])!*255
        let green = (components?[1])!*255
        let blue  = (components?[2])!*255
        
        let hexValue = String(format:"%02X", Int(red)) + String(format:"%02X", Int(green)) + String(format:"%02X", Int(blue))
        return hexValue
    }
}
