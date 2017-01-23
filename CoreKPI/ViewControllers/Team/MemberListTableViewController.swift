//
//  MemberListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import CoreData

class MemberListTableViewController: UITableViewController, updateProfileDelegate {
    
    var model = ModelCoreKPI(token: "test", userID: 1) //debug!
    var request: Request!
    
    var indexPath: IndexPath!
    let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.request = Request(model: model)
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
        
        //Admin permission check!
        if model.profile?.typeOfAccount != TypeOfAccount.Admin {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.loadTeamListFromServer()
        
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
        return self.model.team.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberListCell", for: indexPath) as! MemberListTableViewCell
        
        if let memberNickname = self.model.team[indexPath.row].nickname {
            cell.userNameLabel.text = memberNickname
        } else {
            cell.userNameLabel.text = "\(self.model.team[indexPath.row].firstName!) \(self.model.team[indexPath.row].lastName!)"
        }
        
        cell.userPosition.text = self.model.team[indexPath.row].position
        
        if let photo = self.model.team[indexPath.row].photo as? Data {
            cell.userProfilePhotoImage.image = UIImage(data: photo)
        }
        
        if (self.model.team[indexPath.row].photoLink != nil) {
            //load photo from server
            cell.userProfilePhotoImage?.downloadedFrom(link: self.model.team[indexPath.row].photoLink!)
            
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
        })
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
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
                destinationController.profile = self.model.team[indexPath.row]
                destinationController.model = self.model
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
        
        let data: [String : Any] = [ : ]
        
        request.getJson(category: "/team/getTeamList", data: data,
                        success: { json in
                            self.parsingJson(json: json)
        },
                        failure: { (error) in
                            print(error)
                            self.refreshControl?.endRefreshing()
                            self.showAlert(errorMessage: error)
                            self.tableView.reloadData()
        })
    }
    
    func parsingJson(json: NSDictionary) {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSArray {
                    
                    for profile in model.team {
                        context.delete(profile)
                    }
                    self.model.team.removeAll()
                    
                    var teamListIsFull = false
                    var i = 0
                    while teamListIsFull == false {
                        
                        let profile = Team(context: context)
                        
                        if let userData = dataKey[i] as? NSDictionary {
                            profile.position = userData["position"] as? String
                            let mode = userData["mode"] as? Int
                            mode == 0 ? (profile.isAdmin = false) : (profile.isAdmin = true)
                            profile.nickname = userData["nickname"] as? String
                            profile.lastName = userData["last_name"] as? String
                            profile.username = userData["username"] as? String
                            profile.userID = Int64((userData["user_id"] as? Int)!)
                            if (userData["photo"] as? String) != "" {
                                profile.photoLink = userData["photo"] as? String
                            }
                            
                            profile.firstName = userData["first_name"] as? String
                            
                            do {
                                try context.save()
                            } catch {
                                print(error)
                                return
                            }
                            
                            model.team.append(profile)
                            
                            i+=1
                            if dataKey.count == i {
                                teamListIsFull = true
                            }
                        }
                    }
                    let profileDidChangeNotification = Notification.Name(rawValue:"profileDidChange")
                    let nc = NotificationCenter.default
                    nc.post(name:profileDidChangeNotification,
                            object: nil,
                            userInfo:["teamList": model.team])
                } else {
                    print("Json data is broken")
                }
            } else {
                let errorMessage = json["message"] as! String
                print("Json error message: \(errorMessage)")
                showAlert(errorMessage: errorMessage)
            }
        } else {
            print("Json file is broken!")
        }
        self.refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    //MARK: - show alert function
    func showAlert(errorMessage: String) {
        let alertController = UIAlertController(title: "Team list loading error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - updateProfileDelegate method
    func updateProfile(profile: Team) {
        tableView.reloadData()
    }
    func updateProfilePhoto() {
    }
}
