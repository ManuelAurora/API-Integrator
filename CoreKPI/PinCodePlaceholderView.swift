//
//  PassLockPlaceholderView.swift
//  PassLockDemo
//
//  Created by Manuel Aurora on 14.02.17.
//  Copyright © 2017 Manuel Aurora. All rights reserved.
//

import Foundation
import UIKit

class PinCodePlaceholderView: UIView
{
    public enum PlaceholderState
    {
        case empty
        case filled
    }
    
    private var borderColor = OurColors.violet
    private var borderRadius: CGFloat = 8
    private var borderWidth: CGFloat  = 1
    private var emptyColor: UIColor   = .white
    private var filledColor: UIColor  = OurColors.violet
           
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 16, height: 16)
    }
    
    override func didMoveToSuperview() {
        setupView()
    }
    
    private func setupView() {
        
        layer.borderWidth  = borderWidth
        layer.borderColor  = borderColor.cgColor
        layer.cornerRadius = borderRadius
        backgroundColor    = emptyColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    deinit {
        print("DEBUG: Placeholders deinitialized")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func getColorFor(state: PlaceholderState) -> UIColor {
        
        switch state {
        case .empty:  return emptyColor
        case .filled: return filledColor
        }
    }
    
    func animate(state: PlaceholderState) {
        
        let color = getColorFor(state: state)
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0,
                       options: [], animations: {
                        
                        self.backgroundColor = color
        }, completion: nil )
        
    }
    
}
