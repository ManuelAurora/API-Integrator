//
//  WebViewTestViewController.swift
//  CoreKPI
//
//  Created by Семен on 27.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class WebViewTestViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = Bundle.main.url(forResource: "points", withExtension: "html", subdirectory: "Точечный")
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        
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
