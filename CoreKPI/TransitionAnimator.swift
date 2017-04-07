//
//  TransitionAnimator.swift
//
//  Created by Мануэль on 15.12.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//

import UIKit
import pop

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning
{
    let duration      = 0.35
    var transContext: UIViewControllerContextTransitioning!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        let toView    = transitionContext.view(forKey: .to)!
        let fromView  = transitionContext.view(forKey: .from)!
        
        transContext  = transitionContext
        
        container.addSubview(fromView)
        container.addSubview(toView)
        
        let transition = CATransition()
                transition.duration       = duration
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                transition.type           = kCATransitionPush
                transition.subtype        = kCATransitionFromRight
                transition.fillMode       = kCAFillModeForwards
                transition.isRemovedOnCompletion = true
                transition.delegate       = self
        toView.layer.add(transition, forKey: "thx1138")
        
        UIView.animate(withDuration: duration) { 
            
            fromView.alpha = 0.8
            fromView.frame.origin.x -= 50
        }
    }
}

extension TransitionAnimator: CAAnimationDelegate
{
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        transContext.completeTransition(!transContext.transitionWasCancelled)

    }
}
