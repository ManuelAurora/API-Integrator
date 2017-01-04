//
//  MemberListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class MemberListTableViewController: UITableViewController {
    
    var model = ModelCoreKPI(token: "123", profile: Profile(userId: 1, userName: "user@mail.ru", firstName: "user", lastName: "user", position: "CEO", photo: nil, phone: nil, nickname: nil, typeOfAccount: .Admin))//: ModelCoreKPI!
    var request: Request!
    var memberList: [Profile] = []
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.request = Request(model: model)
        
        //Admin permission check!
        if model.profile?.typeOfAccount != TypeOfAccount.Admin {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.loadTeamListFromServer()
        
        tableView.tableFooterView = UIView(frame: .zero)
        //custom for MemberInfoViewController
//        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
//        self.navigationController?.navigationBar.shadowImage = nil
//        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberListCell", for: indexPath) as! MemberListTableViewCell
        cell.userNameLabel.text = "\(memberList[indexPath.row].firstName) \(memberList[indexPath.row].lastName)"
        cell.userPosition.text = memberList[indexPath.row].position
        if (memberList[indexPath.row].photo != nil) {
            //decode from base64 string
            let imageData = memberList[indexPath.row].photo
            if let dataDecode: NSData = NSData(base64Encoded: imageData!, options: .ignoreUnknownCharacters) {
                let avatarImage: UIImage = UIImage(data: dataDecode as Data)!
                cell.userProfilePhotoImage.image = avatarImage
            } else {
                print("\(memberList[indexPath.row].firstName)'s photo decoding error!")
            }
        }
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MemberInfo" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! MemberInfoViewController
                destinationController.profile = self.memberList[indexPath.row]
                destinationController.model = self.model
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
        })
    }
    
    func parsingJson(json: NSDictionary) {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSArray {
                    var teamListIsFull = false
                    var i = 0
                    while teamListIsFull == false {
                        
                        var profile: Profile!
                        
                        var firstName: String!
                        var lastName: String!
                        var mode: Int!
                        var typeOfAccount: TypeOfAccount!
                        var nickname: String?
                        var photo: String?
                        var position: String?
                        var userId: Int!
                        var userName: String!
                        
                        if let userData = dataKey[i] as? NSDictionary {
                            position = userData["position"] as? String
                            mode = userData["mode"] as? Int
                            mode == 0 ? (typeOfAccount = TypeOfAccount.Manager) : (typeOfAccount = TypeOfAccount.Admin)
                            nickname = userData["nickname"] as? String
                            lastName = userData["last_name"] as? String
                            userName = userData["username"] as? String
                            userId = userData["user_id"] as? Int
                            if (userData["photo"] as? String) != "" {
                                photo = userData["photo"] as? String
                            }
                            
                            firstName = userData["first_name"] as? String
                            
                            profile = Profile(userId: userId, userName: userName, firstName: firstName, lastName: lastName, position: position, photo: photo, phone: nil, nickname: nickname, typeOfAccount: typeOfAccount)
                            self.memberList.append(profile)
                            
                            i+=1
                            
                            if dataKey.count == i {
                                teamListIsFull = true
                            }
                        }
                    }
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
        tableView.reloadData()
    }
    
    //MARK: - show alert function
    func showAlert(errorMessage: String) {
        let alertController = UIAlertController(title: "Team list loading error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
