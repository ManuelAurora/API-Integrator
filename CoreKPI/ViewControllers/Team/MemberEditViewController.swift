//
//  MemberEditViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class MemberEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, updateModelDelegate, updateProfileDelegate {
    
    var model: ModelCoreKPI!
    var profile: Profile!
    var newProfile: Profile!
    
    var delegate: updateModelDelegate!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var memberProfilePhotoImage: UIImageView!
    @IBOutlet weak var memberNameTextField: BottomBorderTextField!
    @IBOutlet weak var memberPositionTextField: BottomBorderTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.memberNameTextField.text = "\(profile.firstName) \(profile.lastName)"
        self.memberPositionTextField.text = profile.position
        
        if profile.photo != nil {
            //Add profile photo from base64 string
            let imageData = profile.photo
            let dataDecode: NSData = NSData(base64Encoded: imageData!, options: .ignoreUnknownCharacters)!
            let avatarImage: UIImage = UIImage(data: dataDecode as Data)!
            self.memberProfilePhotoImage.image = avatarImage
        }
        
        self.newProfile = Profile(profile: profile)
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - TableViewDatasource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
            if model.profile?.userName == profile.userName {
                return 2
            } else {
                return 3
            }
        } else {
            if model.profile?.userName == profile.userName {
                return 2
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellTypeOfAccount = tableView.dequeueReusableCell(withIdentifier: "TypeOfAccount", for: indexPath) as! TypeAccountTableViewCell
        let cellMemberEdit = tableView.dequeueReusableCell(withIdentifier: "MemberInfoEdit", for: indexPath) as! MemberEditTableViewCell
        
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
            if model.profile?.userName == profile.userName {
                switch indexPath.row {
                case 0:
                    cellMemberEdit.headerOfCell.text = "Phone"
                    cellMemberEdit.textFieldOfCell.text = profile.phone
                case 1:
                    cellMemberEdit.headerOfCell.text = "E-mail"
                    cellMemberEdit.textFieldOfCell.text = profile.userName
                    cellMemberEdit.textFieldOfCell.placeholder = "No E-mail"
                default:
                    cellMemberEdit.headerOfCell.text = ""
                    cellMemberEdit.textFieldOfCell.text = ""
                    print("Cell create by default case")
                }
            }// else {
            //                switch indexPath.row {
            //                case 0:
            //                    let stringTypeOfAccount = profile.typeOfAccount.rawValue
            //                    cellTypeOfAccount.typeAccountLabel.text = stringTypeOfAccount
            //                    return cellTypeOfAccount
            //                case 1:
            //                    cellMemberEdit.headerOfCell.text = "Phone"
            //                    cellMemberEdit.textFieldOfCell.text = profile.phone
            //                case 2:
            //                    cellMemberEdit.headerOfCell.text = "E-mail"
            //                    cellMemberEdit.textFieldOfCell.text = profile.userName
            //                    cellMemberEdit.textFieldOfCell.placeholder = "No E-mail"
            //                default:
            //                    cellMemberEdit.headerOfCell.text = ""
            //                    cellMemberEdit.textFieldOfCell.text = ""
            //                    print("Cell create by default case")
            //                }
            //            }
        } //else {
        //            if model.profile?.userName == profile.userName {
        //                switch indexPath.row {
        //                case 0:
        //                    cellMemberEdit.headerOfCell.text = "Phone"
        //                    cellMemberEdit.textFieldOfCell.text = profile.phone
        //                case 1:
        //                    cellMemberEdit.headerOfCell.text = "E-mail"
        //                    cellMemberEdit.textFieldOfCell.text = profile.userName
        //                    cellMemberEdit.textFieldOfCell.placeholder = "No E-mail"
        //                default:
        //                    cellMemberEdit.headerOfCell.text = ""
        //                    cellMemberEdit.textFieldOfCell.text = ""
        //                    print("Cell create by default case")
        //                }
        //            } else {
        //                self.navigationItem.title = "Change Name"
        //                cellMemberEdit.headerOfCell.text = "Change Name"
        //                cellMemberEdit.textFieldOfCell.text = "\(profile.firstName) \(profile.lastName)"
        //            }
        //
        //        }
        
        //return cellMemberEdit
        return cellTypeOfAccount
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
            if model.profile?.userName == profile.userName {
                let memberCell = tableView.cellForRow(at: indexPath!) as! MemberEditTableViewCell
                
                let index : Int = indexPath!.row
                
                switch index {
                case 0:
                    self.newProfile.phone = memberCell.textFieldOfCell.text
                case 1:
                    self.newProfile.userName = memberCell.textFieldOfCell.text!
                default:
                    break
                }
                self.newProfile.phone = memberCell.textFieldOfCell.text
                
            } else {
                //return 3
            }
        } else {
            if model.profile?.userName == profile.userName {
                //return 2
            } else {
                //return 1
            }
        }
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
        //let name = self.memberNameTextField.text
        let position = self.memberPositionTextField.text
        //let photo = self.memberProfilePhotoImage.image
        
        self.newProfile.position = position
        let parentVC: MemberInfoViewController = (self.navigationController?.parent)! as! MemberInfoViewController
        delegate = parentVC
        delegate.updateModel(model: self.model)
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
    
    //MARK: - updateModelDelegate method
    func updateModel(model: ModelCoreKPI) {
        self.model = ModelCoreKPI(model: model)
    }
    
    //MARK: - updateProfileDelegate method
    func updateProfile(profile: Profile) {
        self.profile = Profile(profile: profile)
    }
    
}
