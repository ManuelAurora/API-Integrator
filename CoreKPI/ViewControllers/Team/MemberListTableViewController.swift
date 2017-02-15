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
    let modelDidChangeNotification = Notification.Name(rawValue:"modelDidChange")
    let profilePhotoDownloadNotification = Notification.Name(rawValue:"ProfilePhotoDownloaded")
    
    var indexPath: IndexPath!
    let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.clear
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
        
        //Admin permission check!
        if model.profile?.typeOfAccount != TypeOfAccount.Admin {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        loadTeamListFromServer()
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: profilePhotoDownloadNotification, object:nil, queue:nil, using:catchNotification)
        nc.addObserver(forName: modelDidChangeNotification, object:nil, queue:nil, using:catchNotification)

        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)]
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.team.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberListCell", for: indexPath) as! MemberListTableViewCell
        
        if let memberNickname = model.team[indexPath.row].nickname {
            cell.userNameLabel.text = memberNickname
        } else {
            cell.userNameLabel.text = "\(model.team[indexPath.row].firstName!) \(model.team[indexPath.row].lastName!)"
        }
        
        cell.userPosition.text = model.team[indexPath.row].position
        
        if let photo = model.team[indexPath.row].photo as? Data {
            cell.userProfilePhotoImage.image = UIImage(data: photo)
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
            nc.post(name: self.modelDidChangeNotification,
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
                destinationController.model = ModelCoreKPI(model: model)
                destinationController.memberListVC = self
            }
        }
        if segue.identifier == "MemberListInvite" {
            let destinationViewController = segue.destination as! InviteTableViewController
            destinationViewController.navigationItem.rightBarButtonItem = nil
            destinationViewController.model = ModelCoreKPI(model: model)
        }
    }
    
    //MARK: - load team list from server
    func loadTeamListFromServer() {
        let request = GetMemberList(model: model)
        request.getMemberList(success: { team in
            for profile in self.model.team {
                self.context.delete(profile)
            }
            self.model.team.removeAll()
            self.model.team = team
            do {
                try self.context.save()
            } catch {
                print(error)
                return
            }
            let nc = NotificationCenter.default
            nc.post(name: self.modelDidChangeNotification,
                    object: nil,
                    userInfo:["model": self.model])
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            
        }, failure: { error in
            self.refreshControl?.endRefreshing()
            self.showAlert(title: "Teamlist loading error", errorMessage: error)
            self.tableView.reloadData()
        }
        )
    }
    
    //MARK: - show alert function
    func showAlert(title: String, errorMessage: String) {
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func updateProfilePhoto() {
    }
    
    //MARK: - CatchNotification
    func catchNotification(notification:Notification) -> Void {
        
        if notification.name == profilePhotoDownloadNotification {
            guard let userInfo = notification.userInfo,
                let tag = userInfo["UIImageViewTag"] as? Int,
                let image = userInfo["photo"] as? UIImage
                else {
                    print("No userInfo found in notification")
                    return
            }
            model.team[tag].setValue(UIImagePNGRepresentation(image), forKey: "photo")
        }
        if notification.name == modelDidChangeNotification {
            guard let userInfo = notification.userInfo,
                let model = userInfo["model"] as? ModelCoreKPI else {
                    print("No userInfo found in notification")
                    return
            }
            self.model.kpis = model.kpis
        }
    }
}

extension MemberListTableViewController: updateModelDelegate {
    func updateModel(model: ModelCoreKPI) {
        self.model = ModelCoreKPI(model: model)
        tableView.reloadData()
    }
}
