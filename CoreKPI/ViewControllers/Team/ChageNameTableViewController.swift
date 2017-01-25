//
//  ChageNameTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 26.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class ChageNameTableViewController: UITableViewController {
    
    var model: ModelCoreKPI!
    var index: Int!
    weak var memberInfoVC: MemberInfoViewController!
    var delegate: updateModelDelegate!
    
    let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var NameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nickname = model.team[index].nickname {
            self.NameLabel.text = nickname
        } else {
            self.NameLabel.text = model.team[index].firstName! + " " + model.team[index].lastName!
        }
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        self.navigationController?.hideTransparentNavigationBar()
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
        if let nickname = NameLabel.text {
            if nickname != model.team[index].nickname && nickname != model.team[index].firstName! + " " + model.team[index].lastName! {
                sendNicknameToServer(nickName: nickname)
                model.team[index].nickname = nickname
                
                //debug ->
                do {
                    try context.save()
                } catch {
                    print(error)
                    return
                }
                self.navigationController!.popViewController(animated: true)
                //<- debug
                
            } else {
                self.navigationController!.popViewController(animated: true)
            }
        }
    }
    
    func sendNicknameToServer(nickName: String) {
        
        let request = ChangeNickname(model: model)
        request.changeNickName(nickname: nickName, success: {
            do {
                try self.context.save()
            } catch {
                print(error)
                return
            }
            self.navigationController!.popViewController(animated: true)
        }, failure: { error in
            let alertController = UIAlertController(title: "Error set nickname", message: "\(error)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        )
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
            delegate.updateModel(model: model)
        }
    }
}

//MARK: - updateModelDelegate method
extension ChageNameTableViewController: updateModelDelegate {
    func updateModel(model: ModelCoreKPI) {
        self.model = ModelCoreKPI(model: model)
    }
}

//MARK: - updateNickNameDelegate method
extension ChageNameTableViewController: updateNicknameDelegate {
    func updateNickname(nickname: String) {
        NameLabel.text = nickname
    }
}
