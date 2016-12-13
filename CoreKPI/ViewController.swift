//
//  ViewController.swift
//  CoreKPI
//
//  Created by Семен on 13.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let request = Request()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let backgroundQueue = DispatchQueue(label: "load", qos: .background, target: nil)
        
        backgroundQueue.async() {
            self.request.getJsonTest(
                success: { (json) in
                    print(json)
                    
            },
                failure: { (error) in
                    print(error)
            })
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

