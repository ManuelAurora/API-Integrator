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
    var header: String = " "
    
    //data for charts
    var pieChartData: [(number: String, rate: Int)]!
    var pointChartData: [(country: String, life: Double, population: Int, gdp: Int, color: String, kids: Double, median_age: Double)]!
    
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
            let topOfJS2 = generateDataForJS()
            
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
            
            let topOfJS = "var margin = {top: 50, right: 30, bottom: 30, left: 30}; var width = \(width) - margin.left - margin.right; var height = \(height) - margin.top - margin.bottom;" + generateDataForJS()
        
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
            
            let topOfJsFile = "var margin  = {top: 50, right: 30, bottom: 30, left: 30}; var width   = \(width) - (margin.left + margin.right); var height  = \(height) - (margin.top + margin.bottom);"  + generateDataForJS()
            
            let htmlstring = html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + topOfJsFile + js2! + "</script>"
            
            webView.loadHTMLString(htmlstring, baseURL: nil)
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
    
    private func generateDataForJS() -> String {
        switch typeOfChart {
        case .PieChart:
            //TODO: Remove test data
            //->Debug
            pieChartData = [("Value 1", 200), ("Value 2", 150), ("Value 3", 200), ("Value 4", 300), ("Value 5", 200)]
            header = "This is Pie"
            //<-Debug
            var dataForJS = "var lable = '\(header)'; var data_pie = ["
            
            for (index,item) in pieChartData.enumerated() {
                if index > 0 {
                    dataForJS += ","
                }
                let pieData = "{number: '\(item.number)', rate: \(item.rate)}"
                dataForJS += pieData
            }
            dataForJS += "];"
            return dataForJS
        case .PointChart:
            //TODO: Remove test data
            //->Debug
            pointChartData = [
                ("Algeria",70.6,35468208,6300,"blue",2.12,26.247),
                ("Belgium",80,10754056,32832,"green", 1.76,41.301),
                ("France",81.3,63125894,29691,"green",1.92,40.112),
                ("Honduras",72.9,7754687,3516,"firebrick",2.94,20.945),
                ("Iran",73.1,74798599,12483,"coral",1.57,26.799),
                ("Morocco",70.2,32272974,4263,"blue",2.12,26.215),
                ("Russia",67.6,142835555,14207,"green",1.35,38.054),
                ("Spain",81.6,46454895,26779,"green",1.42,40.174),
                ("USA",78.5,313085380,41230,"firebrick",2,36.59),
                ("Australia",82.1,22268384,34885,"violet",1.9,37.776)
            ]
            header = "This is PointChart"
            //<-Debug
            var dataForJS = "var label = '\(header)'; var pointJson = ["
            
            for (index,item) in pointChartData.enumerated() {
                if index > 0 {
                    dataForJS += ","
                }
                let pointData = "{'country':'\(item.country)','life':\(item.life),'population':\(item.population),'gdp':\(item.gdp),'color':'\(item.color)','kids': \(item.kids),'median_age': \(item.median_age)}"
                dataForJS += pointData
            }
            dataForJS += "]"
            return dataForJS
        case .LineChart:
            return ""
        case .BarChart:
            return "var data =  [{'name':'AA','value':-250,'val':-230},{'name':'AB','value':-300,'val':-230},{'name':'AC','value':-220,'val':-200},{'name':'AD','value':-180,'val':-160},{'name':'AE','value':200,'val':180},{'name':'AF','value':-60,'val':-40},{'name':'AG','value':-260,'val':-200},{'name':'AH','value':180,'val':100},{'name':'BA','value':-150,'val':-100},{'name':'BB','value':300,'val':150},{'name':'BC','value':-220,'val':-190},{'name':'BD','value':-180,'val':-90},{'name':'BE','value':120,'val':100},{'name':'BF','value':60,'val':20},{'name':'BG','value':260,'val':50},{'name':'BH','value':180,'val':150},{'name':null}]"
        case .Funnel:
            return ""
        case .PositiveBar:
            return ""
        case .AreaChart:
            return ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
