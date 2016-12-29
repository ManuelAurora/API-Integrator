//
//  WebView2TestViewController.swift
//  CoreKPI
//
//  Created by Семен on 28.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class WebView2TestViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let htmlFile = Bundle.main.path(forResource:"index", ofType: "html")
        let cssFile = Bundle.main.path(forResource:"style", ofType: "css")
        let jsFile1 = Bundle.main.path(forResource:"Rd3.v3.min", ofType: "js")
        let jsFile2 = Bundle.main.path(forResource:"round", ofType: "js")

        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
        let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
        let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
        
        
        webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + js2! + "</script>", baseURL: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
