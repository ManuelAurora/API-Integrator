//
//  MemberInfoViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import MessageUI
import PhoneNumberKit

class MemberInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var memberProfilePhotoImage: UIImageView!
    @IBOutlet weak var memberProfileNameLabel: UILabel!
    @IBOutlet weak var memberProfilePositionLabel: UILabel!
    @IBOutlet weak var responsibleForButton: UIButton!
    @IBOutlet weak var myKPIsButton: UIButton!
    @IBOutlet weak var securityButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var model: ModelCoreKPI!
    var index: Int!
    
    weak var memberListVC: MemberListTableViewController!
    
    var updateModelDelegate: updateModelDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check admin permission!!
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
            responsibleForButton.isHidden = false
            
            //Check is it my account
            if Int(model.team[index].userID) == model.profile?.userId {
                responsibleForButton.isHidden = true
                myKPIsButton.isHidden = false
                //securityButton.isHidden = false
            }
        } else {
            responsibleForButton.isHidden = true
            myKPIsButton.isHidden = true
            //securityButton.isHidden = true
        }
        
        if let memberNickname = model.team[index].nickname {
            memberProfileNameLabel.text = memberNickname
        } else {
            memberProfileNameLabel.text = "\(model.team[index].firstName!) \(model.team[index].lastName!)"
        }
        
        memberProfilePositionLabel.text = model.team[index].position
        
        if model.team[index].photo != nil {
            memberProfilePhotoImage.image = UIImage(data: model.team[index].photo as! Data)
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
        if model.team[index].phoneNumber == nil {
            let alertController = UIAlertController(title: "Can not call!", message: "Member has not a phone number", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
        } else {
            var url: URL!
            let phoneNumberKit = PhoneNumberKit()
            do {
                let phoneNumber = try phoneNumberKit.parse(model.team[index].phoneNumber!)
                url = URL(string: "tel://+\(phoneNumber.countryCode)\(phoneNumber.nationalNumber)")
            }
            catch {
                print("Generic parser error")
                return
            }
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                let alertController = UIAlertController(title: "Sorry", message: "Can not call!", preferredStyle: .alert)
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
                cell.dataCellLabel.text = model.team[index].isAdmin ? "Admin" : "Manager"
            case 1:
                cell.headerCellLabel.text = "Phone"
                if model.team[index].phoneNumber == nil {
                    cell.dataCellLabel.text = "No Phone Number"
                    cell.dataCellLabel.textColor = UIColor(red: 143/255, green: 142/255, blue: 148/255, alpha: 1.0)
                } else {
                    cell.dataCellLabel.text = model.team[index].phoneNumber
                    cell.dataCellLabel.textColor = UIColor.black
                }
            case 2:
                cell.headerCellLabel.text = "E-mail"
                cell.dataCellLabel.text = model.team[index].username!
            default:
                cell.headerCellLabel.text = ""
                cell.dataCellLabel.text = ""
                print("Cell create by default case")
            }
        } else {
            switch indexPath.row {
            case 0:
                cell.headerCellLabel.text = "Phone"
                if model.team[index].phoneNumber == nil {
                    cell.dataCellLabel.text = "No Phone Number"
                    cell.dataCellLabel.textColor = UIColor(red: 143/255, green: 142/255, blue: 148/255, alpha: 1.0)
                } else {
                    cell.dataCellLabel.text = model.team[index].phoneNumber
                    cell.dataCellLabel.textColor = UIColor.black
                }
            case 1:
                cell.headerCellLabel.text = "E-mail"
                cell.dataCellLabel.text = model.team[index].username!
            default:
                cell.headerCellLabel.text = ""
                cell.dataCellLabel.text = ""
                print("Cell create by default case")
            }
        }
        return cell
    }
    
    @IBAction func securityButtonTapped(_ sender: UIButton) {
        let pinViewController = PinCodeViewController(mode: .createNewPin)
        present(pinViewController, animated: true, completion: nil)
    }
    
    @IBAction func tapEditBautton(_ sender: UIBarButtonItem) {
        if model.profile?.typeOfAccount != TypeOfAccount.Admin {
            if model.profile?.userId != Int(model.team[index].userID) {
                let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeName") as! ChageNameTableViewController
                updateModelDelegate = vc
                updateModelDelegate.updateModel(model: model)
                vc.index = index
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
        updateModelDelegate.updateModel(model: model)
        vc.index = index
        vc.memberInfoVC = self
        self.navigationController?.show(vc, sender: nil)
    }
    
    @IBAction func tapResponsibleForButton(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "KPIListVC") as! KPIsListTableViewController
        vc.model = model
        vc.loadUsersKPI(userID: Int(model.team[index].userID))
        vc.navigationItem.rightBarButtonItem = nil
        vc.refreshControl = nil
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
                updateModelDelegate = memberListVC
                updateModelDelegate.updateModel(model: model)
            }
        }
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    func updateProfilePhoto() {
        if (model.team[index].photo != nil) {
            memberProfilePhotoImage.downloadedFrom(link: model.team[index].photoLink!)
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
            mail.setToRecipients([model.team[index].username!])
            mail.setMessageBody("<p>Hello, \(model.team[index].firstName!) \(model.team[index].lastName!)</p>", isHTML: true)
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
        self.model = ModelCoreKPI(model: model)
        if let nickname = model.team[index].nickname {
            memberProfileNameLabel.text = nickname
        } else {
            memberProfileNameLabel.text = model.team[index].firstName! + " " + model.team[index].lastName!
        }
        memberProfilePositionLabel.text = model.team[index].position
        if model.team[index].photo != nil {
            memberProfilePhotoImage.image = UIImage(data: model.team[index].photo as! Data)
        }
        tableView.reloadData()
        self.navigationController?.presentTransparentNavigationBar()
    }
}

