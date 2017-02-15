//
//  PassLockButton.swift
//  PassLockDemo
//
//  Created by Manuel Aurora on 14.02.17.
//  Copyright © 2017 Manuel Aurora. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
class PassLockButton: UIButton
{
    @IBInspectable
    var borderColor: UIColor = .blue {
        didSet {
            setupButtonView()
        }
    }
   
    @IBInspectable
    var borderRadius: CGFloat = 30 {
        didSet {
            setupButtonView()
        }
    }
    
    @IBInspectable
    var borderWidth:  CGFloat = 1 {
        didSet {
            setupButtonView()
        }
    }
    
    var actualNumber: String {
        get {
            return titleLabel!.text!
        }
    }
    
    var defaultBGColor: UIColor = .clear
    
    @IBInspectable
    var highlightBGColor: UIColor = .clear {
        didSet {
            setupButtonView()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func setupButtonView() {
        
        layer.borderColor  = borderColor.cgColor
        layer.borderWidth  = borderWidth
        layer.cornerRadius = borderRadius
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupButtonView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupActions()
    }
    
    func setupActions() {
        
        addTarget(self, action: #selector(PassLockButton.touchUpHanler), for: [.touchUpInside, .touchCancel, .touchDragOutside])
        addTarget(self, action: #selector(PassLockButton.touchDownHandler), for: .touchDown)
    }
    
    func touchUpHanler() {
        animateBackground(color: defaultBGColor)
    }
    
    func touchDownHandler() {
        animateBackground(color: highlightBGColor)
    }
    
    func animateBackground(color: UIColor) {
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            
            self.backgroundColor = color
            
        }, completion: nil)
    }
}
