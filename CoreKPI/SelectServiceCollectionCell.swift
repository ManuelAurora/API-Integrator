//
//  SelectServiceCollectionCell.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 16.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class ServiceCell: UICollectionViewCell
{  
    @IBOutlet weak var imageView: UIImageView!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setupView()
    }
    
    private lazy var grayedOutLayer: CALayer = {
        let goLayer = CALayer()
        goLayer.backgroundColor = UIColor.black.cgColor
        goLayer.opacity = 0.49
        
        return goLayer
    }()
    
    private(set) var isDisabled: Bool = false
    
    private let titleLabel: UILabel = {
        let title = "Custom KPI"
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        label.text = title
        return label
    }()
    
    private let comingSoonLabel: UILabel = {
        let title = "Coming Soon"
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        label.text = title
        return label
    }()
    
    private let synchronizingLabel: UILabel = {
        let title = "Synchronizing..."
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .center
        label.text = title
        return label
    }()
    
    private func setupView() {
        
        layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        backgroundColor = OurColors.lightBlue
        grayedOutLayer.frame = bounds
    }
    
    func removeGrayLayer() {
        
        synchronizingLabel.removeFromSuperview()
        grayedOutLayer.removeFromSuperlayer()
    }
    
    func animateWaitingForServer() {
        
        layer.addSublayer(grayedOutLayer)
        addSubview(synchronizingLabel)
        
        synchronizingLabel.anchor(nil,
                                  left: leftAnchor,
                                  bottom: bottomAnchor,
                                  right: rightAnchor,
                                  topConstant: 0,
                                  leftConstant: 2,
                                  bottomConstant: 6,
                                  rightConstant: 2,
                                  widthConstant: 0,
                                  heightConstant: 20)
        
        UIView.animate(withDuration: 0.7, delay: 0, options: [.repeat, .autoreverse], animations: { 
            self.synchronizingLabel.alpha = 0
        }, completion: nil)
    }
    
    func grayOut() {
        
        isDisabled = true
        
        layer.addSublayer(grayedOutLayer)
        addSubview(comingSoonLabel)
        
        comingSoonLabel.anchor(topAnchor,
                               left: leftAnchor,
                               bottom: nil,
                               right: rightAnchor,
                               topConstant: 6,
                               leftConstant: 2,
                               bottomConstant: 0,
                               rightConstant: 2,
                               widthConstant: 0,
                               heightConstant: 20)        
    }
    
    func showCustomKPICell() {
        
        imageView.image = nil
        
        addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.anchor(self.topAnchor,
                          left: self.leftAnchor,
                          bottom: self.bottomAnchor,
                          right: self.rightAnchor,
                          topConstant: 0,
                          leftConstant: 0,
                          bottomConstant: 0,
                          rightConstant: 0,
                          widthConstant: 0,
                          heightConstant: self.frame.height / 2)
    }
    
    func set(image: UIImage) {
        
        imageView.image = image        
    }
    
    func animate() {
        
        frame.origin.x += 3
      
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 300,
                       options: [.curveEaseOut],
                       animations: {
                        self.frame.origin.x -= 3
        }, completion: nil)
    }
}


