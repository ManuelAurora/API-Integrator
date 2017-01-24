//
//  MemberInfoViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import MessageUI

class MemberInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var memberProfilePhotoImage: UIImageView!
    @IBOutlet weak var memberProfileNameLabel: UILabel!
    @IBOutlet weak var memberProfilePositionLabel: UILabel!
    @IBOutlet weak var responsibleForButton: UIButton!
    @IBOutlet weak var myKPIsButton: UIButton!
    @IBOutlet weak var securityButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var model: ModelCoreKPI!
    var profile: Team!
    //var profileImage: UIImage?
    
    weak var memberListVC: MemberListTableViewController!
    
    var updateModelDelegate: updateModelDelegate!
    var updateProfileDelegate: updateProfileDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check admin permission!!
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
            responsibleForButton.isHidden = false
            
            //Check is it my account
            if Int(profile.userID) == model.profile?.userId {
                responsibleForButton.isHidden = true
                myKPIsButton.isHidden = false
                securityButton.isHidden = false
            }
        } else {
            responsibleForButton.isHidden = true
            myKPIsButton.isHidden = true
            securityButton.isHidden = true
        }
        
        if let memberNickname = profile.nickname {
            memberProfileNameLabel.text = memberNickname
        } else {
            memberProfileNameLabel.text = "\(profile.firstName!) \(profile.lastName!)"
        }
        
        memberProfilePositionLabel.text = profile.position
        
        if profile.photo != nil {
            memberProfilePhotoImage.image = UIImage(data: profile.photo as! Data)
        } else {
            updateProfilePhoto()
        }
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        //Set Navigation Bar transparent
        self.navigationController?.presentTransparentNavigationBar()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapPhoneButton(_ sender: UIButton) {
        if profile.phoneNumber == nil {
            let alertController = UIAlertController(title: "Can not call!", message: "Member has not a phone number", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
        } else {
            let url = URL(string: "tel://\(profile.phoneNumber!)")
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                let alertController = UIAlertController(title: "Error", message: "Can not call!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
            return 3
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberInfoCell", for: indexPath) as! MemberInfoTableViewCell
        
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
            switch indexPath.row {
            case 0:
                cell.headerCellLabel.text = "Type of account"
                cell.dataCellLabel.text = profile.isAdmin ? "Admin" : "Manager"
            case 1:
                cell.headerCellLabel.text = "Phone"
                if profile.phoneNumber == nil {
                    cell.dataCellLabel.text = "No Phone Number"
                    cell.dataCellLabel.textColor = UIColor(red: 143/255, green: 142/255, blue: 148/255, alpha: 1.0)
                } else {
                    cell.dataCellLabel.text = profile.phoneNumber
                    cell.dataCellLabel.textColor = UIColor.black
                }
            case 2:
                cell.headerCellLabel.text = "E-mail"
                cell.dataCellLabel.text = profile.username!
            default:
                cell.headerCellLabel.text = ""
                cell.dataCellLabel.text = ""
                print("Cell create by default case")
            }
        } else {
            switch indexPath.row {
            case 0:
                cell.headerCellLabel.text = "Phone"
                if profile.phoneNumber == nil {
                    cell.dataCellLabel.text = "No Phone Number"
                    cell.dataCellLabel.textColor = UIColor(red: 143/255, green: 142/255, blue: 148/255, alpha: 1.0)
                } else {
                    cell.dataCellLabel.text = profile.phoneNumber
                    cell.dataCellLabel.textColor = UIColor.black
                }
            case 1:
                cell.headerCellLabel.text = "E-mail"
                cell.dataCellLabel.text = profile.username!
            default:
                cell.headerCellLabel.text = ""
                cell.dataCellLabel.text = ""
                print("Cell create by default case")
            }
        }
        return cell
    }
    
    @IBAction func tapEditBautton(_ sender: UIBarButtonItem) {
        if model.profile?.typeOfAccount != TypeOfAccount.Admin {
            if model.profile?.userId != Int(profile.userID) {
                let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeName") as! ChageNameTableViewController
                updateModelDelegate = vc
                updateProfileDelegate = vc
                updateModelDelegate.updateModel(model: model)
                updateProfileDelegate.updateProfile(profile: profile)
                vc.memberInfoVC = self
                self.navigationController?.show(vc, sender: nil)
            } else {
                updateEditMemberVC()
            }
        } else {
            updateEditMemberVC()
        }
    }
    
    func updateEditMemberVC() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EditMember") as! MemberEditViewController
        updateModelDelegate = vc
        updateProfileDelegate = vc
        updateModelDelegate.updateModel(model: model)
        updateProfileDelegate.updateProfile(profile: profile)
        vc.memberInfoVC = self
        self.navigationController?.show(vc, sender: nil)
    }
    
    @IBAction func tapResponsibleForButton(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "KPIListVC") as! KPIsListTableViewController
        vc.model = model
        vc.loadUsersKPI(userID: Int(profile.userID))
        vc.navigationItem.rightBarButtonItem = nil
        self.navigationController?.show(vc, sender: nil)
    }
    
    @IBAction func tapSecurityButton(_ sender: UIButton) {
        print("Bogdan don't say what this button do ;(")
    }

    //MARK: - navigation
    override func willMove(toParentViewController parent: UIViewController?) {
        if(!(parent?.isEqual(self.parent) ?? false)) {
            if memberListVC != nil {
                //debug
                self.profile.photoLink = "https://pp.vk.me/c624425/v624425140/1439b/3Ka-jAkA1Dw.jpg"
                updateProfileDelegate = memberListVC
                updateProfileDelegate.updateProfile(profile: profile)
            }
        }
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    func updateProfilePhoto() {
        if (profile.photo != nil) {
            memberProfilePhotoImage.downloadedFrom(link: profile.photoLink!)
        } else {
            memberProfilePhotoImage.image = #imageLiteral(resourceName: "defaultProfile")
        }
    }
    
}

//MARK: - MFMailComposeViewControllerDelegate methods
extension MemberInfoViewController: MFMailComposeViewControllerDelegate {
    @IBAction func tapMailButton(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([profile.username!])
            mail.setMessageBody("<p>Hello, \(profile.firstName) \(profile.lastName)</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            print("Email error")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

//MARK: - updateModelDelegate method
extension MemberInfoViewController: updateModelDelegate {
    func updateModel(model: ModelCoreKPI) {
        self.model = model
    }
}

//MARK: - updateProfileDelegate method
extension MemberInfoViewController: updateProfileDelegate {
    func updateProfile(profile: Team) {
        
        if let nickname = self.profile.nickname {
            memberProfileNameLabel.text = nickname
        } else {
            memberProfileNameLabel.text = profile.firstName! + " " + profile.lastName!
        }
        memberProfilePositionLabel.text = profile.position
        if profile.photo != nil {
            memberProfilePhotoImage.image = UIImage(data: profile.photo as! Data)
        }
        tableView.reloadData()
        self.navigationController?.presentTransparentNavigationBar()
    }
}
