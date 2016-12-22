//
//  MemberEditViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class MemberEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var model: ModelCoreKPI!
    var profile: Profile!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var memberProfilePhotoImage: UIImageView!
    @IBOutlet weak var memberNameTextField: BottomBorderTextField!
    @IBOutlet weak var memberPositionTextField: BottomBorderTextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.memberNameTextField.text = "\(profile.firstName) \(profile.lastName)"
        self.memberPositionTextField.text = profile.position
        
        //Add profile photo from base64 string
        let imageData = profile.photo
        let dataDecode: NSData = NSData(base64Encoded: imageData!, options: .ignoreUnknownCharacters)!
        let avatarImage: UIImage = UIImage(data: dataDecode as Data)!
        self.memberProfilePhotoImage.image = avatarImage
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TableViewDatasource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellTypeOfAccount = tableView.dequeueReusableCell(withIdentifier: "TypeOfAccount", for: indexPath) as! TypeAccountTableViewCell
        let cellMemberEdit = tableView.dequeueReusableCell(withIdentifier: "MemberInfoEdit", for: indexPath) as! MemberEditTableViewCell
        switch indexPath.row {
        case 0:
            let temp = profile.typeOfAccount.rawValue
            cellTypeOfAccount.typeAccountLabel.text = temp
            return cellTypeOfAccount
        case 1:
            cellMemberEdit.headerOfCell.text = "Phone"
            cellMemberEdit.textFieldOfCell.text = profile.phone
        case 2:
            cellMemberEdit.headerOfCell.text = "E-mail"
            cellMemberEdit.textFieldOfCell.text = profile.userName
        default:
            cellMemberEdit.headerOfCell.text = ""
            cellMemberEdit.textFieldOfCell.text = ""
            print("Cell create by default case")
        }
        return cellMemberEdit
    }
    
    @IBAction func tapEditPhoto(_ sender: Any) {
        let actionViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionViewController.addAction(UIAlertAction(title: "Take a photo", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.imagePickerFromCamera()
        }))
        actionViewController.addAction(UIAlertAction(title: "Choose from gallery", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.imagePickerFromPhotoLibrary()
        }))
        actionViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionViewController, animated: true, completion: nil)
        
    }
    @IBAction func tapSaveButton(_ sender: Any) {
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: UIImagePickerControllerDelegate methods
    
    func imagePickerFromPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        memberProfilePhotoImage.image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        memberProfilePhotoImage.contentMode = UIViewContentMode.scaleAspectFill
        memberProfilePhotoImage.clipsToBounds = true
        dismiss(animated: true, completion: nil)
    }
    

}
