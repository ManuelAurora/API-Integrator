//
//  TalkToUsViewController.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 28.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class TalkToUsViewController: UITableViewController {

    let rows = 5
    
    private lazy var addQuestionButton: UIBarButtonItem = {
        let selector = #selector(addNewQuestion)

        let b = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add,
                                target: self,
                                action: selector)
        return b
    }()
    
    private func registerNibs() {
        
        let nib = UINib(nibName: "TalkToUsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TalkToUsCell")
    }
    
    
    @objc private func addNewQuestion() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier:
            .integrationRequestVC) as! SendNewIntegrationViewController
        
        navigationController?.pushViewController(vc, animated: true)        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Question"
        registerNibs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = addQuestionButton
        view.backgroundColor = OurColors.gray
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let cells = tableView.visibleCells as! [TalkToUsTableViewCell]
        
        cells.forEach { $0.prepareCellCosmetics() }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        
        return rows
    }
    
    override func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TalkToUsCell",
                                                 for: indexPath) as! TalkToUsTableViewCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        
        let detailVC = storyboard?.instantiateViewController(withIdentifier:
            .questionDetailTableVC) as! QuestionDetailTableViewController
        
        navigationController?.pushViewController(detailVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
