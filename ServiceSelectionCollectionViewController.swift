//
//  ServiceSelectionCollectionViewController.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 15.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

private let cellId = "ServiceCell"

struct KPISource
{
    let service: IntegratedServices
}


class ServiceCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setupView()
    }
    
    private let titleLabel: UILabel = {
        let title = "Custom KPI"
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        label.text = title
        return label
    }()
    
    private func setupView() {
                
        layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        backgroundColor = OurColors.lightBlue
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
    
    func setImageFor(service: IntegratedServices) {
        
        switch service
        {
        case .Quickbooks:       imageView.image = #imageLiteral(resourceName: "QuickBooks")
        case .GoogleAnalytics:  imageView.image = #imageLiteral(resourceName: "GoogleAnalytics")
        case .HubSpotCRM:       imageView.image = #imageLiteral(resourceName: "HubSpotCRM")
        case .HubSpotMarketing: imageView.image = #imageLiteral(resourceName: "HubSpotMarketing")
        case .PayPal:           imageView.image = #imageLiteral(resourceName: "PayPal")
        case .SalesForce:       imageView.image = #imageLiteral(resourceName: "SaleForce")
        default: break
        }
    }
}

class UserHeaderCell: UICollectionReusableView
{
    let titleLabel: UILabel = {
        let title = "Select Source"
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.text = title
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    private func setupView() {
        
        addSubview(titleLabel)
        
        titleLabel.anchor(self.topAnchor,
                          left: self.leftAnchor,
                          bottom: self.bottomAnchor,
                          right: self.rightAnchor,
                          topConstant: 0,
                          leftConstant: 0,
                          bottomConstant: 0,
                          rightConstant: 0,
                          widthConstant: 0,
                          heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ServiceSelectionCollectionViewController: UICollectionViewController,
    UICollectionViewDelegateFlowLayout
{
    private let headerId = "SectionHeader"
    private let source: [KPISource] = {
        
        let custom    = KPISource(service: .none)
        let sfService = KPISource(service: .SalesForce)
        let qbService = KPISource(service: .Quickbooks)
        let gaService = KPISource(service: .GoogleAnalytics)
        let hcService = KPISource(service: .HubSpotCRM)
        let hmService = KPISource(service: .HubSpotMarketing)
        let ppService = KPISource(service: .PayPal)
        
        return [custom, sfService, qbService, gaService, hcService, hmService, ppService]
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(UserHeaderCell.self,
                                 forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
    }    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        
        return source.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let selectedService = source[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell",
                                                      for: indexPath) as! ServiceCell
        
        if indexPath.row == 0
        {
            cell.showCustomKPICell()
        }
        else
        {
            cell.setImageFor(service: selectedService.service)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader
        {
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: headerId,
                                                                       for: indexPath) as! UserHeaderCell
            return cell
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width / 2 - 20
        let size = CGSize(width: width, height: width)
        return size
    }
       
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 50)
    }
    
   
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
}
