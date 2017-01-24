//
//  iOSChartsTestViewController.swift
//  CoreKPI
//
//  Created by Семен Осипов on 08.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit
import Charts

class VisitorCount {
    var date: Date = Date()
    var count: Int = Int(0)
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class iOSChartsTestViewController: UIViewController {

    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var barView: BarChartView!
    
    var array: [VisitorCount] = []
    var typeOfChart = TypeOfChart.PieChart
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        startArray()
        updateChartWithData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startArray() {
        
        for i in 0...6 {
            let one = VisitorCount()
            one.count = i
            self.array.append(one)
        }
    }
    
    @IBAction func buttonDidTaped(_ sender: UIButton) {
        if let value = textField.text , value != "" {
            let visitorCount = VisitorCount()
            visitorCount.count = (NumberFormatter().number(from: value)?.intValue)!
            textField.text = ""
            array.append(visitorCount)
        }
        updateChartWithData()
        self.dismissKeyboard()
    }

    func updateChartWithData() {
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<array.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(array[i].count))
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Visitor count")
        let chartData = BarChartData(dataSet: chartDataSet)
        barView.data = chartData
    }
    
}
