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
    
    var model: ModelCoreKPI!
    var profile: Profile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check admin permission!!
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
        }
        
        self.memberProfileNameLabel.text = "\(profile.firstName) \(profile.lastName)"
        self.memberProfilePositionLabel.text = profile.position
        //Add profile photo from base64 string
        let imageData = profile.photo
        let dataDecode: NSData = NSData(base64Encoded: imageData!, options: .ignoreUnknownCharacters)!
        let avatarImage: UIImage = UIImage(data: dataDecode as Data)!
        self.memberProfilePhotoImage.image = avatarImage
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
                cell.dataCellLabel.text = profile.phone
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
                cell.dataCellLabel.text = profile.phone
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
    
    
    @IBAction func tapResponsibleForButton(_ sender: UIButton) {
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditMember" {
            
            let destinationController = segue.destination as! MemberEditViewController
            destinationController.profile = self.profile
            destinationController.model = self.model
            
        }
    }
    
    
}
