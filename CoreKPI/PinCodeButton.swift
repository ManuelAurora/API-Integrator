//
//  PassLockButton.swift
//  PassLockDemo
//
//  Created by Manuel Aurora on 14.02.17.
//  Copyright © 2017 Manuel Aurora. All rights reserved.
//

import UIKit
import Foundation

class PinCodeButton: UIButton
{
    var borderColor = OurColors.violet
    
    var borderRadius: CGFloat = 30
    var borderWidth:  CGFloat = 1
    
    var actualNumber: String {
        get {
            return titleLabel!.text!
        }
    }
    
    private var defaultBGColor:   UIColor!
    private var highlightBGColor: UIColor!
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func setupButtonView() {
        
        defaultBGColor     = .clear
        highlightBGColor   = .green
        layer.borderColor  = borderColor.cgColor
        layer.borderWidth  = borderWidth
        layer.cornerRadius = borderRadius
        
        setTitleColor(borderColor, for: .normal)
        setTitleColor(.white, for: .highlighted)
        setTitleColor(.lightGray, for: .disabled)
    }    
    
    override func didMoveToSuperview() {
        setupButtonView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupActions()
    }
    
    func setupActions() {
        
        addTarget(self, action: #selector(PinCodeButton.touchUpHanler), for: [.touchUpInside, .touchCancel, .touchDragOutside])
        addTarget(self, action: #selector(PinCodeButton.touchDownHandler), for: .touchDown)
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
