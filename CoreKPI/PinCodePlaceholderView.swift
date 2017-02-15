//
//  PassLockPlaceholderView.swift
//  PassLockDemo
//
//  Created by Manuel Aurora on 14.02.17.
//  Copyright © 2017 Manuel Aurora. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class PassLocPlaceholderView: UIView
{
    @IBInspectable
    var borderColor: UIColor  = .blue {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    var borderRadius: CGFloat = 16 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat  = 1 {
        didSet {
            setupView()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 16, height: 16)
    }
    
    func setupView() {
        
        layer.borderWidth  = borderWidth
        layer.borderColor  = borderColor.cgColor
        layer.cornerRadius = borderRadius
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
