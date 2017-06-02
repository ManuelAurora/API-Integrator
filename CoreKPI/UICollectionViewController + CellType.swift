//
//  UICollectionViewController + CellType.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 02.06.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

extension UICollectionViewController
{
    func dequeueReusableCell(with cellView: UniversalCellView,
                             for indexPath: IndexPath) -> UICollectionViewCell {
        
        let type = type(of: cellView).universalCellType
        let identifier = String(describing: type)
        
        let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: identifier,
                                                       for: indexPath)
        
         cellView.universalSetup(cell: cell)
        
        return cell
    }
}
