//
//  OvalShapeLayer.swift
//  EyeGym
//
//  Created by Мануэль on 27.10.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//

import UIKit
import pop

class OvalShapeLayer: CAShapeLayer
{
    
    private let radius: CGFloat = 40
    
    init(point: CGPoint, color: UIColor) {
        
        super.init()
        
        strokeColor     = color.cgColor
        fillColor       = UIColor.clear.cgColor
        lineDashPattern = [4, 3]
        lineWidth       = 6
        
        path = UIBezierPath(
            ovalIn: CGRect(
                x: point.x - radius,
                y: point.y - radius,
                width: radius * 2,
                height: radius * 2)
            ).cgPath
        
        addPrepareForTrainingAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addPrepareForTrainingAnimations() {
        
        let strokeStartAnimation = POPBasicAnimation(propertyNamed: kPOPShapeLayerStrokeStart)!
        
        strokeStartAnimation.fromValue   = -0.5
        strokeStartAnimation.toValue     = 1.0
        strokeStartAnimation.duration    = 1.0
        strokeStartAnimation.repeatCount = 500
        
        let strokeEndAnimation = POPBasicAnimation(propertyNamed: kPOPShapeLayerStrokeEnd)!
        
        strokeEndAnimation.fromValue   = 0.0
        strokeEndAnimation.toValue     = 1.0
        strokeEndAnimation.duration    = 1.0
        strokeEndAnimation.repeatCount = 500
        
        self.pop_add(strokeStartAnimation, forKey: nil)
        self.pop_add(strokeEndAnimation, forKey: nil)
    }
    
    deinit {
        print("DEBUG: DEINIT")
    }   
}

extension OvalShapeLayer: CAAnimationDelegate
{
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let layer = anim.value(forKey: AnimationConstants.KeyPath.layer) as? CAShapeLayer
        {
            layer.removeFromSuperlayer()
        }
    }
}
