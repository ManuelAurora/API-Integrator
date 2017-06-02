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
        setup(cell: cell as! CellType)
    }
}

protocol UniversalCellView
{
    static var universalCellType: UIView.Type { get }
    func universalSetup(cell: UIView)
}

