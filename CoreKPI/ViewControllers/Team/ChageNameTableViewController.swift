//
//  ChageNameTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 26.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class ChageNameTableViewController: UITableViewController, updateModelDelegate, updateProfileDelegate, updateNicknameDelegate {
    
    var model: ModelCoreKPI!
    var profile: Profile!
    var request: Request!
    weak var memberInfoVC: MemberInfoViewController!
    var delegate: updateProfileDelegate!
    
    @IBOutlet weak var NameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nickname = profile.nickname {
            self.NameLabel.text = nickname
        } else {
            self.NameLabel.text = profile.firstName + " " + profile.lastName
        }
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    @IBAction func tapSaveButton(_ sender: UIBarButtonItem) {
        if let nickname = self.NameLabel.text {
            if nickname != self.profile.nickname && nickname != self.profile.firstName + " " + self.profile.lastName {
                self.sendNicknameToServer(nickName: nickname)
                self.profile.nickname = nickname
            } else {
                self.navigationController!.popViewController(animated: true)
            }
        }
    }
    
    func sendNicknameToServer(nickName: String) {
        
        self.request = Request(model: model)
        let data: [String : Any] = ["user_id" : profile.userId, "nickname" : nickName]
        
        request.getJson(category: "/team/setNickName", data: data,
                        success: { json in
                            self.parsingJson(json: json)
        },
                        failure: { (error) in
                            print(error)
        })
    }
    
    func parsingJson(json: NSDictionary) {
        
        if let successKey = json["success"] as? Int {
            if successKey == 0 {
                let errorMessage = json["message"] as! String
                print("Json error message: \(errorMessage)")
                let alertController = UIAlertController(title: "Error set nickname", message: "\(errorMessage)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.navigationController!.popViewController(animated: true)
            }
        } else {
            print("Json file is broken!")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangeName" {
            let destinationVC = segue.destination as! NewNameViewController
            destinationVC.personName = self.NameLabel.text
            destinationVC.changeNameVC = self
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if(!(parent?.isEqual(self.parent) ?? false)) {
            delegate = memberInfoVC
            delegate.updateProfile(profile: self.profile)
        }
    }
    
    //MARK: - updateModelDelegate method
    func updateModel(model: ModelCoreKPI) {
        self.model = ModelCoreKPI(model: model)
    }
    
    //MARK: - updateProfileDelegate method
    func updateProfile(profile: Profile) {
        self.profile = Profile(profile: profile)
    }
    func updateProfilePhoto() {
    }
    
    //MARK: - updateNickNameDelegate method
    func updateNickname(nickname: String) {
        self.NameLabel.text = nickname
    }
}
