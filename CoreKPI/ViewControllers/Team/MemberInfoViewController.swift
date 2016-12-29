//
//  MemberInfoViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import MessageUI

class MemberInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var memberProfilePhotoImage: UIImageView!
    @IBOutlet weak var memberProfileNameLabel: UILabel!
    @IBOutlet weak var memberProfilePositionLabel: UILabel!
    @IBOutlet weak var responsibleForButton: UIButton!
    @IBOutlet weak var myKPIsButton: UIButton!
    @IBOutlet weak var securityButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var model: ModelCoreKPI!
    var profile: Profile!
    
    var updateModelDelegate: updateModelDelegate!
    var updateProfileDelegate: updateProfileDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check admin permission!!
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
            responsibleForButton.isHidden = false
            
            //Check is it my account
            if profile.userName == model.profile?.userName {
                responsibleForButton.isHidden = true
                myKPIsButton.isHidden = false
                securityButton.isHidden = false
            }
        } else {
            responsibleForButton.isHidden = true
            myKPIsButton.isHidden = true
            securityButton.isHidden = true
        }
        
        self.memberProfileNameLabel.text = "\(profile.firstName) \(profile.lastName)"
        self.memberProfilePositionLabel.text = profile.position
        
        if profile.photo != nil {
            //Add profile photo from base64 string
            let imageData = profile.photo
            let dataDecode: NSData = NSData(base64Encoded: imageData!, options: .ignoreUnknownCharacters)!
            let avatarImage: UIImage = UIImage(data: dataDecode as Data)!
            self.memberProfilePhotoImage.image = avatarImage
        }
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        //Set Navigation Bar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapPhoneButton(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Sorry!", message: "Calls are not available now...", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func tapMailButton(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([profile.userName])
            mail.setMessageBody("<p>Hello, \(profile.firstName) \(profile.lastName)</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            print("Email error")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
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
                cell.dataCellLabel.text = profile.typeOfAccount.rawValue
            case 1:
                cell.headerCellLabel.text = "Phone"
                if profile.phone == nil {
                    cell.dataCellLabel.text = "No Phone Number"
                    cell.dataCellLabel.textColor = UIColor(red: 143/255, green: 142/255, blue: 148/255, alpha: 1.0)
                } else {
                    cell.dataCellLabel.text = profile.phone
                }
            case 2:
                cell.headerCellLabel.text = "E-mail"
                cell.dataCellLabel.text = profile.userName
            default:
                cell.headerCellLabel.text = ""
                cell.dataCellLabel.text = ""
                print("Cell create by default case")
            }
        } else {
            switch indexPath.row {
            case 0:
                cell.headerCellLabel.text = "Phone"
                if profile.phone == nil {
                    cell.dataCellLabel.text = "No Phone Number"
                    cell.dataCellLabel.textColor = UIColor(red: 143/255, green: 142/255, blue: 148/255, alpha: 1.0)
                } else {
                    cell.dataCellLabel.text = profile.phone
                }
            case 1:
                cell.headerCellLabel.text = "E-mail"
                cell.dataCellLabel.text = profile.userName
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
            if model.profile?.userName != profile.userName {
                let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeName") as! ChageNameTableViewController
                updateModelDelegate = vc
                updateProfileDelegate = vc
                updateModelDelegate.updateModel(model: self.model)
                updateProfileDelegate.updateProfile(profile: self.profile)
                self.navigationController?.show(vc, sender: nil)
            } else {
                let vc = storyboard?.instantiateViewController(withIdentifier: "EditMember") as! MemberEditViewController
                updateModelDelegate = vc
                updateProfileDelegate = vc
                updateModelDelegate.updateModel(model: self.model)
                updateProfileDelegate.updateProfile(profile: self.profile)
                self.navigationController?.show(vc, sender: nil)
            }
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "EditMember") as! MemberEditViewController
            updateModelDelegate = vc
            updateProfileDelegate = vc
            updateModelDelegate.updateModel(model: self.model)
            updateProfileDelegate.updateProfile(profile: self.profile)
            self.navigationController?.show(vc, sender: nil)
        }
    }
    
    @IBAction func tapResponsibleForButton(_ sender: UIButton) {
        print("Responsible for was taped")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
}
