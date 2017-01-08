//
//  WebViewChartViewController.swift
//  CoreKPI
//
//  Created by Семен Осипов on 08.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

enum TypeOfChart {
    case PieChart
    case PointChart
}

class WebViewChartViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!

    var typeOfChart = TypeOfChart.PieChart
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch typeOfChart {
        case .PieChart:
            let htmlFile = Bundle.main.path(forResource:"index", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"style", ofType: "css")
            let jsFile1 = Bundle.main.path(forResource:"Rd3.v3.min", ofType: "js")
            let jsFile2 = Bundle.main.path(forResource:"round", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
            let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
            
            
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + js2! + "</script>", baseURL: nil)
            
        case .PointChart:
            let htmlFile = Bundle.main.path(forResource:"points", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"points", ofType: "css")
            let jsFile1 = Bundle.main.path(forResource:"d3", ofType: "js")
            let jsFile2 = Bundle.main.path(forResource:"points", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
            let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
            
            
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + js2! + "</script>", baseURL: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
