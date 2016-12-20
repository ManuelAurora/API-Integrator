//
//  MemberInfoViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class MemberInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var memberListName: String!
    var memberProfilePhoto: UIImage!
    var memberPosition: String!

    var typeOfAccount: TypeOfAccount!
    var phoneNumber: String!
    var email: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func tapPhoneButton(_ sender: UIButton) {
    }
    
    @IBAction func tapMailButton(_ sender: UIButton) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberInfoCell", for: indexPath) as! MemberInfoTableViewCell
        switch indexPath.row {
        case 0:
            cell.headerCellLabel.text = "Type of account"
            if typeOfAccount != nil {
                cell.dataCellLabel.text = typeOfAccount.rawValue
            }
            
        case 1:
            cell.headerCellLabel.text = "Phone"
            cell.dataCellLabel.text = phoneNumber
        case 2:
            cell.headerCellLabel.text = "E-mail"
            cell.dataCellLabel.text = email
        default:
            cell.headerCellLabel.text = ""
            cell.dataCellLabel.text = ""
            print("Cell create by default case")
        }
        return cell
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
