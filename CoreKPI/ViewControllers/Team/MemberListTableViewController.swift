//
//  MemberListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class MemberListTableViewController: UITableViewController {
    
    var model: ModelCoreKPI!
    let stateMachine = UserStateMachine.shared
    var indexPath: IndexPath!
    let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var addButton: UIBarButtonItem!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        refreshControl?.endRefreshing()
        refreshControl?.removeFromSuperview()
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        tableView.contentOffset = CGPoint(x: 0, y: 0 - self.tableView.contentInset.top)
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.clear
        refreshControl?.addTarget(self, action: #selector(self.refresh),
                                  for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refreshControl!)
        //Admin permission check!
        if model.profile?.typeOfAccount != TypeOfAccount.Admin
        {            
            self.navigationItem.rightBarButtonItem = nil
        }
        else { self.navigationItem.rightBarButtonItem = addButton }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.showsVerticalScrollIndicator = true
        tableView.isScrollEnabled = true 
        title = "Team List"
        
        let nc = NotificationCenter.default
       
        nc.addObserver(forName: .modelDidChanged, object:nil, queue:nil, using:catchNotification)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)]
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = OurColors.gray
    }
    
    // MARK: - Table view data source    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.team.count
    }
    
    private func thisIsMyAccount(_ index: Int) -> Bool? {
        
        guard model.team.count > 0 else { return nil }
        
        return Int(model.team[index].userID) == model.profile?.userId
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberListCell",
                                                 for: indexPath) as! MemberListTableViewCell
        
        if thisIsMyAccount(indexPath.row)!
        {
            cell.aditionalBackground.layer.borderWidth = 2
            cell.aditionalBackground.layer.borderColor = OurColors.cyan.cgColor
        }
        else
        {
            cell.aditionalBackground.layer.borderWidth = 0
            cell.aditionalBackground.layer.borderColor = UIColor.white.cgColor
        }
        
        let member = model.team[indexPath.row]
        
        if let memberNickname = member.nickname, memberNickname != "" {
            cell.userNameLabel.text = memberNickname
        } else {
            cell.userNameLabel.text = "\(member.firstName!) \(member.lastName!)"
        }
        
        if let imgUrlString = member.photoLink
        {
            cell.userProfilePhotoImage.loadImage(from: imgUrlString)
        }
        
        cell.userPosition.text = member.position
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction =  UITableViewRowAction(style: .default, title: "Delete", handler: {
            (action, indexPath) -> Void in
            self.deleteUser(userID: self.model.team[indexPath.row].userID)
            self.changeExecutant(index: indexPath.row)
            self.context.delete(self.model.team[indexPath.row])
            (UIApplication.shared .delegate as! AppDelegate).saveContext()
            self.model.team.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            do {
                self.model.team = try self.context.fetch(Team.fetchRequest())
            } catch {
                print("Fetching faild")
            }
            
            
            let nc = NotificationCenter.default
            nc.post(name: .modelDidChanged,
                    object: nil,
                    userInfo:["model": self.model])
        }
        )
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
            return [deleteAction]
        } else {
            return []
        }
        
    }
    
    func changeExecutant(index: Int) {
        
        let oldMemberID = Int(model.team[index].userID)
        
        for kpi in self.model.kpis {
            if kpi.createdKPI?.executant == oldMemberID {
                kpi.createdKPI?.executant = (model.profile?.userId)!
            }
        }
    }
    
    //MARK: - Ban user
    func deleteUser(userID: Int64) {
        let request = DeleteUser(model: model)
        request.deleteUser(withID: Int(userID), success: {
            self.loadTeamListFromServer()
        return
        }, failure: { error in
            print(error)
            self.showAlert(title: "Error Occured", errorMessage: error)
        self.loadTeamListFromServer()
        }
        )
    }
    
    //MARK: -  Pull to refresh method
    func refresh(sender:AnyObject)
    {
        loadTeamListFromServer()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MemberInfo" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! MemberInfoViewController           
                destinationController.index = indexPath.row
                destinationController.model = model                
                destinationController.memberListVC = self
            }
        }
        if segue.identifier == "MemberListInvite" {
            let destinationViewController = segue.destination as! InviteTableViewController
            destinationViewController.model = model
        }
    }
    
    private func sortUsers() {
        
        model.team.sort {
            if let firstUserName = $0.firstName, let secondUserName = $1.firstName
            {
                if $0.userID == Int64(stateMachine.profileId)
                {
                    return true
                }
                else if $1.userID == Int64(stateMachine.profileId)
                {
                    return false
                }
                
                return firstUserName < secondUserName
            }
            return false
        }
    }
    
    //MARK: - load team list from server
    func loadTeamListFromServer() {
        
        let stateMachine = UserStateMachine.shared
        let request = GetMemberList(model: model)
        
        stateMachine.getNumberOfInvitations()
        
        request.getMemberList(success: { team in
            self.model.team = team
            UserStateMachine.shared.updateProfile()
            self.sortUsers()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            
            do {
                try self.context.save()
            }
            catch {
                print(error)
                return
            }
            
        }, failure: { error in
            self.refreshControl?.endRefreshing()
            self.showAlert(title: "Error Occured", errorMessage: error)
            self.tableView.reloadData()
        }
        )
    }    
    
    func updateProfilePhoto() {
    }
    
    //MARK: - CatchNotification
    func catchNotification(notification:Notification) -> Void {
        
        if notification.name == .modelDidChanged {
            //loadTeamListFromServer()
        }
    }
}

extension MemberListTableViewController: StoryboardInstantiation {}
