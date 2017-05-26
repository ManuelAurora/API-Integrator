//
//  TalkToUsViewController.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 28.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class TalkToUsViewController: UITableViewController
{
    
    private let userId = ModelCoreKPI.modelShared.profile.userId
    
    var questions = [QuestionAnswer]()
    
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
        
        addQuestionButton.isEnabled = false
        
        let vc = storyboard?.instantiateViewController(withIdentifier:
            .integrationRequestVC) as! SendNewIntegrationViewController
        vc.title = "New Question"
        vc.messageType = .support
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func refresh() {
        
        requestConversations()
    }
    
    private func requestConversations() {
        
        let req = MessagesRequestManager(model: ModelCoreKPI.modelShared)
        
        req.getMessagesOf(type: .support, success: { result in
            self.ui(block: false)
            self.questions = result.filter { $0.userId == self.userId }
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }) { error in
            self.ui(block: false)
            self.refreshControl?.endRefreshing()
            print(error)
        }
    }
    
    private func ui(block: Bool) {
        
        if block
        {
            let center = navigationController!.view.center
            addWaitingSpinner(at: center, color: OurColors.cyan)
        }
        else
        {
            removeWaitingSpinner()
        }
        
        tableView.isUserInteractionEnabled = !block
        navigationItem.rightBarButtonItem?.isEnabled = !block
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self,
                                  action: #selector(self.refresh),
                                  for: UIControlEvents.valueChanged)
        refreshControl?.backgroundColor = UIColor.clear
        
        title = "Questions"
        registerNibs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        ui(block: true)
        requestConversations()
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
        
        return questions.count
    }
    
    override func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeAllAlamofireNetworking()
        ui(block: false)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let answer = questions[indexPath.row].answer
        let cell = tableView.dequeueReusableCell(withIdentifier: "TalkToUsCell",
                                                 for: indexPath) as! TalkToUsTableViewCell
        cell.questionLabel.text = "    " + questions[indexPath.row].question
        
        if answer == ""
        {
            cell.answerLabel.text = "There is no answer yet"
            cell.answerLabel.textColor = .gray
        }
        else { cell.answerLabel.text = answer }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        
        let detailVC = storyboard?.instantiateViewController(withIdentifier:
            .questionDetailTableVC) as! QuestionDetailTableViewController
        detailVC.message = questions[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
