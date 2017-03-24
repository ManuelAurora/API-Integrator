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
    var pieChartData: [(number: String, rate: String)] = []
    var pointChartData: [(country: String, life: String, population: String, gdp: String, color: String, kids: String, median_age: String)] = []
    var lineChartData: (usdData: [(date: String, rate: String)], eurData: [(date: String, rate: String)])!
    var barChartData: [(value: String, val: String)] = []
    var funnelChartData: [(name: String, value: String)] = []
    var positiveBarData: [(value: String, val: String)] = []
    var areaChartData: [(date: String, kermit: String, piggy: String, gonzo: String, lol: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = false
        webView.backgroundColor = UIColor.white
        webView.frame = view.bounds
        createCharts()
    }
    
    private func createCharts() {
        
        let tabBarHeight        = self.tabBarController?.tabBar.frame.size.height
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        let statusBarHeight     = UIApplication.shared.statusBarFrame.height
        
        let height = webView.bounds.size.height - (tabBarHeight! + navigationBarHeight! + statusBarHeight)
        let width  = webView.bounds.size.width
        
        switch typeOfChart
        {
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
            let topOfJsFile = "var margin    = {top: 50, right: 30, bottom: 30, left: 30}; var width = \(width) - (margin.left + margin.right); var height = \(height) - (margin.top + margin.bottom);" + generateDataForJS()
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
            
            let jsHead = "var FunnelWidth = \(width), FunnelHeight = \(height);" + generateDataForJS()
            
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
            let downOfJsFile = generateDataForJS() + "positiveBar(\(width), \(height), data, 180, 0.35);"
            
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
            let downOfJsFile = generateDataForJS() + "stack_area(\(width) - 0, \(height), data_stack_area);"
            
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + js2! + downOfJsFile + "</script>", baseURL: nil)
        }
    }
    
    private func generateDataForJS() -> String {
        switch typeOfChart {
        case .PieChart:
            //TODO: Remove test data
            //->Debug
            //pieChartData = [("кусок 1", 499), ("Value 2", 150), ("Value 3", 200), ("Value 4", 300), ("Value 5", 200)]
            //header = "This is Pie"
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
                ("Algeria","70.6","35468208","6300","blue","2.12","26.247"),
                ("Belgium","80","10754056","32832","green", "1.76","41.301"),
                ("France","81.3","63125894","29691","green","1.92","40.112"),
                ("Honduras","72.9","7754687","3516","firebrick","2.94","20.945"),
                ("Iran","73.1","74798599","12483","coral","1.57","26.799"),
                ("Morocco","70.2","32272974","4263","blue","2.12","26.215"),
                ("Russia","67.6","142835555","14207","green","1.35","38.054"),
                ("Spain","81.6","46454895","26779","green","1.42","40.174"),
                ("USA","78.5","313085380","41230","firebrick","2","36.59"),
                ("Australia","82.1","22268384","34885","violet","1.9","37.776")
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
            //TODO: Remove test data
            //->Debug
            lineChartData = (
                [
                    ("1482354000000", "26.4"),
                    ("1482440400000", "29.2"),
                    ("1482526800000", "26.4"),
                    ("1482613200000", "26.45"),
                    ("1482699600000", "26.3"),
                    ("1482786000000", "26.87"),
                    ("1482872400000", "26.52")
                ],
                [
                    ("1482354000000", "28.2"),
                    ("1482440400000", "28.3"),
                    ("1482526800000", "29.46"),
                    ("1482613200000", "27.95"),
                    ("1482699600000", "27.90"),
                    ("1482786000000", "27.9"),
                    ("1482872400000", "28.5")
                ])
            header = "This is LineChart"
            //<-Debug
        
            var dataForJS = "var usdData = ["
            for (index,item) in lineChartData.usdData.enumerated() {
                if index > 0 {
                    dataForJS += ","
                }
                let lineData = "{date: new Date(\(item.date)), rate: \(item.rate)}"
                dataForJS += lineData
            }
            dataForJS += "]; var eurData = ["
            for (index,item) in lineChartData.eurData.enumerated() {
                if index > 0 {
                    dataForJS += ","
                }
                let lineData = "{date: \(item.date), rate: \(item.rate)}"
                dataForJS += lineData
            }
            dataForJS += "];"
            return dataForJS
        case .BarChart:
            //TODO: Remove test data
            //->Debug
            barChartData =
                [
                    ("-250", "-230"),
                    ("-300", "-230"),
                    ("-220", "-200"),
                    ("-180", "-160"),
                    ("200", "180"),
                    ("-60", "-40"),
                    ("-260", "-200"),
                    ("180", "100"),
                    ("-150", "-100"),
                    ("300", "150"),
                    ("-220", "-190"),
                    ("-180", "-90"),
                    ("120", "100"),
                    ("60", "20"),
                    ("260", "50"),
                    ("180", "150")
                ]
            header = "This is BarChart"
            //<-Debug
            
            var dataForJS = "var data = ["
            for (index,item) in barChartData.enumerated() {
                if index > 0 {
                    dataForJS += ","
                }
                let barData = "{'name':'\(randomString(10))','value':\(item.value),'val':\(item.val)}"
                dataForJS += barData
            }
            dataForJS += "]"
            return dataForJS
            
        case .Funnel:
            //TODO: Remove test data
            //->Debug
            funnelChartData = [("Шаг вперед", "100"), ("Step 2", "200"), ("Step 3", "500"), ("Step 4", "50")]
            header = "This is FunnelChart"
            //<-Debug
            var dataForJS = "var dataByFunnel = ["
            for (index,item) in funnelChartData.enumerated() {
                if index > 0 {
                    dataForJS += ","
                }
                let funnelData = "['\(item.name)', \(item.value), '#87d37c']"
                dataForJS += funnelData
            }
            dataForJS += "];"
            return dataForJS
        case .PositiveBar:
            //TODO: Remove test data
            //->Debug
            positiveBarData = [
                ("250","230"),
                ("300","230"),
                ("220","200"),
                ("180","160"),
                ("200","180"),
                ("60","40"),
                ("260","200"),
                ("180","100"),
                ("150","100"),
                ("300","150"),
                ("220","190"),
                ("180","90"),
                ("120","100"),
                ("60","20"),
                ("260","50"),
                ("180","150"),
            ]
            //<-Debug
            var dataForJS = "var data = ["
            for (index,item) in positiveBarData.enumerated() {
                if index > 0 {
                    dataForJS += ","
                }
                let positiveBar = "{'name': '\(randomString(10))','value': \(item.value),'val': \(item.val)}"
                dataForJS += positiveBar
            }
            dataForJS += "];"
            return dataForJS
        case .AreaChart:
            //TODO: Remove test data
            //->Debug
            areaChartData = [
                ("13-Oct-31","85.44","150","80.57","50"),
                ("13-Nov-30","130","200.85","168.97","150"),
                ("13-Dec-31","113.46","350.88","40.57","200"),
                ("14-Jan-30","140.46","350.88","40.57","100")
            ]
            //<-Debug
            var dataForJS = "var data_stack_area = ["
            for (index,item) in areaChartData.enumerated() {
                if index > 0 {
                    dataForJS += ","
                }
                let areaChart = "{'date': '\(item.date)','Kermit': \(item.kermit),'piggy': \(item.piggy),'Gonzo': \(item.gonzo),'Lol': \(item.lol)}"
                dataForJS += areaChart
            }
            dataForJS += "];"
            return dataForJS
        }
    }

    private func randomString(_ length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func refreshView() {
        createCharts()
    }
}
