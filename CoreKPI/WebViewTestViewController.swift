//
//  WebViewTestViewController.swift
//  CoreKPI
//
//  Created by Семен on 27.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import JavaScriptCore
import WebKit

class WebViewTestViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var wkWebView: WKWebView? = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let htmlFile = Bundle.main.path(forResource:"points", ofType: "html")
        let cssFile = Bundle.main.path(forResource:"points", ofType: "css")
        let jsFile1 = Bundle.main.path(forResource:"d3", ofType: "js")
        let jsFile2 = Bundle.main.path(forResource:"points", ofType: "js")
        
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
        let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
        let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
        
        
        webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + js2! + "</script>", baseURL: nil)

        
        //Test webView
//        let url = URL(string: "http://yandex.ru")
//        let request = URLRequest(url: url!)
//        webView.loadRequest(request)

    }

}
