//
//  MemberListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class MemberListTableViewController: UITableViewController {

    var model: ModelCoreKPI = ModelCoreKPI(userId: 1, token: "1234", profile: Profile(userName: "user@mail.ru", firstName: "User", lastName: "User", position: "CEO", photo: nil, phone: "123456789", typeOfAccount: .Admin))
    var memberList: [Profile]!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Admin permission check!
        if model.profile?.typeOfAccount != TypeOfAccount.Admin {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        let jimPhoto = UIImagePNGRepresentation(#imageLiteral(resourceName: "Jim Carrey"))?.base64EncodedString(options: .lineLength64Characters)
        let jackiePhoto = UIImagePNGRepresentation(#imageLiteral(resourceName: "Jackie Chan"))?.base64EncodedString(options: .lineLength64Characters)
        let kimPhoto = UIImagePNGRepresentation(#imageLiteral(resourceName: "Kim Chan"))?.base64EncodedString(options: .lineLength64Characters)
        
        let jimProfile = Profile(userName: "Jim@mail.ru", firstName: "Jim", lastName: "Carrey", position: "CEO", photo: jimPhoto, phone: "8-800-555-35-35", typeOfAccount: .Admin)
        let jackieProfile = Profile(userName: "jackie@mail.ru", firstName: "Jackie", lastName: "Chan", position: "Sales Manager", photo: jackiePhoto, phone: "8-800-555-08-35", typeOfAccount: .Manager)
        let kimProfile = Profile(userName: "kim@mail.ru", firstName: "Kim", lastName: "Chan", position: "Sales Manager", photo: kimPhoto, phone: "8-800-635-05-85", typeOfAccount: .Manager)
        
        memberList = [jimProfile, jackieProfile, kimProfile]
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
        
        //decode from base64 string
        let imageData = memberList[indexPath.row].photo
        let dataDecode: NSData = NSData(base64Encoded: imageData!, options: .ignoreUnknownCharacters)!
        let avatarImage: UIImage = UIImage(data: dataDecode as Data)!
        cell.userProfilePhotoImage.image = avatarImage

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
        }
    }

}
