//
//  WKWebViewTestViewController.swift
//  CoreKPI
//
//  Created by Семен on 21.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit
import WebKit

class WKWebViewTestViewController: UIViewController {
    
    var webView: WKWebView!
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView = WKWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        self.view.sendSubview(toBack: webView)
        
        loadWebView()
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(loadWebView), userInfo: nil, repeats: true)
    }
    
    func loadWebView() {
        //let tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        //let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        //let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        let height = self.view.frame.size.height// - (tabBarHeight! + navigationBarHeight! + statusBarHeight)
        let width = self.view.frame.size.width
        
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
        
        webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + acc! + "</script><script>" + js1! + "</script><script>" + topOfJS2 + js2! +  endOfJS + "</script>", baseURL: nil)
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
    
    @IBAction func closeVC(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
