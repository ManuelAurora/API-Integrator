//
//  HubspotChoosePipelineViewController.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 04.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

class HubspotChoosePipelineViewController: UIViewController
{
    var delegate: HubspotSalesFunnelMakerProtocol!
    
    @IBOutlet weak var pipelinesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        pipelinesTableView.layer.cornerRadius = 15
        pipelinesTableView.delegate = self
        pipelinesTableView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .custom
    }
}

extension HubspotChoosePipelineViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
    }
}

extension HubspotChoosePipelineViewController: UITableViewDataSource
{    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PipelineCell")
        cell?.textLabel?.text = "cell"
        return cell!
    }
}
