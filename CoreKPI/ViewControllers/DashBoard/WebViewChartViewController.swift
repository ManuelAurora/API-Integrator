//
//  WebViewChartViewController.swift
//  CoreKPI
//
//  Created by Семен Осипов on 08.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit
import WebKit

enum TypeOfChart: String {
    case PieChart = "Pie chart"
    case PointChart = "Point chart"
    case LineChart = "Line chart"
    case BarChart = "Negative bar chart"
    case Funnel = "Funnel chart"
    case PositiveBar = "Positive bar chart"
    case AreaChart = "Area chart"
}

class WebViewChartViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!

    var typeOfChart = TypeOfChart.PieChart
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = false
        webView.backgroundColor = UIColor.white
        webView.frame = view.bounds
        
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        let height = webView.bounds.size.height - (tabBarHeight! + navigationBarHeight! + statusBarHeight)
        let width = webView.bounds.size.width
        
        switch typeOfChart {
        case .PieChart:
            let htmlFile = Bundle.main.path(forResource:"index", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"style", ofType: "css")
            let jsFile1 = Bundle.main.path(forResource:"Rd3.v3.min", ofType: "js")
            let jsFile2 = Bundle.main.path(forResource:"round", ofType: "js")
            let accountingFile = Bundle.main.path(forResource: "accounting.min", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
            let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
            let acc = try? String(contentsOfFile: accountingFile!, encoding: String.Encoding.utf8)
            
            let endOfJS = "pie((\(width)), \(height), data_pie);"
            let topOfJS2 = self.getRandomValues()
            
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + acc! + "</script><script>" + js1! + "</script><script>" + topOfJS2 + js2! + endOfJS + "</script>", baseURL: nil)
            
        case .PointChart:
            let htmlFile = Bundle.main.path(forResource:"points", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"points", ofType: "css")
            let jsFile1 = Bundle.main.path(forResource:"d3", ofType: "js")
            let jsFile2 = Bundle.main.path(forResource:"points", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
            let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
            
            let topOfJS = "var margin = {top: 50, right: 30, bottom: 30, left: 30}; var width = \(width) - margin.left - margin.right; var height = \(height) - margin.top - margin.bottom;"
        
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + topOfJS + js2! + "</script>", baseURL: nil)
        case .LineChart:
            let htmlFile = Bundle.main.path(forResource:"Lines", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"Lines", ofType: "css")
            let jsFile1 = Bundle.main.path(forResource:"Rd3.v3.min", ofType: "js")
            let jsFile2 = Bundle.main.path(forResource:"Lines", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
            let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
            let topOfJsFile = "var margin    = {top: 50, right: 30, bottom: 30, left: 30}; var width = \(width) - (margin.left + margin.right); var height = \(height) - (margin.top + margin.bottom);"
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + topOfJsFile + js2! + "</script>", baseURL: nil)
        case  .BarChart:
            let htmlFile = Bundle.main.path(forResource:"bar", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"bar", ofType: "css")
            let jsFile1 = Bundle.main.path(forResource:"Rd3.v3.min", ofType: "js")
            let jsFile2 = Bundle.main.path(forResource:"bar", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
            let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
            
            let topOfJsFile = "var margin  = {top: 50, right: 30, bottom: 30, left: 30}; var width   = \(width) - (margin.left + margin.right); var height  = \(height) - (margin.top + margin.bottom);"
            
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + topOfJsFile + js2! + "</script>", baseURL: nil)
        case .Funnel:
            let htmlFile = Bundle.main.path(forResource:"funnel", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"funnel", ofType: "css")
            let jsJquerryFile = Bundle.main.path(forResource:"jquery.min", ofType: "js")
            let jsD3File = Bundle.main.path(forResource:"d3V442.min", ofType: "js")
            let jsD3FunnelFile = Bundle.main.path(forResource:"d3-funnel", ofType: "js")
            let jsFile = Bundle.main.path(forResource:"funnel", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let jsJquerry = try? String(contentsOfFile: jsJquerryFile!, encoding: String.Encoding.utf8)
            let jsD3 = try? String(contentsOfFile: jsD3File!, encoding: String.Encoding.utf8)
            let jsD3Funnel = try? String(contentsOfFile: jsD3FunnelFile!, encoding: String.Encoding.utf8)
            let js = try? String(contentsOfFile: jsFile!, encoding: String.Encoding.utf8)
            
            let jsHead = "var FunnelWidth = \(width), FunnelHeight = \(height)"
            
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + jsJquerry! + "</script><script>" + jsD3! + "</script><script>" + jsD3Funnel! + "</script><script>" + jsHead + js! + "</script>", baseURL: nil)
        case .PositiveBar:
            let htmlFile = Bundle.main.path(forResource:"positiveBar", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"positiveBar", ofType: "css")
            let jsFile1 = Bundle.main.path(forResource:"Rd3.v3.min", ofType: "js")
            let jsFile2 = Bundle.main.path(forResource:"positiveBar", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
            let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
            let downOfJsFile = "positiveBar(\(width), \(height), data, 180, 0.35);"
            
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + js2! + downOfJsFile + "</script>", baseURL: nil)
        case .AreaChart:
            let htmlFile = Bundle.main.path(forResource:"stackArea", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"stackArea", ofType: "css")
            let jsFile1 = Bundle.main.path(forResource:"Rd3.v3.min", ofType: "js")
            let jsFile2 = Bundle.main.path(forResource:"stackArea", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
            let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
            let downOfJsFile = "stack_area(\(width) - 0, \(height), data_stack_area);"
            
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + js2! + downOfJsFile + "</script>", baseURL: nil)
        }
    }

    func getRandomValues() -> String {
        let numOne = 200
        let numTwo = 150
        let numThree = 200
        let numFour = 300
        let numFive = 200
        
        var array = [numOne, numTwo, numThree, numFour, numFive]
        
        let random = Int(arc4random_uniform(4))
        array[random] = Int(arc4random_uniform(500))
        
        return "var numOne = \(array[0]); var numTwo = \(array[1]); var numThree = \(array[2]); var numFour = \(array[3]); var numFive = \(array[4]);"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
