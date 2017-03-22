//
//  NumberChartViewController.swift
//  CoreKPI
//
//  Created by Семен on 14.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class NumberChartViewController: UIViewController {

    @IBOutlet weak var doubleDataView: UIView!
    @IBOutlet weak var singleDataView: UIView!
    
    //DoubleDataView
    @IBOutlet weak var doubleKPIName: UILabel!
    @IBOutlet weak var doubleTodayNumber: UILabel!
    @IBOutlet weak var doubleTodayPercent: UILabel!
    @IBOutlet weak var doubleTodayArrow: UIImageView!
    @IBOutlet weak var doubleYesterdayNumber: UILabel!
    
    //singleDataView
    @IBOutlet weak var singleDataKPIName: UILabel!
    @IBOutlet weak var singleTodayNumber: UILabel!
    @IBOutlet weak var singleTodayValueAndPercent: UILabel!
    @IBOutlet weak var singleTodayArrow: UIImageView!
}
