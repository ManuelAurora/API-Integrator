//
//  MemberListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import CoreData

class MemberListTableViewController: UITableViewController {
    
    var model = ModelCoreKPI(token: "test", userID: 1) //debug!
    let modelDidChangeNotification = Notification.Name(rawValue:"modelDidChange")
    
    var indexPath: IndexPath!
    let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
        
        //Admin permission check!
        if model.profile?.typeOfAccount != TypeOfAccount.Admin {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        loadTeamListFromServer()
        
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
            if cell.userProfilePhotoImage.image != #imageLiteral(resourceName: "defaultProfile") {
                model.team[indexPath.row].setValue(UIImagePNGRepresentation(cell.userProfilePhotoImage.image!)! as NSData?, forKey: "photo")
            }
        } else {
            cell.userProfilePhotoImage.image = #imageLiteral(resourceName: "defaultProfile")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction =  UITableViewRowAction(style: .default, title: "Delete", handler: {
            (action, indexPath) -> Void in
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
        return [deleteAction]
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
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            
        }, failure: { error in
            self.refreshControl?.endRefreshing()
            self.showAlert(errorMessage: error)
            self.tableView.reloadData()
        }
        )
    }
    
    //MARK: - show alert function
    func showAlert(errorMessage: String) {
        let alertController = UIAlertController(title: "Team list loading error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func updateProfilePhoto() {
    }
}

extension MemberListTableViewController: updateModelDelegate {
    func updateModel(model: ModelCoreKPI) {
        self.model = ModelCoreKPI(model: model)
        tableView.reloadData()
    }
}
