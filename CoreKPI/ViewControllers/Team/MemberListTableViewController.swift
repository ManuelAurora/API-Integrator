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
        
        title = "Team List"
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: .profilePhotoDownloaded, object:nil, queue:nil, using:catchNotification)
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberListCell", for: indexPath) as! MemberListTableViewCell
        
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
        
        if let memberNickname = model.team[indexPath.row].nickname {
            cell.userNameLabel.text = memberNickname
        } else {
            cell.userNameLabel.text = "\(model.team[indexPath.row].firstName!) \(model.team[indexPath.row].lastName!)"
        }
        
        cell.userPosition.text = model.team[indexPath.row].position
        
        if let photo = model.team[indexPath.row].photo
        {
            cell.userProfilePhotoImage.image = UIImage(data: photo as Data)
        }
        
        if (model.team[indexPath.row].photoLink != nil) {
            //load photo from server
            cell.userProfilePhotoImage?.downloadedFrom(link: model.team[indexPath.row].photoLink!)
            cell.userProfilePhotoImage.tag = indexPath.row
        } else {
            cell.userProfilePhotoImage.image = #imageLiteral(resourceName: "defaultProfile")
        }
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
            self.showAlert(title: "Sorry", errorMessage: error)
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
    
    //MARK: - load team list from server
    func loadTeamListFromServer() {
        
        UserStateMachine.shared.getNumberOfInvitations()
        
        let request = GetMemberList(model: model)
        
        request.getMemberList(success: {
            team in
            self.model.team.forEach { self.context.delete($0) }
            self.model.team.removeAll()
            self.model.team = team.sorted { member in
                let memberId  = Int(member.0.userID)
                let profileId = self.model.profile?.userId
                
                return memberId == profileId
            }
            
            do {
                try self.context.save()
            }
            catch {
                print(error)
                return
            }
                        
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            
        }, failure: { error in
            self.refreshControl?.endRefreshing()
            self.showAlert(title: "Teamlist loading error", errorMessage: error)
            self.tableView.reloadData()
        }
        )
    }    
    
    func updateProfilePhoto() {
    }
    
    //MARK: - CatchNotification
    func catchNotification(notification:Notification) -> Void {
        
        if notification.name == .profilePhotoDownloaded {
            guard let userInfo = notification.userInfo,
                let tag = userInfo["UIImageViewTag"] as? Int,
                let image = userInfo["photo"] as? UIImage,
                model.team.count > 0
                else {
                    print("No userInfo with Picture found in notification")
                    return
            }
            model.team[tag].setValue(UIImagePNGRepresentation(image), forKey: "photo")
            do {
                try context.save()
            } catch {
                print(error)
                return
            }
        }
        if notification.name == .modelDidChanged {
            tableView?.reloadData()
        }
    }
}
