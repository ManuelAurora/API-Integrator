//
//  AboutTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import MessageUI

class AboutTableViewController: UITableViewController   {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  section == 0 {
            return 3
        } else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
               sendEmail()
            case 1:
                if let url = URL(string: "https://www.facebook.com/smichrissoft/") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            case 2:
                if let url = URL(string: "http://twitter.com") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            default:
                break
                
            }
        case 1:
            switch indexPath.row {
            case 0:
                let defaultText = URL(string: "http://corekpi.com")
                let activityController = UIActivityViewController(activityItems: [defaultText as Any], applicationActivities: nil)
                present(activityController, animated: true, completion: nil)
            case 1:
                if let url = URL(string: "http://apple.com") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            default:
                break
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        
        switch section {
        case 0:
             header.textLabel?.text = "Get in touch"
        case 1:
            header.textLabel?.text = "I like CoreKPI"
        default:
            break
        }
        header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 13)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
}

//MARK: - Send Email
extension AboutTableViewController: MFMailComposeViewControllerDelegate {
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["info@smichrisgroup.com"])
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            print("Email error")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
