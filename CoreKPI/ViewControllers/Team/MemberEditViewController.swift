//
//  MemberEditViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class MemberEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, updateModelDelegate, updateProfileDelegate, updateTypeOfAccountDelegate, UITextFieldDelegate {
    
    var model: ModelCoreKPI!
    var profile: Profile!
    var newProfile: Profile!
    var request: Request!
    var profileImage: UIImage?
    
    weak var memberInfoVC: MemberInfoViewController!
    var delegate: updateProfileDelegate!
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var memberProfilePhotoImage: UIImageView!
    @IBOutlet weak var memberNameTextField: BottomBorderTextField!
    @IBOutlet weak var memberPositionTextField: BottomBorderTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.memberNameTextField.text = "\(profile.firstName) \(profile.lastName)"
        self.memberPositionTextField.text = profile.position
        
        if profileImage != nil {
            self.memberProfilePhotoImage.image = profileImage
        }
        
        self.newProfile = Profile(profile: profile)
        self.request = Request(model: self.model)
        
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
        
        if model.profile?.typeOfAccount == TypeOfAccount.Admin && model.profile?.userName != profile.userName {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if model.profile?.typeOfAccount == TypeOfAccount.Admin && model.profile?.userName != profile.userName {
                return 1
            } else {
                fallthrough
            }
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if model.profile?.typeOfAccount == TypeOfAccount.Admin && model.profile?.userName != profile.userName {
                let cellTypeOfAccount = tableView.dequeueReusableCell(withIdentifier: "TypeOfAccount", for: indexPath) as! TypeAccountTableViewCell
                cellTypeOfAccount.typeAccountLabel.text = self.newProfile.typeOfAccount.rawValue
                return cellTypeOfAccount
            } else {
                fallthrough
            }
        case 1:
            let cellMemberEdit = tableView.dequeueReusableCell(withIdentifier: "MemberInfoEdit", for: indexPath) as! MemberEditTableViewCell
            switch indexPath.row {
            case 0:
                cellMemberEdit.headerOfCell.text = "Phone"
                cellMemberEdit.textFieldOfCell.text = profile.phone
                cellMemberEdit.textFieldOfCell.placeholder = "No Phone"
                cellMemberEdit.textFieldOfCell.keyboardType = .numberPad
                cellMemberEdit.textFieldOfCell.tag = 0
            case 1:
                cellMemberEdit.headerOfCell.text = "E-mail"
                cellMemberEdit.textFieldOfCell.text = profile.userName
                cellMemberEdit.textFieldOfCell.placeholder = "No E-mail"
                cellMemberEdit.textFieldOfCell.keyboardType = .emailAddress
                cellMemberEdit.textFieldOfCell.tag = 1
            default:
                cellMemberEdit.headerOfCell.text = ""
                cellMemberEdit.textFieldOfCell.text = ""
                print("Cell create by default case")
            }
            return cellMemberEdit
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        switch indexPath!.section {
        case 0:
            fallthrough
        case 1:
            let memberEditCell = UITableViewCell() as! MemberEditTableViewCell
            switch indexPath!.row {
            case 0:
                if memberEditCell.textFieldOfCell.text != "" {
                    self.newProfile.phone = memberEditCell.textFieldOfCell.text
                } else {
                    self.newProfile.phone = nil
                }
            case 1:
                self.newProfile.userName = memberEditCell.textFieldOfCell.text!
                
            default:
                break
            }
        default:
            break
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
        
        if checkInputValue() {
            createDataForRequest()
        } else {
            return
        }
        
        //debug only
        memberInfoVC.profileImage = self.memberProfilePhotoImage.image
        delegate = memberInfoVC
        delegate.updateProfile(profile: self.newProfile)
        self.navigationController!.popViewController(animated: true)
        
    }
    
    //MARK: - Check input value
    func checkInputValue() -> Bool {
        
        if self.memberNameTextField.text == "" {
            showAlert(title: "Error saving", message: "Name text field is empty")
            return false
        } else {
            let name = self.memberNameTextField.text?.components(separatedBy: " ")
            if (name?.count)! < 2 {
                self.showAlert(title: "Error", message: "Member should have first name and last name")
                return false
            } else {
                self.newProfile.firstName = (name?[0])!
                self.newProfile.lastName = (name?[1])!
            }
        }
        
        if self.memberPositionTextField.text == "" {
            self.newProfile.position = nil
        } else {
            self.newProfile.position = self.memberPositionTextField.text
        }
        
        if self.newProfile.userName == "" {
            showAlert(title: "Error", message: "Email text field is empty")
            return false
        } else {
            
            if self.newProfile.userName.range(of: "@") == nil || (self.newProfile.userName.components(separatedBy: "@")[0].isEmpty) ||  (self.newProfile.userName.components(separatedBy: "@")[1].isEmpty) {
                showAlert(title: "Error", message: "Invalid E-mail adress")
                return false
            }
        }
        
        if self.newProfile.phone == "" {
            self.newProfile.phone = nil
        }
        
        return true
    }
    
    func createDataForRequest() {
        var firstname: String?
        var lastname: String?
        var position: String?
        var phone: String?
        var email: String?
        var photo: UIImage?
        var newParams: [String : String?] = [:]
        var typeOfAccountWasChanged = false
        
        if self.newProfile.photo == "New photo link" {
            photo = self.memberProfilePhotoImage.image
            newParams["photo"] = sendProfilePhotoToServer(photo: photo!) ?? ""
        }
        if self.newProfile.firstName != self.profile.firstName {
            firstname = self.newProfile.firstName
            newParams["first_name"] = firstname
        }
        if self.newProfile.lastName != self.profile.lastName {
            lastname = self.newProfile.lastName
            newParams["last_name"] = lastname
        }
        if self.newProfile.position != self.profile.position {
            position = self.newProfile.position
            newParams["position"] = position ?? ""
        }
        if self.newProfile.phone != self.profile.phone {
            phone = self.newProfile.phone
            newParams["phone"] = phone ?? ""
        }
        if self.newProfile.userName != self.profile.userName {
            email = self.newProfile.userName
            newParams["username"] = email
        }
        if self.newProfile.typeOfAccount != self.profile.typeOfAccount {
            changeUserRights(typeOfAccount: self.newProfile.typeOfAccount)
            typeOfAccountWasChanged = true
        }
        if newParams.count > 0 {
            sendRequest(params: newParams)
        } else if newParams.count < 1 && typeOfAccountWasChanged == false {
            showAlert(title: "Warning", message: "Profile not changed")
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    func sendProfilePhotoToServer(photo: UIImage) -> String? {
        //send
        return "https://photo.png"
    }
    
    func sendRequest(params : [String : String?] ) {
        
        let data: [String : Any] = ["user_id" : newProfile.userId, "data" : params]
        
        request.getJson(category: "/account/changeProfile", data: data,
                        success: { json in
                            if self.parsingJson(json: json) {
                                self.memberInfoVC.profileImage = self.memberProfilePhotoImage.image
                                self.delegate = self.memberInfoVC
                                self.delegate.updateProfile(profile: self.newProfile)
                                self.navigationController!.popViewController(animated: true)
                            }
        },
                        failure: { (error) in
                            print(error)
        })
    }
    
    func parsingJson(json: NSDictionary) -> Bool {
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if (json["data"] as? NSDictionary) == nil {
                    print("Json data is broken")
                } else {
                    return true
                }
            } else {
                let errorMessage = json["message"] as! String
                print("Json error message: \(errorMessage)")
                showAlert(title: "Save profile error", message: errorMessage)
            }
        } else {
            print("Json file is broken!")
            
        }
        return false
    }
    
    func changeUserRights(typeOfAccount: TypeOfAccount) {
        
        let data: [String : Any] = ["user_id" : newProfile.userId, "mode" : typeOfAccount == .Admin ? 1 : 0]
        
        request.getJson(category: "/team/changeUserRights", data: data,
                        success: { json in
                            if self.parsingJson(json: json) {
                                print("TypeOfAccount was changed")
                            }
        },
                        failure: { (error) in
                            print(error)
        })
    }
    
    //MARK: - Show alert method
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypeOfAccount" {
            let destinationVC = segue.destination as! TypeOfAccountTableViewController
            destinationVC.memberEditVC = self
            destinationVC.typeOfAccount = self.newProfile.typeOfAccount
        }
    }
    
    //MARK: - UIImagePickerControllerDelegate methods
    
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
        self.newProfile.photo = "New photo link"
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
    func updateProfilePhoto() {
    }
    //MARK: - updateTypeOfAccountDelegate method
    func updateTypeOfAccount(typeOfAccount: TypeOfAccount) {
        self.newProfile.typeOfAccount = typeOfAccount
        tableView.reloadData()
    }
    
    //MARK: - UITextFieldDelegate method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField.tag {
        case 0:
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = (newString as NSString).components(separatedBy: NSCharacterSet.decimalDigits.inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne {
                formattedString.append("1 ")
                index += 1
            }
            if (length - index) > 3 {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            if length - index > 3 {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            self.newProfile.phone = formattedString as String
            return false
        case 1:
            let textFieldText: NSString = (textField.text ?? "") as NSString
            let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
            self.newProfile.userName = txtAfterUpdate
            return true
        default:
            return true
        }
    }
}
