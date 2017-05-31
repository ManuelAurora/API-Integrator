//
//  ServiceSelectionCollectionViewController.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 15.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class ServiceSelectionCollectionViewController: UICollectionViewController,
    UICollectionViewDelegateFlowLayout
{
    private let datasource = SelectServiceDatasource()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.delegate = self
        title = "Select Source"
    }    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        
        if section == 0
        {
            return 1
        }
        else
        {
            return datasource.kpiSources.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let selectedService = datasource.kpiSources[indexPath.row].service
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell",
                                                      for: indexPath) as! ServiceCell
        
        if indexPath.section == 0
        {
            cell.showCustomKPICell()
        }
        else
        {
            if indexPath.row > 0
            {
                cell.grayOut()
            }
            cell.setImageFor(service: selectedService)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size: CGSize
        
        if indexPath.section == 0
        {
            let width = view.frame.width - 20
            let height: CGFloat = view.frame.width / 4 - 20
            size  = CGSize(width: width, height: height)
        }
        else
        {
            let width = view.frame.width / 2 - 12.5
            let height = view.frame.width / 2 - 40
            size = CGSize(width: width, height: height)
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if indexPath.section == 0
        {
            let customKpiVc = storyboard.instantiateViewController(
                withIdentifier: .createNewCustomKpi) as! ChooseSuggestedKPITableViewController
            customKpiVc.model = ModelCoreKPI.modelShared           
            navigationController?.pushViewController(customKpiVc, animated: true)
        }
        else
        {
            let cell = collectionView.cellForItem(at: indexPath) as! ServiceCell
            
            if cell.isDisabled
            {
                cell.animate()
                return
            }
                
            let service = datasource.kpiSources[indexPath.row].service
            let externalKPIVC = storyboard.instantiateViewController(
                withIdentifier: .externalKPIVC) as! ExternalKPIViewController
            externalKPIVC.selectedService = service
            externalKPIVC.serviceKPI = datasource.getKpisFor(service: service)
            navigationController?.pushViewController(externalKPIVC, animated: true)
        }
    }
}
