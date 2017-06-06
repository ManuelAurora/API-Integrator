//
//  HubspotChoosePipelineViewController.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 04.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

class HubspotChoosePipelineViewController: UITableViewController, StoryboardInstantiation
{
    weak var delegate: HubspotSalesFunnelMakerProtocol!
    
    var pipelines: [HSPipeline]!
    
    private var choosenPipelines: [HSPipeline] = []
    
    deinit {
        print("DEBUG: HubspotChoosePipelineVC Deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIBarButtonItem(barButtonSystemItem: .done,
                                     target: self,
                                     action: #selector(self.transferChoosenPipelines))
        
        navigationItem.rightBarButtonItem = button
        navigationItem.setHidesBackButton(true, animated: false)
        title = "Pipelines"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PipelineCell") as! PipelineTableViewCell
        
        cell.pipelineTitleLabel.text = pipelines?[indexPath.row].label
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pipelines!.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! PipelineTableViewCell
        cell.wasSelected = !cell.wasSelected
        
        addRemovePipelineFrom(indexPath: indexPath, selected: cell.wasSelected)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func transferChoosenPipelines() {
        
        delegate.formChoosen(pipelines: choosenPipelines)
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func addRemovePipelineFrom(indexPath: IndexPath, selected: Bool) {
        
        let pipe = pipelines[indexPath.row]
        
        if selected
        {
            choosenPipelines.append(pipe)
        }
        else
        {
            let filtered = choosenPipelines.filter { $0.pipelineId != pipe.pipelineId }
            
            choosenPipelines = filtered
        }
    }
}
