//
//  ServiceSelectionCollectionViewController.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 15.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class ServiceSelectionCollectionViewController: UICollectionViewController
    
{
    fileprivate let viewModel  = ServiceSelectionViewModel()
    fileprivate let nc         = NotificationCenter.default
    
    fileprivate var datasource: SelectServiceDatasource {
        return viewModel.datasource
    }
    
    deinit {
        nc.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeNotifications()
        
        collectionView?.delegate = self
        title = "Select Source"
    }
    
    private func subscribeNotifications() {
        
        nc.addObserver(forName: .integratedServicesListLoaded,
                       object: nil,
                       queue: nil) { _ in
                        self.collectionView?.reloadSections(IndexSet(integer: 1))
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return viewModel.getNumberOfSections()
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.getNumberOfCellsIn(section: section)
    }
        
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let sectionType = viewModel.sectionTypeFor(indexPath: indexPath)
        
        var cellView: UniversalCellView
        
        switch sectionType
        {
        case .custom:
            cellView = CustomCellView()
            
        case .integrated:
            let isActive = indexPath.row == 0
            let isIntServicesPrepared = viewModel.isIntegratedServicesPrepared()
            let selectedService = datasource.kpiSources[indexPath.row].service
            
            cellView = IntegratedCellView(service: selectedService,
                                               isActive: isActive,
                                               intServicesPrepared: isIntServicesPrepared)
        }
        
        return dequeueReusableCell(with: cellView, for: indexPath)
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sectionType = viewModel.sectionTypeFor(indexPath: indexPath)
        
        switch sectionType
        {
        case .custom:
            let customKpiVc = storyboard.instantiateViewController(
                withIdentifier: .createNewCustomKpi) as! ChooseSuggestedKPITableViewController
            customKpiVc.model = ModelCoreKPI.modelShared
            navigationController?.pushViewController(customKpiVc, animated: true)
            
        case .integrated:
            let cell = collectionView.cellForItem(at: indexPath) as! ServiceCell
            
            if cell.isDisabled || !viewModel.isIntegratedServicesPrepared()
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

extension ServiceSelectionCollectionViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size: CGSize
        let sectionType = viewModel.sectionTypeFor(indexPath: indexPath)
        
        switch sectionType
        {
        case .custom:
            let width = view.frame.width - 20
            let height: CGFloat = view.frame.width / 4 - 20
            size  = CGSize(width: width, height: height)
            
        case .integrated:
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
}
