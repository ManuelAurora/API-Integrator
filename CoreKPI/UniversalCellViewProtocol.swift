//
//  UniversalCellView.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 02.06.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

protocol CellView: UniversalCellView
{
    associatedtype CellType: UIView
    func setup(cell: CellType)
}

extension CellView
{
    static var universalCellType: UIView.Type {
        return CellType.self
    }
    
    func universalSetup(cell: UIView) {
        
        guard let cellType = cell as? CellType else {
            fatalError("Cannot find CellType for cell")
        }
        
        setup(cell: cellType)
    }
}

protocol UniversalCellView
{
    static var universalCellType: UIView.Type { get }
    func universalSetup(cell: UIView)
}

